
using DelimitedFiles


function ReadDate(path)

    Falkenauer = readdlm(path)
    # the capacity of each bin
    capacity = Falkenauer[2]
    # the number of item
    numitem = Falkenauer[1]
    # the weight of each item
    weight = Falkenauer[3:length(Falkenauer)]
    # normalize the weight
    weight = weight/capacity
    # sort the weight array
    weight = sort(weight)
    
    return capacity,numitem,weight

end
