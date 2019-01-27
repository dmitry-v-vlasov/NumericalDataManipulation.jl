using URIParser
using NumericalDataManipulation.DataIO.FileSystem
using NumericalDataManipulation.Interpolation
using NumericalDataManipulation.Data

function load_numerical_table(resource::FileResource; has_title::Bool = false)
    @assert(exists(resource), "The resource $resource does not exist.")
    lines_to_skip = if has_title 1 else 0 end
    datatable = load_datatable(resource.file_path; skip = lines_to_skip)
    numerical_table = NumericalTable(datatable)
    return numerical_table
end

function save_numerical_table(resource::FileResource, table::NumericalTable)
end
