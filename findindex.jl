function findindex(A, num)
<<<<<<< HEAD:findindex.jl
    # find the index in array A correspond to num
=======
    # find the index in array A correspond to number
>>>>>>> be79188bf518ec697e10719c84f6b0e716003e78:findall.jl
    index = []
    for j in 1:length(A)
        if(A[j] == num)
            push!(index, j)
        end
    end
    return index
end
