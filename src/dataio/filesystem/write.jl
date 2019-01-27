using FileIO
using CSVFiles
using DataFrames

function save_datatable(data::DataFrame, file_path::AbstractString)
    return save_DataFrame(data, file_path;
        delimiter = space::Delimiter, header = true)
end

function save_DataFrame(
    data::DataFrame,
    file_path::AbstractString;
    delimiter::Delimiter = space::Delimiter,
    header::Bool = true)
    @assert(!isdir(file_path), ArgumentError("The file '$file_path' is a directory."))
    file_object = query(file_path)
    @assert(!unknown(file_object), ArgumentError("The file '$file_path' has unknown extension and/or format."))
    file_format = typeof(file_object).parameters[1]
    @info "Detected the format $file_format for the file '$file_path'. Saving to DataFrame..."

    data |> save(file_path;
        delim=DELIMITER[delimiter],
        nastring="NA", header=header)
    @info "... Data saved from a DataFrame to the file $file_path."
end
