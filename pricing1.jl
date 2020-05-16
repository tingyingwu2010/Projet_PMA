function pricing1(pi, mu, T, weight, constraint)
    #T number of items
    n = length(constraint)
    price=Model(with_optimizer(Gurobi.Optimizer, GUROBI_ENV, OutputFlag = 0, InfUnbdInfo = 0))
    @variable(price, w[1:n], binary = true)
    @variable(price,y[1:T] >= 0,  binary = true)
    @constraint(price, capacity, sum(y[i]*weight[i] for i in 1:T) <= 1)
    p = 1
    for (i,j,k) in constraint
        if k == 1
            @constraint(price, w[p] - y[j] <= 0)
            @constraint(price, w[p] - y[i] <= 0)
        else
            @constraint(price, w[p] - y[j] <= 0)
            @constraint(price, w[p] - y[i] <= 0)
            @constraint(price, w[p] - y[j] - y[i] + 1 >= 0)
        end
        p +=1
    end
    @objective(price, Min, 1-sum(pi[i]*y[i] for i in 1:T)-sum(mu[i]*w[i] for i in 1:n))
    optimize!(price)

    return value.(y), objective_value.(price)
end
