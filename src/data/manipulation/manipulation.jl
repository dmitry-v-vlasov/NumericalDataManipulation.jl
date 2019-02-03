module Manipulation

include("types.jl")
include("arrays.jl")
include("tables.jl")
include("piecewise.jl")


export DataGrid
export merge_grids, merge_knots
export unique_knots
export piecewise_function
export merge_table_slave_to_master_sigmoid

end  # module Manipulation
