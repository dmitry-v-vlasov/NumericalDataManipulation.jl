using NumericalDataManipulation.Data.Storage

abstract type Task end

struct MergeTwoTablesTask <: Task
    file_a::FileResource
    file_b::FileResource
    master::Symbol
    columns::Vector{Int}
    master_interval::Tuple{Float64, Float64, Symbol}
    slave_intervals::Vector{Tuple{Float64, Float64, Symbol}}
    skip_title_a::Bool
    skip_title_b::Bool
    function MergeTwoTablesTask(
        path_a::AbstractString, path_b::AbstractString, master::Symbol,
        columns::Vector{Int},
        master_interval::Tuple{Float64, Float64, Symbol},
        slave_intervals::Vector{Tuple{Float64, Float64, Symbol}},
        skip_title_a::Bool, skip_title_b::Bool)
        return new(FileResource(path_a), FileResource(path_b), master,
            columns, master_interval, slave_intervals,
            skip_title_a, skip_title_b)
    end
end
