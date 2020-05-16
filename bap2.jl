function bap2(capacity,numitem,weight)
    # initialization
    # an optimal sulotion can not be smaller than the round up value of average weight
    theory = cld(sum(weight), 1)
    epsilon = 0.001
    pattern_pool=Array{Array}(undef,0)
    # This function gives a feasible solution by 2-approximation method
    upper, items = Initialisation(capacity,numitem,weight)
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
    # we
    branch_condition_tree= Array{Array}(undef,0)
    push!(branch_condition_tree, [])

    while length(branch_condition_tree)!=0
        println("------------round ", ii, "-------------")

        # println(branch_condition_tree)
        println("length tree", length(branch_condition_tree))
        constraints = branch_condition_tree[length(branch_condition_tree)]
        deleteat!(branch_condition_tree,length(branch_condition_tree))
        # constraints = branch_condition_tree[1]
        # deleteat!(branch_condition_tree,1)
        println("length before filtration ", length(pattern_pool))
        columns = filtration(constraints, pattern_pool)
        println("length after filtration ", length(columns))
        #println("constraint: ", constraints)
        #println("columns   ", columns)
        lower = -1000
        alpha = Array{Any, 1}(undef,0)
        nbit = 1
        feasibility = true
        while nbit<1000
            alpha, master, cons, feasibility= RDWLP(columns, numitem)

            println("length columns_cc   ", length(columns))
            println("length alpha_cc   ", length(alpha))
            # println("alpha", alpha)
            #update upperbound
            if !feasibility
                break
            end
            print("master value:", objective_value.(master))
            if isInteger(alpha)
                ss = objective_value.(master)
                if ss<upper
                    println("alpha is integer")
                    upper = ss
                    alpha_opt = Array{Array{Float, 1}}(undef,0)
                    for a in 1:length(alpha)
                        if alpha[a]==1
                            push!(alpha_opt, columns[a])
                        end
                    end
                end
            end
            d = JuMP.dual.(cons)
            aa, bb = Heuristic_sub(capacity, numitem, weight, d, constraints)
            y, sp_obj = pricing(d, numitem, weight, constraints)
            lower =sum(d)+sp_obj
            println("dual: ", lower)
            println("reduced cost: ", sp_obj)
            #update lower bound
            if lower>=upper
                break
            end
            if sp_obj>-epsilon    #or dual > primal??? heuristic for master?
                break
            end
            nbit+=1
            sum_weight = sum(y[k]*weight[k] for k in 1:numitem)
            #println("add column", y)
            push!(columns, y)
            if sum_weight>0.5
                push!(pattern_pool, y)
            end

        end


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

        # branch
        if upper>lower && flag
            #detection of solutioon integrality and selection the fractional patterns
            fraction_pattern = Array{Array}(undef,0)
            fraction_alpha = []
            for a in 1:length(alpha)
                if alpha[a]<1 && alpha[a]>0
                    push!(fraction_pattern, columns[a])
                    push!(fraction_alpha, alpha[a])
                end
            end
            i,j = search_fraction(fraction_pattern, numitem, fraction_alpha, constraints)
            println("find index i",i,", j: ",j)
            constraint_up = copy(constraints)
            push!(constraint_up, (i,j,1))
            constraint_down = copy(constraints)
            push!(constraint_down, (i,j,0))
            push!(branch_condition_tree, constraint_down)
            push!(branch_condition_tree, constraint_up)
        end
        ii = ii+1
        if upper == theory
            break
        end
    end
    return alpha_opt, upper
end

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
