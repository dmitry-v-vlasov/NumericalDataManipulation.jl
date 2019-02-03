using NumericalDataManipulation.Data.Storage
using NumericalDataManipulation.Data.Manipulation

using Crayons.Box

function merge_two_tables(task::MergeTwoTablesTask)
    @info RED_FG("=======================")
    @info MAGENTA_FG(UNDERLINE(BOLD("[Merge Two Tables Task]")))

    @info RED_FG("-----------------------")
    table_a = load_numerical_table(task.file_a; has_title = task.skip_title_a)
    @info "$(MAGENTA_FG(BOLD("Loaded table A:")))\n$table_a"
    table_b = load_numerical_table(task.file_b; has_title = task.skip_title_b)
    @info "$(MAGENTA_FG(BOLD("Loaded table B:")))\n$table_b"
    @info RED_FG("-----------------------")

    @info RED_FG(".......................")
    grid_a = DataGrid(table_a.argument)
    @info "$(MAGENTA_FG(BOLD("Argument grid of table A:")))\n$grid_a"
    grid_b = DataGrid(table_b.argument)
    @info "$(MAGENTA_FG(BOLD("Argument grid of table B:")))\n$grid_b"

    @info RED_FG("⋯ ⋯ ⋯ ⋯ ⋯")
    tail = task.grid_merge_parameters.tail_knots
    ϵʳᵉˡ = task.grid_merge_parameters.ϵʳᵉˡ
    meanΔ = task.grid_merge_parameters.meanΔ
    merged_grid_result = merge_grids(grid_a, grid_b; ntail = tail, ϵʳᵉˡ = ϵʳᵉˡ, meanΔ = meanΔ)
    @info "$(MAGENTA_FG(BOLD("Merged grid A + B:")))\n$merged_grid_result"
    @info RED_FG("⋯ ⋯ ⋯ ⋯ ⋯")
    @info "$(LIGHT_MAGENTA_FG(BOLD("The master grid is: ")))$(LIGHT_GRAY_FG(task.master == :a ? "A" : "B"))"
    master_grid = task.master == :a ? grid_a : grid_b
    slave_grid =  task.master == :a ? grid_b : grid_a
    merged_grid = merged_grid_result
    @info RED_FG(".......................")

    # ----
    master_table = task.master == :a ? table_a : table_b
    slave_table =  task.master == :a ? table_b : table_a
    target_table = merge_table_slave_to_master_sigmoid(
                        slave_table, master_table,
                        task.columns,
                        map(ivl -> (ivl[1], ivl[2]), task.slave_intervals),
                        (task.master_interval[1], task.master_interval[2]),
                        master_grid, slave_grid, merged_grid)
    # ----

    @info MAGENTA_FG(UNDERLINE(BOLD("[Merge Two Tables Task] - Done")))
    @info RED_FG("=======================")
end
