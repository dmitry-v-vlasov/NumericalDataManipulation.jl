module CommonMath

const ∞ = Inf
const ∞⁻ = -Inf
const 𝐆 = MathConstants.golden
const 𝐆⁻¹ = 𝐆 - 1
const 𝐆1⁻¹ = 2 - 𝐆
const c½ = 0.5

function mean_geometric(a::Float64, b::Float64; use_abs::Bool = false)
    prod = a * b
    return (use_abs ? sign(prod) : 1) * √(use_abs ? abs(prod) : prod)
end
function mean_geometric(V::Vector{Float64}; use_abs::Bool = false)
    @assert !isempty(V)
    prodV = prod(V)
    σ = use_abs ? sign(prodV) : 1
    return (use_abs ? abs(prodV) : prodV)^(1 / length(V))
end

function mean_harmonic(a::Float64, b::Float64)
    return 2 / (1 / a + 1 / b)
end
function mean_harmonic(V::Vector{Float64})
    @assert !isempty(V)
    return length(V) / sum(v -> 1 / v, V)
end

function scientific_notation_parts(a::Float64)
    o = floor(log10(abs(a)))
    υ = a / 10^o
    return (υ, o)
end

function mean_log10(a::Float64, b::Float64)
    υᵃ, oᵃ = scientific_notation_parts(a)
    υᵇ, oᵇ = scientific_notation_parts(b)
    return mean_geometric(υᵃ, υᵇ; use_abs = false) * 10^(mean_geometric(oᵃ, oᵇ; use_abs = true))
    return mean_geometric(υᵃ, υᵇ; use_abs = false) * 10^(mean_geometric(oᵃ, oᵇ; use_abs = true))
end
function mean_log10(V::Vector{Float64})
    @assert !isempty(V)
    vᵐⁱⁿ = minimum(V); vᵐᵃˣ = maximum(V)
    @assert vᵐⁱⁿ ≠ 0
    return mean_log10(vᵐⁱⁿ, vᵐᵃˣ)
end

function mean_log10_golden_lower(v¹::Float64, v²::Float64)
    a = min(v¹, v²); b = max(v¹, v²)
    υᵃ, oᵃ = scientific_notation_parts(a)
    υᵇ, oᵇ = scientific_notation_parts(b)
    return (𝐆⁻¹*υᵃ + 𝐆1⁻¹*υᵇ) * 10^(𝐆⁻¹*oᵃ + 𝐆1⁻¹*oᵇ)
end
function mean_log10_golden_lower(V::Vector{Float64})
    @assert !isempty(V)
    vᵐⁱⁿ = minimum(V); vᵐᵃˣ = maximum(V)
    @assert vᵐⁱⁿ ≠ 0
    return mean_log10_golden_lower(vᵐⁱⁿ, vᵐᵃˣ)
end

export ∞, ∞⁻
export 𝐆, 𝐆⁻¹, 𝐆1⁻¹
export mean_geometric, mean_harmonic
export scientific_notation_parts
export mean_log10, mean_log10_golden_lower

end  # module CommonMath
