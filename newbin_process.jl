function newbin_process(numitem,weight,new_index,cond)
    numitem = trunc(Int,numitem)
    index = []

    nbbin = 0

    bin_item = Array{Array}(undef, numitem)
    for j in 1 : numitem
        bin_item[j] = []
    end

    weight_bin = zeros(1, numitem)

    for (i,j,k) in cond
        if(i in new_index & j in new_index)
            if((k == 1) & !(i in index) & !(j in index))
                nbbin = nbbin + 1
                push!(bin_item[nbbin], i ,j)
                weight_bin[nbbin] = weight[i] + weight[j]
                push!(index,i,j)
            elseif((k == 1) & (i in index))
                for p in 1:nbbin
                    if(i in bin_item[p])
                        push!(bin_item[p],j)
                        weight_bin[p] = weight_bin[p] + weight_bin[j]
                        push!(index,j)
                        break
                    end
                end
            elseif(k == 1 & (j in index))
                for p in 1:nbbin
                    if(j in bin_item[p])
                        push!(bin_item[p],j)
                        weight_bin[p] = weight_bin[p] + weight_bin[i]
                        push!(index,i)
                        break
                    end
                end
            end
        end
    end

    deleteat!(new_index,index)
    for i in new_index
        Possible = false
        for j in 1:nbbin
            if(weight[i]+weight_bin[j]<1)
                for p in bin_item[j]
                    if(!((i,p,0) in cond) & !((p,i,0) in cond))
                        Possible = true
                    end
                end
            end
            if(Possible)
                weight_bin[j] = weight[i]+weight_bin[j]
                push!(bin_item[j],i)
                break
            end
        end
        if(!Possible)
            nbbin = nbbin + 1
            push!(bin_item[nbbin],i)
        end
    end

    for p in 1:nbbin
        if weight_bin[p] > 1
            print("no possible result")
            return 0, [], []
        end
    end

    bin_item = bin_item[1:nbbin]
    weight_bin = weight_bin[1:nbbin]

    return nbbin,bin_item,weight_bin
end
