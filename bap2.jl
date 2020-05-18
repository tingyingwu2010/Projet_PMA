function bap2(capacity,numitem,weight)
    # initialization
    # an optimal sulotion can not be smaller than the round up value of average weight
    theory = cld(sum(weight), 1)
    epsilon = 0.001
    pattern_pool=Array{Array}(undef,0)
    # This function gives a feasible solution by 2-approximation method
    upper, items = Initialisation(numitem,weight)
    # add inital patterns to pattern pool
    nb_node = 1
    for i in vec(items)
        sum_weight = i*weight
        push!(pattern_pool, reshape(i, (numitem,)))
    end

    lower = -1000
    alpha_opt = items
    ii = 1
    # we store the branch constraint in branch_condition_tree
    branch_condition_tree= Array{Array}(undef,0)
    push!(branch_condition_tree, [])
    # node processing
    while length(branch_condition_tree)!=0
        println("------------round ", ii, "-------------")
        println("length of bap tree ", length(branch_condition_tree))
        # branching constraint in current node
        constraints = branch_condition_tree[length(branch_condition_tree)]
        deleteat!(branch_condition_tree,length(branch_condition_tree))
        # constraints = branch_condition_tree[1]
        # deleteat!(branch_condition_tree,1)
        println("amount of patterns before filtration ", length(pattern_pool))
        columns = filtration(constraints, pattern_pool)
        println("amount of patterns after filtration ", length(columns))
        #println("constraint: ", constraints)
        #println("columns   ", columns)
        lower = -1000
        # solution of master problem
        alpha = Array{Any, 1}(undef,0)
        nbit = 1
        feasibility = true
        while nbit<1000
            alpha, master, cons, feasibility= RDWLP(columns, numitem)
            # println("length columns_cc   ", length(columns))
            # println("length alpha_cc   ", length(alpha))
            if !feasibility
                break
            end
            # println("master value:", objective_value.(master))
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
            # dynamic programming on pricing problem
            # aa, bb = Heuristic_sub(capacity, numitem, weight, d, constraints)
            y, sp_obj = pricing(d, numitem, weight, constraints)
            # calculate lower bound
            lower =sum(d)+sp_obj
            # println("reduced cost: ", sp_obj)
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
        # println("length current pool ", length(columns))

        # we branch only in the case that
        if upper>lower && flag
            # detection of solutioon integerality and selection the fractional patterns
            fraction_pattern = Array{Array}(undef,0)
            fraction_alpha = []
            for a in 1:length(alpha)
                if alpha[a]<1 && alpha[a]>0
                    push!(fraction_pattern, columns[a])
                    push!(fraction_alpha, alpha[a])
                    nb_node +=2
                end
            end
            # we chose the branch rule 2.1 in
            i,j = search_fraction(fraction_pattern, numitem, fraction_alpha, constraints)
            println("find branching index i: ",i,", j: ",j)
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
    return alpha_opt, upper, nb_node
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

# the function search the item i,j that we branch on
# pick up the fractional items that have largest total weight
function search_fraction(fraction_pattern, numitem, alpha, cons)
    for i in numitem:-1:2
        for j in (i-1):-1:1
            w=0
            for a in 1:length(alpha)
                if fraction_pattern[a][i]==1 && fraction_pattern[a][j]==1
                    w = w + alpha[a]
                end
            end
            if w<1 && w>0
                if !((i,j,0) in cons) && !((i,j,1) in cons)
                    return i, j
                end
            end
        end
    end
end

# filtration of patterns in pattern pool
function filtration(cons, columns)
    col_filt = copy(columns)
    ind = []
    for (i,j,type) in cons
        # filtration of up branch
        if type == 1
            for k in 1:length(col_filt)
                if col_filt[k][i] == 1 && col_filt[k][j] == 0
                    push!(ind,k)
                end
                if col_filt[k][i] == 0 && col_filt[k][j] == 1
                    push!(ind,k)
                end
            end

        # filtration of down branch
        else
            for k in 1:length(col_filt)
                if col_filt[k][i] == 1 && col_filt[k][j] == 1
                    push!(ind,k)
                end
            end
        end
    end
    deleteat!(col_filt, sort(unique(ind)))
    return col_filt
end
