module Manager

include("types.jl")
include("merge-tables.jl")

export MergeTwoTablesTask,
       MergeFunctionStrategyName, NAIVE_JOIN, SIGMOID_JOIN
export merge_two_tables

end  # module Manager
