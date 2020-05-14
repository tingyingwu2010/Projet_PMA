function findindex(A, num)
    index = []
    for j in 1:length(A)
        if(A[j] == num)
            push!(index, j)
        end
    end
    return index
end
