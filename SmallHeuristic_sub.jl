function SmallHeuristic_sub(num, numitem, weight, cond)
    #num: number of items non-packed
    #numitem: number of all items = 120/250/500/1000
    nbbin,item_bin,weight_bin = newbin_process(num,weight,cond)

    nbbin = trunc(Int,nbbin)
    # number of items
    i = 1
    # number of bins
    bin = nbbin
    # Used capacity in bin
    cap_used = zeros(1, nbbin)
    # Packed in bin
    bin_item = Array{Array}(undef, nbbin)
    for j in 1 : nbbin
        bin_item[j] = []
    end

    # There are still items to be packed
    while (i <= nbbin)
        Possible = False
        for j in 1 : nbbin
            if(cap_used[j] + weight_bin[i] < 1)
                for p in bin_item[j]
                    for q in item_bin[i]
                        if(bin_item[j] == [])
                            Possible = true
                        elseif(!((p,q,0) in cond) & !((q,p,0) in cond))
                            Possible = true
                        end
                    end
                end
                if(possible)
                    cap_used[j] = cap_used[j] + weight_bin[i]
                    for r in item_bin[i]
                        bin_item[j] = push!(bin_item[j],r)
                    end
                    i = i + 1
                    break
                end
            end
        end
    end

    for j in 1 : nbbin
        if(cap_used[j]==0)
            bin = j - 1
            break
        end
    end
    bin_item = bin_item[1:bin]

    item = Array{Array}(undef, bin)
    for j in 1 : bin
        item[j] = zeros(1, numitem)
    end

    for i in 1:length(bin_item)
        for j in bin_item[i]
            item[i][j] = 1
        end
    end

    return bin, item
end
