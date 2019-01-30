module CommonMath

function mean_geometric(a::Float64, b::Float64)
    return mean_geometric([a, b])
end
function mean_geometric(V::Vector{Float64})
    @assert !isempty(V)
    return prod(V)^(1 / length(V))
end

function mean_harmonic(a::Float64, b::Float64)
    return mean_harmonic([a, b])
end
function mean_harmonic(V::Vector{Float64})
    @assert !isempty(V)
    return length(V) / sum(v -> 1 / v, V)
end

export mean_geometric, mean_harmonic

end  # module CommonMath
