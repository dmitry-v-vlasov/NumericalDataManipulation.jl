using Statistics

using NumericalDataManipulation.Common

struct DataGrid
    knots::Vector{Float64}
    Δmin::Float64
    Δmax::Float64
    Δmean::Float64
    Δ𝐆::Float64
    Δknots::Vector{Float64}
    function DataGrid(knots::Vector{Float64})
        @assert(!isempty(knots), "Data grid cannot be empty.")
        Δknots, Δmin, Δmax, Δmean, Δ𝐆 = give_Δknots(knots)
        grid = new(knots, Δmin, Δmax, Δmean, Δ𝐆, Δknots)
    end
    function DataGrid(range::StepRange)
        @assert(issorted(range), "The range must be sorted in an ascending order.")
        knots = collect(range)
        Δknots, Δmin, Δmax, Δmean, Δ𝐆 = give_Δknots(knots)
        grid = new(knots, Δmin, Δmax, Δmean, Δ𝐆, Δknots)
    end
end

function give_Δknots(knots::Vector{Float64})
    @assert(length(knots) ≥ 3, "Grid must contain at least 3 knots.")
    @assert(issorted(knots), "The knots must be sorted in an ascending order.")
    Δknots = knots[2:end] - knots[1:end-1]
    Δmin = minimum(Δknots)
    Δmax = maximum(Δknots)
    Δmean = mean(Δknots)
    Δ𝐆 = mean_log10_golden_lower(Δmin, Δmax)
    return Δknots, Δmin, Δmax, Δmean, Δ𝐆
end
