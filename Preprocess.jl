function Preprocess(numitem, weight_new)
    weight = copy(weight_new)
    numitem = trunc(Int,numitem)
    num_bin_1 = 0
    num_bin_2 = 0
    pattern_bin = Array{Array{}}(undef,numitem)
    for i in 1:numitem
        pattern_bin[i] = zeros(1,numitem)
    end
    p = 0
    index = []
    for i in 2:numitem
        if weight[1] + weight[i] > 1
            num_bin_1 = num_bin_1+1
            p = p + 1
            pattern_bin[p][i] = 1
            push!(index,i)
        end
    end
    println("so huge: ",num_bin_1)

    for i in 1:(numitem-1)
        for j in (i+1):numitem
            if ((weight[i]+weight[j] == 1) && !(i in index) && !(j in index))
                num_bin_2 = num_bin_2+1
                p = p+1
                pattern_bin[p][i] = 1
                pattern_bin[p][j] = 1
                push!(index,i,j)
            end
        end
    end
    println("two in one: ",num_bin_2)

    num_bin_3 = 0
    for i in numitem:3
        for j in 1:(i-2)
            if weight[i] + weight[j] < 1 && weight[i] + weight[j] + weight[j+1] > 1 && !(i in index) && !(j in index) && !((j+1) in index)
                num_bin_3 = num_bin_3+1
                p = p+1
                pattern_bin[p][i] = 1
                pattern_bin[p][j] = 1
                push!(index,i,j)
            end
        end
    end
    println("3 too huge but 2 just ok: ", num_bin_3)

    new_weight = deleteat!(weight,sort(index))
    num_bin = num_bin_1 + num_bin_2 + num_bin_3

    numitem = numitem - num_bin_1 - 2*(num_bin_2+num_bin_3)
    pattern_bin = pattern_bin[1:p]

    if (num_bin == 0)
        println("There is no need to preprocess!!!!!!!!")
    end

    return  num_bin, pattern_bin, numitem, new_weight, index
end
