function RDWLP(columns, T)
    println("-------------solve RDWLP-----------------")
    n = size(columns)
    master=Model(with_optimizer(Gurobi.Optimizer,OutputFlag = 0, InfUnbdInfo = 1))

    @variable(master, alpha[1:n] >= 0,  binary = false)
    item_cons = @constraint(master, item_cons[i in 1:T], sum(alpha[i]*pattern[i] for pattern in columns) ==1)
    @objective(master, min, sum(alpha))
    optimize!(master)
    return alpha, master, item_cons
end
