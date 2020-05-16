using JuMP, Gurobi

const GUROBI_ENV = Gurobi.Env()
path = "C:/Users/Think/Desktop/PMA/Falkenauer/Falkenauer U/Falkenauer_u120_01.txt"
# C:\Users\Think\Desktop\PMA\Falkenauer\Falkenauer U
capacity,numitem,weight = ReadDate(path)
capacity=floor(Int, capacity)
numitem = floor(Int, numitem)

num_bin, pattern_bin, numitem, new_weight, index_result=Preprocess(numitem, weight)

capacity = 10
weight = reshape([8,8,8,8,5,5,5,5,2,2,1,1,4,4,4,4,3,3,3,3], (20,))/10
new_weight = copy(weight)
numitem = 20
# bin,bin_item = Initialisation(numitem,new_weight)

sol_opt, value_opt = bap2(capacity, numitem, new_weight)
println(value_opt+num_bin)
print(sum(weight))

sol_opt = result_processing(sol_opt, index_result, numitem, pattern_bin)
print(size(sol_opt))
orignal_formulation(weight)

sol_opt, value_opt = bap1(capacity, numitem, new_weight)
