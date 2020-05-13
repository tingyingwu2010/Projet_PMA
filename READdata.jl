
using DelimitedFiles


function ReadDate(path)

    Falkenauer = readdlm(path)
    capacity = Falkenauer[2]
    numbin = Falkenauer[1]
    weight = Falkenauer[3:122]

    return capacity,numbin,weight

end
