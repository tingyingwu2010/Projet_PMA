function findindex(A, num)
    # find the index in array A correspond to number
    index = []
    for j in 1:length(A)
        if(A[j] == num)
            push!(index, j)
        end
    end
    return index
end
