
function bap2(capacity,numitem,weight)
    #initialization
    #lambda=Array{VariableRef}(undef,9)
    theory = cld(sum(weight), capacity)
    epsilon = 0.001
    pattern_pool=Array{Array}(undef,0)
    upper, items = Initialisation(capacity,numitem,weight)
    for i in vec(items)
        push!(pattern_pool, i)
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
    # column_tree=Array{Array{Array}}(undef,0)
    # push!(column_tree,pattern_pool)
    branch_condition_tree= Array{Array{Any,1},1}(undef,0)
    push!(branch_condition_tree, [])
    while length(branch_condition_tree)!=0
        println("------------round ", ii, "-------------")
        # columns = column_tree[length(columns)]
        # deleteat!(column_tree,length(column_tree))
        println("length tree", length(branch_condition_tree))
        println("length general pool", length(pattern_pool))
        constraints = branch_condition_tree[length(branch_condition_tree)]
        deleteat!(branch_condition_tree,length(branch_condition_tree))
        columns = filtration(constraints, pattern_pool)
        lower = -1000
        alpha = Array{Any, 1}(undef,0)
        ss = -1000
        while true
            alpha, master, cons= RDWLP(columns, numitem)
            d = JuMP.dual.(cons)
            y, sp_obj = pricing(d, numitem, weight, constraints)
            ss = objective_value.(master)
            #update lower bound
            lower = sum(d)+sp_obj
            println("dual: ", lower)
            if sp_obj>-epsilon    #or dual > primal??? heuristic for master?
                break
            end
            push!(pattern_pool, y)
            push!(columns, y)
            println("length current pool ", length(columns))
        end

        #detection of solutioon integrality and selection the fractional patterns
        fraction_pattern = Array{Array}(undef,0)
        fraction_alpha = []
        flag = true
        for a in 1:length(alpha)
            if alpha[a]<1 && alpha[a]>0
                push!(fraction_pattern, pattern_pool[a])
                push!(fraction_alpha, alpha[a])
                flag = false
            end
        end
        #update upperbound
        if flag
            if ss<upper
                uppper = ss
                alpha_opt = copy(alpha)
            end
        end
        println("upper bound: ", upper)
        # branch
        if upper>lower && !flag               # solution infeasible??
            i,j = search_fraction(fraction_pattern, numitem, fraction_alpha)
            println("find index i",i,", j: ",j)
            constraint_up = copy(constraints)
            push!(constraint_up, (i,j,1))
            constraint_down = copy(constraints)
            push!(constraint_down, (i,j,0))
            push!(branch_condition_tree, constraint_up)
            push!(branch_condition_tree, constraint_down)
        end
        if upper == theory
            break
        end
        ii = ii+1
    end
    return alpha_opt, upper
end

# pick up the fractional items that have largest total weight
function search_fraction(fraction_pattern, numitem, alpha)
    for i in numitem:-1:1
        for j in numitem:-1:1
            w=0
            for a in 1:length(alpha)
                if fraction_pattern[a][i]==1 && fraction_pattern[a][j]==1
                    w = w + alpha[a]
                end
            end
            if w<1 && w>0
                return i, j
            end
        end
    end
end

function filtration(cons, columns)
    col_filt = copy(columns)
    print("col_filt: ", length(col_filt))
    for (i,j,type) in cons
        # filtration of up branch
        if type == 1
            for k in 1:length(col_filt)
                if col_filt[k][i] == 1 && col_filt[k][j] == 0
                    deleteat!(col_filt, k)
                end
                if col_filt[k][i] == 0 && col_filt[k][j] == 1
                    deleteat!(col_filt, k)
                end
            end

        # filtration of down branch
        else
            print("col_filt: ", length(col_filt))
            for k in 1:length(col_filt)
                if col_filt[k][i] == 1 && col_filt[k][j] == 1
                    deleteat!(col_filt, k)
                end
            end
        end
    end
    return col_filt
end
