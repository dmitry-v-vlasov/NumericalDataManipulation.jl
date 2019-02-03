using DataFrames
using NumericalDataManipulation.Data

function merge_table_slave_to_master_sigmoid(
    slave_table::NumericalTable,
    master_table::NumericalTable,
    slave_intervals::Vector{Tuple{Float64, Float64}},
    master_interval::Tuple{Float64, Float64},
    master_grid::DataGrid,
    slave_grid::DataGrid,
    optimal_grid::DataGrid)
    optimal_knots = optimal_grid.knots
    grid_knots = filter(knot -> master_interval[1] ≤ knot ≤ master_interval[2], optimal_knots)
    grid = DataGrid(grid_knots)
end
