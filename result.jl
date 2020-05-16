function result_processing(result_pattern, result_index, numitem, pattern_bin)
    # result_pattern: the result of each bin after branch and price

    for k in 1:length(result_pattern)
        result_pattern[k] = floor.(Int,result_pattern[k])
        result_pattern[k] = reshape(result_pattern[k], (numitem,))
    end

    for i in sort(result_index)
        for k in 1:length(result_pattern)
            insert!(result_pattern[k], i, 0)
        end
    end



    return vcat(pattern_bin,result_pattern)
end
