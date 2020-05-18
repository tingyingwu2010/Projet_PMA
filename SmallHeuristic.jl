function SmallHeuristic(numitem, weight, alpha, column_pool, cond)
    numitem = trunc(Int, numitem)

    p = 0
    bin = 0
    # The weight of each bin
    weight_bin = zeros(1, numitem)
    # initialization of item_bin
    # every bin have a vector of the number of items which are in the bin
    item_bin = Array{Array}(undef, numitem)
    # pattern that alpha is not integer
    column = Array{Array}(undef, length(alpha))
    # Use a new bin to pack the pattern with alpha = 1
    # Stock the pattern with fractional alpha into column
    for i in 1:length(alpha)
        if (alpha[i] == 1)
            bin = bin + 1
            weight_bin[bin] = sum(weight.*column_pool[i])
            item_bin[bin] = findindex(column_pool[i], 1)
        elseif(alpha[i] != 0)
            p = p + 1
            column[p] = column_pool[i]
        end
    end
    column = column[1:p]


    weight_bin = weight_bin[1:bin]
    item_bin = item_bin[1:bin]

    # All the index of the item which is not properly packed
    S = sum(column)
    index = []
    for i in 1:numitem
        if(S[i] != 0)
            push!(index, i)
        end
    end

    # Use newbin_process to generate all the remaining items that are not properly packed
    nbbin,bin_item,weight_bin = newbin_process(numitem,weight,index,cond)

    # if we return 0 from newbin_process means there is no possible result
    if nbbin == 0
        print("no possible result")
        return 100000, []
    end

    # initialization of the item array to indicate the item in each bin generated
    item = Array{Array}(undef, (nbbin+bin))
    for j in 1 : (nbbin+bin)
        item[j] = zeros(1, numitem)
    end

    # merge bin_item(from newbin_process) and item_bin(from the bin for alpha = 1)
    for i in 1:nbbin
        push!(item_bin,bin_item[i])
    end

    # change the index of item to vector form
    for i in 1:length(item_bin)
        for j in item_bin[i]
            item[i][j] = 1
        end
    end

    # the number of bin generated
    bin = bin + nbbin

    println("bin heuristic", bin)
    # bin: the number of bin generated
    # item: the item in each bin generated
    return bin, item
end
