using Statistics
using Formatting
using Crayons.Box
using NumericalDataManipulation.Common
using NumericalDataManipulation.CommonMath

struct DataGrid
    knots::Vector{Float64}
    Δmin::Float64
    Δmax::Float64
    Δmean::Float64
    Δlog10::Float64
    Δ𝐆::Float64
    Δknots::Vector{Float64}
    function DataGrid(knots::Vector{Float64})
        @assert(!isempty(knots), "Data grid cannot be empty.")
        Δknots, Δmin, Δmax, Δmean, Δlog10, Δ𝐆 = give_Δknots(knots)
        grid = new(knots, Δmin, Δmax, Δmean, Δlog10, Δ𝐆, Δknots)
    end
    function DataGrid(range::StepRange)
        @assert(issorted(range), "The range must be sorted in an ascending order.")
        knots = collect(range)
        Δknots, Δmin, Δmax, Δmean, Δlog10, Δ𝐆 = give_Δknots(knots)
        grid = new(knots, Δmin, Δmax, Δmean, Δlog10, Δ𝐆, Δknots)
    end
end
function Base.show(io::IO, grid::DataGrid)
    compact = get(io, :compact, false)

    knots = grid.knots; a = knots[1]; b = knots[end]; N = length(knots)
    Δmin = grid.Δmin
    Δmax = grid.Δmax
    Δmean = grid.Δmean
    Δlog10 = grid.Δlog10
    Δ𝐆 = grid.Δ𝐆
    Δknots = grid.Δknots

    if compact
        printfmt(io, "$(LIGHT_GRAY_FG("DataGrid([{1:.3e}, {2:.3e}]($N), Δlog10 = {3:.6e}, Δmin = {4:.6e}, Δmax = {5:.3e}, Δmean = {6:.5e}, Δ𝐆 = {7:.6e})"))",
            a, b, Δlog10, Δmin, Δmax, Δmean, Δ𝐆)
    else
        printfmt(io, "$(LIGHT_GRAY_FG("DataGrid([{1:.3e}, {2:.3e}]($N), Δlog10 = {3:.6e}, Δmin = {4:.6e}, Δmax = {5:.3e}, Δmean = {6:.5e}, Δ𝐆 = {7:.6e})"))",
            a, b, Δlog10, Δmin, Δmax, Δmean, Δ𝐆)
    end

end
function Base.show(io::IO, ::MIME"text/plain", grid::DataGrid)
    show(io, grid)
end

function give_Δknots(knots::Vector{Float64})
    @assert(length(knots) ≥ 3, "Grid must contain at least 3 knots.")
    @assert(issorted(knots), "The knots must be sorted in an ascending order.")
    Δknots = knots[2:end] - knots[1:end-1]
    Δmin = minimum(Δknots)
    Δmax = maximum(Δknots)
    Δmean = mean(Δknots)
    Δ𝐆 = mean_log10_golden_lower(Δmin, Δmax)
    Δlog10 = mean_log10(Δmin, Δmax)
    return Δknots, Δmin, Δmax, Δmean, Δlog10, Δ𝐆
end
