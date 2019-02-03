using DataFrames
using NumericalDataManipulation.Data

function merge_table_slave_to_master_sigmoid(
    slave_table::NumericalTable,
    master_table::NumericalTable,
    columns::Vector{Int},
    slave_intervals::Vector{Tuple{Float64, Float64}},
    master_interval::Tuple{Float64, Float64},
    master_grid::DataGrid,
    slave_grid::DataGrid,
    optimal_grid::DataGrid)
    @info MAGENTA_FG(BOLD("░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░"))
    @info MAGENTA_FG(BOLD("[Merge slave table to master with sigmoid functions]"))
    optimal_knots = optimal_grid.knots
    ivl₍ₘ₎ = master_interval
    grid_knots = filter(knot -> ivl₍ₘ₎[1] ≤ knot ≤ ivl₍ₘ₎[2], optimal_knots)
    grid = DataGrid(grid_knots)
    @info "$(MAGENTA_FG("Target grid: "))$grid"

    @info "$(MAGENTA_FG("Target columns: "))$(LIGHT_GRAY_FG("$columns"))"
    pwfs = Dict{Int, Function}()
    for k ∈ columns
        @info "$(MAGENTA_FG("Function for column "))$(LIGHT_GRAY_FG("$k"))"
        fₖ₍ₛ₎ = slave_table.functions[k]
        fₖ₍ₘ₎ = master_table.functions[k]
        defslₖ = Vector{Pair{Tuple{Float64, Float64}, Tuple{Function, Bool}}}()
        L = length(slave_intervals)
        for (l, ivlₗ₍ₛ₎) ∈ enumerate(slave_intervals)
            ivlₗ₋₁₍ₛ₎ = l == 1 ? nothing : slave_intervals[l - 1]

            def₋₁ = (l == 1 ? ivl₍ₘ₎[1] : ivlₗ₋₁₍ₛ₎[2], ivlₗ₍ₛ₎[1]) => (fₖ₍ₘ₎, false)
            def₀ = (ivlₗ₍ₛ₎[1], ivlₗ₍ₛ₎[2]) => (fₖ₍ₛ₎, true)
            def₊₁ = l == L ? (ivlₗ₍ₛ₎[2], ivl₍ₘ₎[2]) => (fₖ₍ₘ₎, false) : nothing

            push!(defslₖ, def₋₁)
            push!(defslₖ, def₀)
            if !isnothing(def₊₁) push!(defslₖ, def₊₁) end
        end
        defsₖ = OrderedDict{Tuple{Float64, Float64}, Tuple{Function, Bool}}(defslₖ)
        fₖ₍ₚ₎, bpₖ = piecewise_function(defsₖ; ϵᵇᵖ = grid.Δmin)
        @info "$(MAGENTA_FG("Calculated function for column "))$(LIGHT_GRAY_FG("$k"))$(MAGENTA_FG(" with breakpoints: $bpₖ"))"
        pwfs[k] = fₖ₍ₚ₎
        @info "$(MAGENTA_FG("Function for column "))$(LIGHT_GRAY_FG("$k"))$(MAGENTA_FG(" ... Done"))"
    end

    fₖ₍ₜ₎ = collect(
                if haskey(pwfs, it[1])
                    @info "$(MAGENTA_FG("Function for column "))$(LIGHT_GRAY_FG("$(it[1])"))$(MAGENTA_FG(" is replaced with a piecewise version."))"
                    pwfs[it[1]]
                else it[2] end for it ∈ enumerate(master_table.functions))
    N⁽ᶠ⁾ = length(fₖ₍ₜ₎)
    @assert(N⁽ᶠ⁾ == length(master_table.functions), "N⁽ᶠ⁾ = $N⁽ᶠ⁾, master N = $(length(master_table.functions))")

    @info MAGENTA_FG("Making a new table which is similar to the master table...")
    target_data = similar(master_table.data, 0)
    col_names = collect(string(c) for c ∈ names(target_data))
    @info "$(MAGENTA_FG("Target table column names: "))$(LIGHT_GRAY_FG("{$(join(col_names, ", "))}"))"
    @info "$(MAGENTA_FG("Calculating target table values for "))$(LIGHT_GRAY_FG("$(length(grid.knots))"))$(MAGENTA_FG(" knots"))"
    for knot ∈ grid.knots
        row = zeros(Float64, N⁽ᶠ⁾ + 1)
        row[1] = knot
        for k = 1:N⁽ᶠ⁾
            row[k + 1] = fₖ₍ₜ₎[k](knot)
        end
        push!(target_data, row)
    end
    @info "$(MAGENTA_FG("Target table values are calculated. Size: "))$(LIGHT_GRAY_FG("$(size(target_data))"))"
    target_table = NumericalTable(target_data)
    @info "$(MAGENTA_FG("Target numerical table is ready:"))\n$target_table"
    @info MAGENTA_FG(BOLD("[Merge slave table to master with sigmoid functions... Done]"))
    @info "░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░"
    return target_table
end
