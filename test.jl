using JuMP, Gurobi

s = [1/6, 2/6, 2/6, 3/6, 4/6]
colums = [[1,0,0,0,0], [0,1,0,0,0], [0,0,1,0,0], [0,0,0,1,0], [0,0,0,0,1]]
nb=5

while true
    println("-------------------------")
    alpha, master, cons= RDWLP(colums, nb)
    println("alpha")
    println(alpha)
    #update upperbound
    d = JuMP.dual.(cons)
    println("pi")
    println(d)
    y, sp_obj = pricing(d, nb, s, [])
    #update lower bound
    lower = sum(d)+sp_obj
    println("dual: ", lower)

    println("y")
    println(y)
    if sp_obj>-0.001    #or dual > primal??? heuristic for master?
        break
    end
    push!(colums, y)
end
