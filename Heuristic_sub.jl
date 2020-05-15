function Heuristic_sub(capacity, numitem, weight, pi, cond)
    weight = weight*capacity
    numitem = trunc(Int,numitem)

    # the number of item
    N = numitem;

    # the number of row represent the number of item available
    # the number of column represent the capacity available
    V = Array{Array}(undef, numitem+1)
    for i in 1:numitem
        V = zeros(Int64, 1, capacity+1)
    end

    Bin_item = Array{Array{Array}}(undef, numitem+1)
    for i in 1:numitem+1
        Bin_item[i] = Array{Array{}}(undef, capacity+1)
    end
    for i in 1:numitem+1
        for j in 1:capacity+1
            Bin_item[i][j] = []
        end
    end


    # fix the value of the first row and first column to 0
    for col in 0:capacity+1)
        V[1][col] = 0;
    end
    for row in 0:numitem+1)
        V[row][1] = 0;
    end

    # consider every item
    for item in 2:numitem+1
        for w in 2:capacity+1
            if (weight[item-1] <= w)
                # pack the current item in the bin
                # if the value of the weight without current item + the value of current item > current value
                # we put the current item in the bin
                if (pi[item-1]+V[item-1][w-weight[item-1]] >= V[item-1][w])
                    push!(Bin_item[i][j],item-1)
                end
                # so the value of the bin becomes the max of these 2 possibility
                V[item][w]=Max(pi[item-1]+V[item-1][w-weight[item-1]], V[item-1][w]);
            else
                # Don't pack the current item in the bin, so we keep the number
                V[item][w]=V[item-1][w];
            end
        end
    end

    row_num = findmax(V)[2]
    col_num = findmax(findmax(V)[1])

    items = Bin_item[row_num][col_num]

    objective = (findmax(findmax(V)[1])[1])/capacity
    sol = zeros(1, numitem)

    for j in items
        sol[j] = 1
    end


    return sol, objective;
