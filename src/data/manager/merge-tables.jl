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
    @info "$(MAGENTA_FG(BOLD("Argument grid of table A:")))\n$(LIGHT_GRAY_FG("$grid_a"))"
    grid_b = DataGrid(table_b.argument)
    @info "$(MAGENTA_FG(BOLD("Argument grid of table B:")))\n$(LIGHT_GRAY_FG("$grid_b"))"
    @info RED_FG(".......................")

    @info MAGENTA_FG(UNDERLINE(BOLD("[Merge Two Tables Task] - Done")))
    @info RED_FG("=======================")
end
