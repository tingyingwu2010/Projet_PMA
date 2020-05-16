function RDWLP1(columns, T, cons)

    n = floor(Int, length(columns))
    master=Model(with_optimizer(Gurobi.Optimizer,GUROBI_ENV, OutputFlag = 0, InfUnbdInfo = 0))

    @variable(master, alpha[1:n] >= 0,  binary = false)
    l=1
    mu = Array{ConstraintRef,1}(undef, length(cons))
    for (i,j,k) in cons
        ind = []
        for p in 1:n
            if columns[p][i]==1 && columns[p][j]==1
                push!(ind, p)
            end
        end
        if k == 1
            mu[l] = @constraint(master, sum(alpha[m] for m in ind) >= 1)
        else
            mu[l] = @constraint(master, sum(alpha[m] for m in ind) <= 0)
        end
        l+=1
    end
    item_cons = @constraint(master, item_cons[i in 1:T], sum(alpha[k]*columns[k][i] for k in 1:n) ==1)
    @objective(master, Min, sum(alpha))
    optimize!(master)

    if JuMP.termination_status(master)==MOI.OPTIMAL
        #println("objective value ", objective_value.(master))
        #println("len alpha ", length(value.(alpha)))
        # println(item_cons)
        
        return value.(alpha), master, item_cons, mu, true
    else
        return [], master, item_cons, mu, false
    end

end
