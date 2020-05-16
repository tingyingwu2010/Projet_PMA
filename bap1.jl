function bap1(capacity,numitem,weight)
    # initialization
    # an optimal sulotion can not be smaller than the round up value of average weight
    theory = cld(sum(weight), 1)
    epsilon = 0.05
    pattern_pool=Array{Array}(undef,0)
    # This function gives a feasible solution by 2-approximation method
    upper, items = Initialisation(numitem,weight)
    # add inital patterns to pattern pool
    for i in vec(items)
        sum_weight = i*weight
        push!(pattern_pool, reshape(i, (numitem,)))
    end

    # print(pattern_pool)
    # start with the columns that each item in a bin
    # for i in 1:numitem
    #     a =  zeros(Int64, 1, numitem)
    #     a[i] = 1
    #     push!(pattern_pool, a)
    # end

    println(upper)
    lower = -1000
    alpha_opt = items
    ii = 1
    # we store the branch constraint in branch_condition_tree
    branch_condition_tree= Array{Array}(undef,0)
    push!(branch_condition_tree, [])
    # node processing
    while length(branch_condition_tree)!=0
        println("------------round ", ii, "-------------")
        println("length tree", length(branch_condition_tree))
        # branching constraint in current node (DFS)
        constraints = branch_condition_tree[length(branch_condition_tree)]
        deleteat!(branch_condition_tree,length(branch_condition_tree))
        # constraints = branch_condition_tree[1]
        # deleteat!(branch_condition_tree,1)
        columns = copy(pattern_pool)
        lower = -1000
        # solution of master problem
        alpha = Array{Any, 1}(undef,0)
        nbit = 1
        feasibility = true
        while nbit<1000
            alpha, master, cons, cons2, feasibility= RDWLP1(columns, numitem, constraints)
            if !feasibility
                break
            end
            println("master value:", objective_value.(master))
            # if the master problem is integer we, try to update upperbound
            if isInteger(alpha)
                ss = objective_value.(master)
                if ss<upper
                    println("alpha is integer")
                    upper = ss
                    alpha_opt = Array{Array}(undef,0)
                    for a in 1:length(alpha)
                        if alpha[a]==1
                            push!(alpha_opt, columns[a])
                        end
                    end
                end
            end
            d = JuMP.dual.(cons)
            mu = JuMP.dual.(cons2)
            y, sp_obj = pricing1(d, mu, numitem, weight, constraints)
            # calculate lower bound
            lower =sum(d)+sp_obj
            println("reduced cost: ", sp_obj)
            #update lower bound
            if lower>=upper
                break
            end
            # if reduced cost is positive, break
            if sp_obj>-epsilon
                break
            end
            nbit+=1
            sum_weight = sum(y[k]*weight[k] for k in 1:numitem)
            push!(columns, y)
            # we only add high quality parttens (total weight > 0.5)to the pattern pool
            if sum_weight>0.5
                push!(pattern_pool, y)
            end

        end
        println("dual: ", lower)
        # test the integrality and feasibility of master solution
        flag = !isInteger(alpha) && feasibility
        if flag
            heur_up, heur_item = SmallHeuristic(numitem, weight, alpha, columns, constraints)
            if heur_up<upper
                upper = heur_up
                #println("heuristic add", heur_item)
                alpha_opt = copy(heur_item)
            end
        end
        println("upper bound: ", upper)
        println("length current pool ", length(columns))

        # we branch only in the case that
        if upper>lower && flag
            # detection of solutioon integerality and selection the fractional patterns
            fraction_pattern = Array{Array}(undef,0)
            fraction_alpha = []
            for a in 1:length(alpha)
                if alpha[a]<1 && alpha[a]>0
                    push!(fraction_pattern, columns[a])
                    push!(fraction_alpha, alpha[a])
                end
            end
            # we chose the branch rule 2.1 in
            i,j = search_fraction(fraction_pattern, numitem, fraction_alpha, constraints)
            println("find index i",i,", j: ",j)
            # up branch (i,j together)
            constraint_up = copy(constraints)
            push!(constraint_up, (i,j,1))
            # down branch (i,j seprate)
            constraint_down = copy(constraints)
            push!(constraint_down, (i,j,0))
            push!(branch_condition_tree, constraint_down)
            push!(branch_condition_tree, constraint_up)
        end
        ii = ii+1
        # if the theorical optimal value is reached, we end the program
        if upper == theory
            break
        end
    end
    return alpha_opt, upper
end

# the function detects the integerality of an array
function isInteger(alpha)
    flag = true
    for a in 1:length(alpha)
        if alpha[a]<1 && alpha[a]>0
            flag=false
            break
        end
    end
    return flag
end
