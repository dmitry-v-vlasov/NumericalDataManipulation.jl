using NumericalDataManipulation.Data.Storage

using Crayons.Box

function merge_two_tables(task::MergeTwoTablesTask)
    @info MAGENTA_FG(UNDERLINE(BOLD("[Merge Two Tables Task]")))
    table_a = load_numerical_table(task.file_a; has_title = task.skip_title_a)
    @info "$(MAGENTA_FG(BOLD("Loaded table A:")))\n$(LIGHT_GRAY_FG("$table_a"))"
    table_b = load_numerical_table(task.file_b; has_title = task.skip_title_b)
    @info "$(MAGENTA_FG(BOLD("Loaded table B:")))\n$(LIGHT_GRAY_FG("$table_b"))"
    @info MAGENTA_FG(UNDERLINE(BOLD("[Merge Two Tables Task] - Done")))
end
