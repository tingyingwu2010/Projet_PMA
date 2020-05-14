using JuMP, Gurobi

path = "C:/Users/Think/Desktop/PMA/Falkenauer/Falkenauer U/Falkenauer_u120_06.txt"
# C:\Users\Think\Desktop\PMA\Falkenauer\Falkenauer U
capacity,numitem,weight = ReadDate(path)

bin,bin_item = Initialisation(capacity,numitem,weight)
print(vec(bin_item))
bap2(capacity, numitem, weight)
