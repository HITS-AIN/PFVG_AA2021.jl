using Distances

#----------------------------------------------------------------
function mergeTimeSeries(t1, t2, a, b)
#----------------------------------------------------------------
    R = pairwise(Cityblock(), t1, t2)

    limit = 0.5

    time_stamps = Array{Float64}(undef, 0)
    value_a     = Array{Float64}(undef, 0)
    value_b     = Array{Float64}(undef, 0)

    for row_index in 1:size(R,1)

        minval, mincol = findmin(R[row_index, :])

        if minval <= limit
            nothing
        else
            continue
        end

        minval_in_column = minimum(R[:, mincol])
        if minval <= minval_in_column
            # we have a match
            push!(time_stamps, t1[row_index])
            push!(value_a,      a[row_index])
            push!(value_b,      b[mincol])

        else
            nothing
        end

    end

    @assert(length(time_stamps) == length(value_a) == length(value_b))

    return time_stamps, value_a, value_b

end
