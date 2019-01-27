import Dierckx
import Calculus

using Formatting

struct SplineFunction <: Function
    spline::Dierckx.Spline1D
    function_object::Function
    firstderivative_object::Function
    a::Float64
    b::Float64
    y_min::Float64
    y_max::Float64
    Δx_min::Float64
    Δx_max::Float64
    Δy_min::Float64
    Δy_max::Float64

    function SplineFunction(X::Vector{Float64}, Y::Vector{Float64})
        @assert(!isempty(X), "X must non be empty.")
        @assert(!isempty(Y), "Y must non be empty.")
        @assert(length(X) > 2, "The length of X must greater than 2.")
        @assert(length(Y) > 2, "The length of Y must greater than 2.")
        @assert(issorted(X), "The values in X must be sorted in the ascending order.")
        @assert(length(X) == length(Y), "X and Y must have equal sizes.")

        a = X[1]; b = X[end]
        y_min = minimum(Y); y_max = maximum(Y)
        Δx_min = minimum(X[2:end] .- X[1:end-1]); Δx_max = maximum(X[2:end] .- X[1:end-1])
        Δy_min = minimum(abs.(Y[2:end] .- Y[1:end-1])); Δy_max = maximum(abs.(Y[2:end] .- Y[1:end-1]))
        spline = Dierckx.Spline1D(X, Y; w=ones(length(X)), k=2, bc="extrapolate", s=0.0)

        this = new(spline,
            x::Number -> Dierckx.evaluate(spline, x),
            x::Number -> Dierckx.derivative(spline, x),
            a, b,
            y_min, y_max,
            Δx_min, Δx_max, Δy_min, Δy_max)

        return this
    end

    function (sfunction::SplineFunction)(x::Number)
        return sfunction.function_object(x)
    end
end
function Base.show(io::IO, sfunction::SplineFunction)
    compact = get(io, :compact, false)

    a = sfunction.a; b = sfunction.b
    y_min = sfunction.y_min; y_max = sfunction.y_max
    Δx_min = sfunction.Δx_min; Δx_max = sfunction.Δx_max
    Δy_min = sfunction.Δy_min; Δy_max = sfunction.Δy_max
    spline = sfunction.spline
    order = spline.k

    if compact
        printfmt(io, "𝐒𝐩𝐥𝐢𝐧𝐞(𝐗 ∈ [{1:.6e}, {2:.6e}], 𝐘 ∈ [{3:.6e}, {4:.6e}]; 𝚶 = {5}; Δxᵐⁱⁿ = {6:.6e}, Δxᵐᵃˣ = {7:.6e})",
            a, b, y_min, y_max, order, Δx_min, Δx_max)
    else
        printfmt(io, "𝐒𝐩𝐥𝐢𝐧𝐞(𝐗 ∈ [{1:.6e}, {2:.6e}], 𝐘 ∈ [{3:.6e}, {4:.6e}]; 𝚶 = {5}; Δxᵐⁱⁿ = {6:.6e}, Δxᵐᵃˣ = {7:.6e}; |Δyᵐⁱⁿ| = {8:.6e}, |Δyᵐᵃˣ| = {9:.6e})",
            a, b, y_min, y_max, order, Δx_min, Δx_max, Δy_min, Δy_max)
    end
end
function Base.show(io::IO, ::MIME"text/plain", sfunction::SplineFunction)
    show(io, sfunction)
end

function ⋮(sfunction::SplineFunction, x::Number)
    return sfunction.firstderivative_object(x)
end
function d2(sfunction::SplineFunction, x::Number)
    return Calculus.derivative(sfunction.firstderivative_object, x)
end
function ∫(sfunction::SplineFunction, (a, b)::Tuple{Number, Number})
    return Dierckx.integrate(sfunction.spline, a, b)
end
function ⩪(sfunction::SplineFunction)
    return Dierckx.roots(sfunction.spline)
end
