function pricing(pi, T, weight)
    println("-------------solve SP-----------------")
#T number of items
    price=Model(with_optimizer(Gurobi.Optimizer,OutputFlag = 0, InfUnbdInfo = 1))

    @variable(price,y[1:T] >= 0,  binary = true)
    @constraint(price, capacity, sum(y[i]*weight[i] for i in 1:T) <= 1)
    @objective(price, min, 1-sum(pi[i]*y[i] for i in 1:T))
    optimize!(price)
    return values.(y), objective_value.(SP)
end
