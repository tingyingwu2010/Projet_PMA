function orignal_formulation(weight)
    nb_item = length(weight)
    bp=Model(with_optimizer(Gurobi.Optimizer,GUROBI_ENV, OutputFlag = 1, InfUnbdInfo = 0))
    x=Array{Array{VariableRef,1},1}(undef,nb_item)
    for m in 1:nb_item
        x[m]=Array{VariableRef,1}(undef,nb_item)
    end
    for i in 1:nb_item
        for j in 1:nb_item
            x[i][j] = @variable(bp, binary = true)
        end
    end
    @variable(bp, u[1:nb_item],  binary = true)
    for i in 1:nb_item
        @constraint(bp, sum(x[i][k] for k in 1:nb_item) ==1)
    end

    for k in 1:nb_item
        @constraint(bp, sum(weight[i]*x[i][k] for i in 1:nb_item)- u[k] <=0)
    end
    # set a limit processing time to each node (300s)
    MOI.set(bp, MOI.RawParameter("TimeLimit"), 300.0);
    @objective(bp, Min, sum(u))
    optimize!(bp)
    print(objective_value(bp))
end
