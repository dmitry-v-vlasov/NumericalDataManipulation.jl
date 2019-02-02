using DataFrames
using Crayons.Box
using NumericalDataManipulation.Types
using NumericalDataManipulation.Interpolation
using NumericalDataManipulation.Strings

abstract type Table end
struct NumericalTable <: Table
    argument::Vector{Float64}
    data::DataFrame
    functions::Vector{SplineFunction}
    function NumericalTable(data::DataFrame)
        @assert(!isempty(data), "The data must not be empty.")
        @assert(all(type -> isasupertype(type, Number), eltypes(data)), "All column types must by of the type Number.")
        @assert(size(data, 1) ≥ 3, "The data must have at least 3 rows.")
        @assert(size(data, 2) ≥ 2, "The data must have at least 2 columns.")

        # We assume that the first column is an argument grid.
        functions = Vector{SplineFunction}()
        X = data[:, 1]
        for j = 2:size(data, 2)
            Y = data[:, j]
            spline_function = SplineFunction(X, Y)
            push!(functions, spline_function)
        end
        numerical_table = new(X, data, functions)
        return numerical_table
    end
end
function Base.show(io::IO, table::NumericalTable)
    compact = get(io, :compact, false)

    X = table.argument
    data = table.data
    functions = table.functions
    N_L = size(data, 1)
    N_C = size(data, 2)

    sb = IOBuffer()
    for (i, func) ∈ enumerate(functions)
        println(sb, "    ⚫ $(LIGHT_GRAY_FG(supindex(i)))$func")
    end
    functions_description = String(take!(sb))
    if compact
        print(io, LIGHT_GRAY_FG("NumericalTable(data = X[$(X[1]), $(X[end])]($N_L), Y($N_L×$(N_C - 1)):\n$functions_description"))
    else
        print(io, LIGHT_GRAY_FG("NumericalTable(data = X[$(X[1]), $(X[end])]($N_L), Y($N_L×$(N_C - 1)):\n$functions_description"))
    end

end
function Base.show(io::IO, ::MIME"text/plain", table::NumericalTable)
    show(io, table)
end
