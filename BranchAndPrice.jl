using JuMP, Gurobi

function bap(capacity,numitem,weight)
    #initialization
    #lambda=Array{VariableRef}(undef,9)
    epsilon = 0.0001
    pattern_pool=Array{Array{Int64,1},1}(undef,0)
    # start with the columns that each item in a bin
    for i in 1:numitem
        a =  zeros(Int64, 1, numitem)
        a[i] = 1
        push!(pattern_pool, a)
    end
    uppper = Inf
    lower = -Inf
    node_tree=[]
    while true
        #column = node_tree[-1]
        sp_obj = -100
        while true
            alpha, master, cons= master(pattern_pool, numitem)
            lower = JuMP.objective_value.(master)
            d = JuMP.dual.(cons)
            y, sp_obj = pricing(d, numitem, weight)
            if sp_obj<-epsilon    #or dual > primal??? heuristic for master?
                break
            end
            push!(pattern_pool, y)
        end

        #detection of solutioon integrality and selection the fractional patterns
        fraction_pattern = Array{Array{Int64,1},1}(undef,0)
        flag = true
        for a in size(alpha)
            if alpha[a]<1 && alpha[a]>0
                push!(fraction_pattern, pattern_pool[a])
                flag = false
            end
        end
        #update upperbound
        if flag
            alpha_opt = alpha
            if lower>upper
                uppper = lower
            end
        end

        if uppper>lower && !flag               # solution infeasible??
            i,j = search_fraction(alpha, numitem)

        end

    end

end

function search_fraction(fraction_pattern, numitem)
    for i in numitem:-1:1
        for j in numitem:-1:1
            w=0
            if fraction_pattern[a][i]==1 && fraction_pattern[a][j]==1
                w = w + alpha[a]
            end
            if w<1 && w>0
                return i, j
            end
        end
    end
end
