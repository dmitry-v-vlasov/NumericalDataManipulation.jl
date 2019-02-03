module Common

using Statistics
using NumericalDataManipulation.CommonMath

function relative_Δ(a¹::Float64, a²::Float64, b¹::Float64, b²::Float64)
    return (a² - a¹) / (b² - b¹)
end

function relative_Δ(a¹::Float64, a²::Float64, b::Float64)
    return (a² - a¹) / b
end

function relative(a::Float64, b::Float64)
    @debug "Relation: a=$a, b=$b, rel=$(a / b)"
    return a / b
end

function issmall(a::Float64, b::Float64; ϵʳᵉˡ=1e-2::Float64)
    return relative(a, b) < ϵʳᵉˡ
end

function Δknot_values(knots::Vector{Float64})
    @assert(!isempty(knots), "An empty knot vector is given.")
    @assert(issorted(knots), "The knot vector must be sorted in an ascending order.")
    @assert(length(knots) ≥ 2, "The knot vector must have 2 knots at least.")
    Δknots = knots[2:end] - knots[1:end-1]
    return Δknots
end

function nonzero(V::Vector{Float64})
    return filter(v -> v ≠ 0.0, V)
end

function finity(a::Float64, b::Float64, c::Float64)
    return (finity(a), finity(b), finity(c))
end
function finity(triple::Tuple{Float64, Float64, Float64})
    return map(number -> finity(number), triple)
end
function finity(v::Vector{Float64})
    return map(number -> finity(number), v)
end

function finity(number::Float64)
    if number == ∞⁻
        return ∞⁻
    elseif number == ∞
        return ∞
    else
        return 1
    end
end

function relfinity(a::Float64, b::Float64, c::Float64; D::Float64 = 1.0, ϵʳᵉˡ::Float64=1e-2)
    return (relfinity(a; D = D, ϵʳᵉˡ = ϵʳᵉˡ),
        relfinity(b; D = D, ϵʳᵉˡ = ϵʳᵉˡ),
        relfinity(c; D = D, ϵʳᵉˡ = ϵʳᵉˡ))
end
function relfinity(triple::Tuple{Float64, Float64, Float64}; D::Float64 = 1.0, ϵʳᵉˡ::Float64=1e-2)
    return map(number -> relfinity(number; D = D, ϵʳᵉˡ = ϵʳᵉˡ), triple)
end
function relfinity(vector::Vector{Float64}; D::Float64 = 1.0, ϵʳᵉˡ::Float64=1e-2)
    return map(number -> relfinity(number; D = D, ϵʳᵉˡ = ϵʳᵉˡ), vector)
end
function relfinity(number::Float64; D::Float64 = 1.0, ϵʳᵉˡ::Float64=1e-2)
    if number == ∞⁻
        return ∞⁻
    elseif number == ∞
        return ∞
    else
        if issmall(number, D; ϵʳᵉˡ = ϵʳᵉˡ)
            return 0
        else
            return 1
        end
    end
end

function sum_until(upper_bound_reached::Function, V::Vector{Float64})
    Σ = 0.0; iᵉ = 0
    for (i, v) ∈ enumerate(V)
        if upper_bound_reached(v, Σ + v)
            break
        end
        if v == ∞ || v == ∞⁻ || v == NaN
            @warn "v = $v with index $i; vector: $V"
        end
        Σ += v; iᵉ = i
    end
    return (Σ, iᵉ)
end

flatten(arr::Array) = mapreduce(x -> isa(x, Array) ? flatten(x) : x, append!, arr,init=[])
flatten(arr::Tuple) = mapreduce(x -> isa(x, Tuple) ? flatten(x) : x, append!, arr,init=[])
flatten(arr::Base.KeySet) = mapreduce(x -> isa(x, Base.KeySet) ? flatten(x) : x, append!, arr,init=[])

export relative_Δ, relative, issmall
export Δknot_values
export nonzero, finity, relfinity
export sum_until
export flatten

end  # module Common
