using JuMP, Gurobi
const GUROBI_ENV = Gurobi.Env()
#You should change the path of instance
path = "C:/Users/Think/Desktop/PMA/Falkenauer/Falkenauer U/Falkenauer_u250_01.txt"
capacity,numitem,weight = ReadDate(path)
capacity=floor(Int, capacity)
numitem = floor(Int, numitem)
# pre processing of the data
num_bin, pattern_bin, numitem, new_weight, index_result=Preprocess(numitem, weight)

# a simple example
# capacity = 10
# weight = reshape([8,8,8,8,5,5,5,5,2,2,1,1,4,4,4,4,3,3,3,3], (20,))/10
# new_weight = copy(weight)
# numitem = 20

@time sol_opt, value_opt, node_added = bap2(capacity, numitem, new_weight)
sol_opt = result_processing(sol_opt, index_result, numitem, pattern_bin)
println("****************************")
println("bap2 finished, the optimal number of bin is ",value_opt+num_bin)
println("Total number of nodes processed is ", node_added)
# print(sum(weight))
@time sol_opt, value_opt, node_added= bap1(capacity, numitem, new_weight)
println("****************************")
println("bap1 finished, the optimal number of bin is ",value_opt+num_bin)
println("Total number of nodes processed is ", node_added)

@time orignal_formulation(weight)
