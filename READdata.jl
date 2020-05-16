
using DelimitedFiles


function ReadDate(path)

    Falkenauer = readdlm(path)
    capacity = Falkenauer[2]
    numitem = Falkenauer[1]
    weight = Falkenauer[3:length(Falkenauer)]
    weight = weight/capacity
    weight = sort(weight)
    return capacity,numitem,weight

end
