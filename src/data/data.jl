module Data

include("types.jl")
export NumericalTable

include("storage/storage.jl")
export FileResource
export exists
export load_numerical_table

end  # module
