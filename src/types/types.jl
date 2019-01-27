module Types

function supertypes(type::DataType)
    types = Vector{DataType}()
    a_type = type
    while a_type.super ≠ Any
        push!(types, a_type.super)
        a_type = a_type.super
    end
    return types
end

function isasupertype(type::DataType, stype::DataType)
    return any(type -> type == stype, supertypes(type))
end

export supertypes
export isasupertype

end  # module Types
