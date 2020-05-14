function newbin_process(numitem,weight,cond)
    numitem = trunc(Int,numitem)
    index = []

    nbbin = 0

    bin_item = Array{Array}(undef, numitem)
    for j in 1 : numitem
        bin_item[j] = []
    end

    weight_bin = zeros(1, numitem)

    for (i,j,k) in condition
        if((k == 1) & !(i in index) & !(j in index))
            push!(bin_item[nbbin], i ,j)
            weight_bin[nbbin] = weight[i] + weight[j]
            push!(index,i,j)
            nbbin = nbbin + 1
        elseif((k == 1) & (i in index))
            for p in 1:nbbin
                if(i in bin_item[p])
                    push!(bin_item[p],j)
                    weight_bin[p] = weight_bin[p] + weight_bin[j]
                    push!(index,j)
                end
            end
        elseif(k == 1 & (j in index))
            for p in 1:nbbin
                if(j in bin_item[p])
                    push!(bin_item[p],j)
                    weight_bin[p] = weight_bin[p] + weight_bin[i]
                    push!(index,i)
                end
            end
        end
    end

    for p in 1:nbbin
        if weight_item[p] > 1
            print("no possible result")
            return 0, []
        end
    end

    bin_item = bin_item[1:nbbin]
    weight_bin = weight_bin[1:nbbin]
    
    return nbbin,bin_item,weight_bin
end
