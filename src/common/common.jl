module Common

using Statistics

const 𝐆 = MathConstants.golden
const 𝐆⁻¹ = 𝐆 - 1
const 𝐆1⁻¹ = 2 - 𝐆
const c½ = 0.5

function scientific_notation_parts(a::Float64)
    o = floor(log10(abs(a)))
    υ = a / 10^o
    return (υ, o)
end

function mean_log10(a::Float64, b::Float64)
    υᵃ, oᵃ = scientific_notation_parts(a)
    υᵇ, oᵇ = scientific_notation_parts(b)
    return 0.5 * (υᵃ + υᵇ) * 10^(0.5 * (oᵃ + oᵇ))
end

function mean_log10_golden_lower(v¹::Float64, v²::Float64)
    a = min(v¹, v²); b = max(v¹, v²)
    υᵃ, oᵃ = scientific_notation_parts(a)
    υᵇ, oᵇ = scientific_notation_parts(b)
    return (𝐆⁻¹*υᵃ + 𝐆1⁻¹*υᵇ) * 10^(𝐆⁻¹*oᵃ + 𝐆1⁻¹*oᵇ)
end

export 𝐆, 𝐆⁻¹, 𝐆1⁻¹
export scientific_notation_parts
export mean_log10, mean_log10_golden_lower

end  # module Common
