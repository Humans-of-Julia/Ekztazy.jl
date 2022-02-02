struct NamingError <: Exception 
    invalid_name::AbstractString
    name_of::String
    reason::String
end

NamingError(a::AbstractString, nameof::String) = NamingError(a, nameof, "it may be too long or contain invalid characters.")

Base.showerror(io::IO, e::NamingError) = print(io, "Name $(e.invalid_name) is an invalid name for `$(e.name_of)`` because `$(e.reason)`.")
