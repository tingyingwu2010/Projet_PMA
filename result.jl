function result_processing(result_pattern, index)
    # result_pattern: the result of each bin after branch and price
    p = 0
    for i in index
        for pattern in result_pattern
            insert!(pattern, i+p, 0)
        end
        p = p + 1
    end

    return result_pattern
