using FileIO
using CSVFiles
using DataFrames

function load_table(file_path::AbstractString)
    return load_DataFrame(file_path;
        skip_lines = 0, delimiter = space::Delimiter, header = true)
end

function load_DataFrame(
    file_path::AbstractString;
    skip_lines::Int = 0,
    delimiter::Delimiter = space::Delimiter,
    header::Bool = true, column_names::Dict{Int, AbstractString} = Dict{Int, AbstractString}())
    @assert(isfile(file_path), ArgumentError("The file '$file_path' does not exist or is not a file."))
    file_object = query(file_path)
    @assert(!unknown(file_object), ArgumentError("The file '$file_path' has unknown extension and/or format."))
    file_format = typeof(file_object).parameters[1]
    @info "Detected the format $file_format for the file '$file_path'. Loading to DataFrame..."

    data = if isempty(column_names)
        load(file_object;
            skiplines_begin = skip_lines,
            spacedelim=(delimiter == space::Delimiter),
            header_exists=header,
            type_detect_rows=22) |> DataFrame
    else
        load(file_object;
            skiplines_begin = skip_lines,
            spacedelim=(delimiter == space::Delimiter),
            header_exists=header, colnames=column_names,
            type_detect_rows=22) |> DataFrame
    end
    if data == nothing
        @warn "... No data has been loaded."
        return nothing
    end
    @info "... Data loaded to a new DataFrame with size $(size(data, 1))×$(size(data, 2))."
end
