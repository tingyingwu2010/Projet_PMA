function SmallHeuristic(numitem, weight, alpha, column_pool, cond)
    numitem = trunc(Int, numitem)

    p = 1
    bin = 1
    # The weight of each bin
    weight_bin = zeros(1, numitem)
    # initialization of item_bin
    # every bin have a vector of the number of items which are in the bin
    item_bin = Array{Array}(undef, numitem)
    # pattern that alpha is not integer
    column = Array{Array}(undef, numitem)

    for i in 1:length(alpha)
        if(alpha[i] == 1)
            weight_bin[bin] = sum(weight.*column_pool[i])
            item_bin[bin] = findindex(column_pool[i], 1)
            bin = bin + 1
        elseif(alpha[i] != 0)
            column[p] = column_pool[i]
            p = p + 1
        end
    end

    weight_bin = weight_bin[1:bin]
    item_bin = item_bin[1:bin]

    # All the index of the item which is not properly placed
    S = sum(column)
    index = []
    for i in 1:numitem
        if(S[i] != 0)
            push!(index, i)
        end
    end

    # We can try to find if there is a bin can pack these remaining items
    #delete = []
    #for i in 1:length(index)
    #    for j in 1:bin
    #        if(weight[index[i]]+weight_bin[j]<1)
    #            for p in item_bin[j]
    #                if(!(index[i],p,0) in cond & !(p,index[i],0) in cond)
    #                    push!(delete, i)
    #                    push!(item_bin[j], index[i])
    #                    weight_bin[j] = weight[index[i]]+weight_bin[j]
    #                end
    #            end
    #        end
    #    end
    #end
    #deleteat!(index,delete)

    nbbin,bin_item,weight_bin = newbin_process(numitem,weight,index,cond)

    item = Array{Array}(undef, (nbbin+bin))
    for j in 1 : (nbbin+bin)
        item[j] = zeros(1, numitem)
    end

    for i in 1:nbbin
        push!(item_bin,bin_item[i])
    end

    for i in 1:length(item_bin)
        for j in 1:length(item_bin[i])
            item[i][j] = 1
        end
    end

    bin = bin + nbbin


    return bin, item
end
