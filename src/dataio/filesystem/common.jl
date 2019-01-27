using FileIO

const R_FILE_PATH = r"(((\.\.){1}/)*|(/){1})?(([a-zA-Z0-9]*)/)*([a-zA-Z0-9]*)+([.dat]|[.txt]|[.dsv]|[.csv])+"
function issomepath(some_path)
    return occursin(R_FILE_PATH, some_path)
end

file_extension(path::AbstractString) = try match(r"\.[A-Za-z0-9]+$", path).match catch e "" end

function file_format(path::AbstractString)
    extension = strip(file_extension(path))
    if isempty(extension)
        return format""
    else
        @assert startswith(extension, '.')
        @assert length(extension) > 1
        return DataFormat{Symbol(uppercase(extension[2:end]))}
    end
end
