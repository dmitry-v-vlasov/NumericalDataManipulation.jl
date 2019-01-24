using FileIO

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
