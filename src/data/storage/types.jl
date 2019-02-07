using URIParser
using DataFrames
using Humanize
using NumericalDataManipulation.Data

abstract type Resource end
abstract type UriResource <: Resource end

struct FileResource <: UriResource
    uri::URI
    file_path::AbstractString

    function FileResource(a_string::AbstractString)
        given_string = strip(a_string)
        uri_string = if(ispath(given_string))
            "file://$(abspath(given_string))"
        elseif issomepath(given_string)
            if startswith(given_string, "file://")
                given_string
            else
                "file://$given_string"
            end
        end
        @assert(!isempty(uri_string), "The given file URI is an empty string.")
        uri = URI(uri_string)
        @assert(isvalid(uri), "The URI '$uri' is not valid.")
        @assert("file" == uri.scheme, "Only the 'file' scheme is supported; Given - '$(uri.scheme)'.")
        @assert(isempty(uri.host) ||
            "localhost" == uri.host ||
            "127.0.0.1" == uri.host, "Only localhost URIs are supported; Given - '$(uri)'.")
        uri_path = uri.path
        # TODO: convert uri_path to a platform specific file_path
        file_path = uri_path
        #@assert(isfile(file_path), "The path '$file_path' does not correspond to a file."
        this = new(uri, file_path)
        return this
    end
end
function Base.show(io::IO, resource::FileResource)
    compact = get(io, :compact, false)

    file_path = resource.file_path
    uri = resource.uri

    if compact
        print(io, "FileResource(path = $file_path, URI = $uri")
    else
        print(io, "FileResource(path = $file_path, URI = $uri")
    end

end
function Base.show(io::IO, ::MIME"text/plain", resource::FileResource)
    show(io, resource)
end

function exists(resource::FileResource)
    return isfile(resource.file_path)
end

function stats(resource::FileResource)
    if exists(resource)
        return stat(resource.file_path)
    else
        return nothing
    end
end

function fsize(resource::FileResource)
    st = stats(resource)
    return st == nothing ?
        "nonexistent" : Humanize.datasize(st.size; style=:dec, format="%.3f")
end

function fsizediff(resource1::FileResource, resource2::FileResource)
    st1 = stats(resource1)
    st2 = stats(resource2)
    if st1 ≠ nothing && st2 ≠ nothing
        size1 = st1.size; size2 = st2.size
        Δsize = size1 - size2
        return "$(sign(Δsize) > 0 ? '➕' : '➖')$(Humanize.datasize(abs(Δsize); style=:gnu, format="%.3f"))"
    else
        return "nonexistent"
    end
end

function fbasename(resource::Resource)
    if exists(resource)
        return basename(resource.file_path)
    else
        return nothing
    end
end
