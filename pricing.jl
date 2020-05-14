function pricing(pi, T, weight, constraint)
    println("-------------solve SP-----------------")
#T number of items
    price=Model(with_optimizer(Gurobi.Optimizer,OutputFlag = 0, InfUnbdInfo = 1))

    @variable(price,y[1:T] >= 0,  binary = true)
    @constraint(price, capacity, sum(y[i]*weight[i] for i in 1:T) == 1)
    for (i,j,k) in constraint
        if k == 1
            @constraint(price, y[i] - y[j] == 0)
        else
            @constraint(price, y[i] + y[j] <= 1)
        end
    end
    @objective(price, Min, 1-sum(pi[i]*y[i] for i in 1:T))
    optimize!(price)
    println("objetive value: ", objective_value.(price))
    # println("new colomn: ", value.(y))
    return value.(y), objective_value.(price)
end
