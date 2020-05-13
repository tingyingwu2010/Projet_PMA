function pricing(pi, T, weight)
    println("-------------solve SP-----------------")
#T number of items
    price=Model(with_optimizer(Gurobi.Optimizer,OutputFlag = 0, InfUnbdInfo = 1))

    @variable(master, alpha[1:n] >= 0,  binary = false)
    @constraint(master, arc_s2, sum(y[i]*[i] = 1 for i in 1:T)
    @objective(master, max, sum(alpha))
    z = optimize!(dsp)
    return alpha, master, z
end
