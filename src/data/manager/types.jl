using NumericalDataManipulation.Data.Storage

@enum MergeFunctionStrategyName NAIVE_JOIN SIGMOID_JOIN

struct GridMergeParameters
    tail_knots::Int
    ϵʳᵉˡ::Float64
    meanΔ::Function
end

abstract type Task end
struct MergeTwoTablesTask <: Task
    file_a::FileResource
    file_b::FileResource
    master::Symbol
    columns::Vector{Int}
    master_interval::Tuple{Float64, Float64, Symbol}
    slave_intervals::Vector{Tuple{Float64, Float64, Symbol}}
    merge_function_strategy::MergeFunctionStrategyName
    grid_merge_parameters::GridMergeParameters
    skip_title_a::Bool
    skip_title_b::Bool
    function MergeTwoTablesTask(
        path_a::AbstractString, path_b::AbstractString, master::Symbol,
        columns::Vector{Int},
        master_interval::Tuple{Float64, Float64, Symbol},
        slave_intervals::Vector{Tuple{Float64, Float64, Symbol}},
        merge_function_strategy::MergeFunctionStrategyName,
        grid_merge_parameters::GridMergeParameters,
        skip_title_a::Bool, skip_title_b::Bool)
        return new(FileResource(path_a), FileResource(path_b), master,
            columns, master_interval, slave_intervals,
            merge_function_strategy, grid_merge_parameters,
            skip_title_a, skip_title_b)
    end
end
