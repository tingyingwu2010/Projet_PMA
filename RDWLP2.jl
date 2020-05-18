function RDWLP(columns, T)
    #println("-------------solve RDWLP-----------------")
    n = floor(Int, length(columns))

    master=Model(with_optimizer(Gurobi.Optimizer,GUROBI_ENV, OutputFlag = 0, InfUnbdInfo = 0))
    #println("number columns", n)
    @variable(master, alpha[1:n] >= 0,  binary = false)
    item_cons = @constraint(master, item_cons[i in 1:T], sum(alpha[k]*columns[k][i] for k in 1:n) ==1)
    @objective(master, Min, sum(alpha))
    optimize!(master)

    if JuMP.termination_status(master)==MOI.OPTIMAL
        #println("objective value ", objective_value.(master))
        #println("len alpha ", length(value.(alpha)))
        # println(item_cons)
        return value.(alpha), master, item_cons, true
    else
        return [], master, item_cons, false
    end

end
