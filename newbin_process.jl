function newbin_process(numitem,weight,new_index,cond)
    # new_index contain the index of items we have not considered
    # cond contains all the branch rule at the current node
    numitem = trunc(Int,numitem)
    index = []
    # We must pack some pairs of items together
    # nbbin = number of larger item generated according to the branch rules.
    nbbin = 0
    # initialization of the array indicating the items in each bin generated
    bin_item = Array{Array}(undef, numitem)
    for j in 1 : numitem
        bin_item[j] = []
    end
    # the weight of each bin generated
    weight_bin = zeros(1, numitem)
    # consider the branch rules, some pairs of the items must be packed together
    for (i,j,k) in cond
        # if we have not considered item i and j
        if (i in new_index) && (j in new_index)
            # k = 1 means i, j must be packed together
            # k = 0 means i, j must not be packed together
            if ((k == 1) && !(i in index) & !(j in index))
                # use a new bin to pack item i and j
                nbbin = nbbin + 1
                # update the weight of the new bin
                push!(bin_item[nbbin], i ,j)
                weight_bin[nbbin] = weight[i] + weight[j]
                # indicate that we have already considered item i and j
                push!(index,i,j)
            elseif ((k == 1) && (i in index))
                # if i, j must be packed together and we have already packed item i
                for p in 1:nbbin
                    if (i in bin_item[p])
                        # so we need to pack item j in the bin where there is item i
                        push!(bin_item[p],j)
                        # update the weight of this bin
                        weight_bin[p] = weight_bin[p] + weight_bin[j]
                        push!(index,j)
                        break
                    end
                end
            elseif (k == 1 & (j in index))
                # if i, j must be packed together and we have already packed item j
                for p in 1:nbbin
                    if (j in bin_item[p])
                        # so we need to pack item i in the bin where there is item j
                        push!(bin_item[p],i)
                        # update the weight of this bin
                        weight_bin[p] = weight_bin[p] + weight_bin[i]
                        push!(index,i)
                        break
                    end
                end
            end
        end
    end
    # delete all the index of item which has already been considered
    for i in index
        deleteat!(new_index,findindex(new_index, i))
    end
    # For these remaining items, we firstly try to pack them in the existing bin
    for i in new_index
        Possible = false
        for j in 1:nbbin
            # if there is still a bin can pack this item
            if (weight[i]+weight_bin[j]<1)
                for p in bin_item[j]
                    # if there all items in this bin do not conflict with the current item
                    if (!((i,p,0) in cond) & !((p,i,0) in cond))
                        Possible = true
                    end
                end
            end
            if (Possible)
                weight_bin[j] = weight[i]+weight_bin[j]
                push!(bin_item[j],i)
                break
            end
        end
        # if it is not possible to pack the current item in existing bin
        # we should use a new bin to pack this item
        if (!Possible)
            nbbin = nbbin + 1
            # update the weight of this bin and the item in this bin
            weight_bin[nbbin] = weight[i]
            push!(bin_item[nbbin],i)
        end
    end

    # if according to some unreasonable branch rules,
    # there are bin with weight > capacity of each bin
    for p in 1:nbbin
        if weight_bin[p] > 1
            print("no possible result")
            return 0, [], []
        end
    end

    bin_item = bin_item[1:nbbin]
    weight_bin = weight_bin[1:nbbin]
    
    # nb_larger_item: the number of bin generated
    # bin_item: the items in the bin generated
    # weight_bin: the weight of the bin generated
    return nbbin,bin_item,weight_bin
end
