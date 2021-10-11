export InteractionCreate

"""
Interaction Create gateway event
"""
struct InteractionCreate <: AbstractEvent
    int::Interaction
end
@boilerplate InteractionCreate :docs :mock
InteractionCreate(; kwargs...) = InteractionCreate(Interaction(; kwargs...))
InteractionCreate(d::Dict{Symbol, Any}) = InteractionCreate(; d...)
