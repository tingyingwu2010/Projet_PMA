function master(columns, T)
    println("-------------solve RDWLP-----------------")
    n = size(columns)
    master=Model(with_optimizer(Gurobi.Optimizer,OutputFlag = 0, InfUnbdInfo = 1))

    @variable(master, alpha[1:n] >= 0,  binary = false)
    for i in 1:T
        @constraint(master, arc_s2, sum(alpha[i]*pattern[i] = 1 for pattern in columns)
        end
    @objective(master, min, sum(alpha))
    z = optimize!(dsp)
    return alpha, master, z
end
