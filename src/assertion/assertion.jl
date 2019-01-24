module Assertion

# macro assert_that(expression, messages...)
#     message = isempty(messages) ? expression : messages[1]
#     if isa(message, AbstractString)
#         message = message
#     elseif !isempty(messages) && (isa(message, Expr) || isa(message, Symbol))
#         # message is an expression needing evaluating
#         message = :(Main.Base.string($(esc(message))))
#     elseif isdefined(Main, :Base) && isdefined(Main.Base, :string) && applicable(Main.Base.string, message)
#         message = Main.Base.string(message)
#     else
#         # string() might not be defined during bootstrap
#         message = :(Main.Base.string($(Expr(:quote, message))))
#     end
#
#     parts = length(messages) < 2 ? Vector{Expr}() : collect(messages[2:end])
#     part_messages = Vector{Any}()
#     if isa(parts, Vector)
#         if !isempty(parts)
#             @info "Parts: $parts"
#             for part ∈ parts
#                 if isa(part, Expr) || isa(part, Symbol)
#                     push!(part_messages, :($part))
#                 elseif isa(part, QuoteNode)
#                     @info "Part quote: $(part.value)"
#                     push!(part_messages, :( Main.Base.string( $(Expr(:quote,part.value)) ) ))
#                 else
#                     push!(part_messages, :($part))
#                 end
#             end
#         end
#     end# Main.Base.string($(esc(part))))
#
#     return :($(esc(expression)) ? $(nothing) : throw( AssertionError($(part_messages[1])) ))
# end

# macro assert_that(expression, explanation::AbstractString)
#     return quote if $expression
#             nothing
#         else
#             formula = $(string(expression))
#             explanation_text = $(explanation)
#             throw(AssertionError("Expression: '$formula'; Explanation: $explanation_text"))
#         end
#     end
# end
#
# macro assert_that(expression, explanation::AbstractString, parts)
#     return quote
#         if $expression
#             nothing
#         else
#             formula = $(string(expression))
#             explanation_text = $(explanation)
#             parts_text = $(parts)
#             throw(AssertionError("Expression: '$formula'; Explanation: $explanation_text; Parts: $parts_text"))
#         end
#     end
# end

# function assertion_parts(parts::Vector{Pair{Expr, Any}})
#     join(map(part -> "$(part.first) = $(part.second)", parts), ", ")
# end
#
# function assertion_parts(parts::Vector{Pair{Symbol, Any}})
#     join(map(part -> "$(part.first) = $(part.second)", parts), ", ")
# end
#
# function assertion_parts(parts::Vector{Pair{Any, Any}})
#     join(map(part -> "$(part.first) = $(part.second)", parts), ", ")
# end
#
# function assertion_parts(parts::Vector)
#     join(map(
#         part -> begin
#             if("$(typeof(part).name)" == "Pair")
#                 "$(part.first) = $(part.second)"
#             else
#                 "$part"
#             end
#         end, parts), ", ")
# end
#
# export @assert_that
# export assertion_parts

end # module
