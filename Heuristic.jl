function Initialisation(numitem, weight)
    # A = Array{Array}(undef, 9)
    numitem = trunc(Int,numitem)
    # number of items
    i = 1
    # number of bins
    bin = 0
    # Used capacity in bin
    cap_used = zeros(1, numitem)
    # Packed in bin
    bin_item = Array{Array}(undef, numitem)
    for j in 1 : numitem
        bin_item[j] = zeros(1, numitem)
    end
    # There are still items to be packed
    while (i <= numitem)
        for j in 1 : numitem
            if(cap_used[j] + weight[i] < 1)
                cap_used[j] = cap_used[j] + weight[i]
                bin_item[j][i] = 1
                i = i + 1
                break
            end
        end
    end
    for j in 1 : numitem
        if(sum(bin_item[j])==0.0)
            bin = j - 1
            break
        end
    end
    bin_item = bin_item[1:bin]

    return bin, bin_item
end
