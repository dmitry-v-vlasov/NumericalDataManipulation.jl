module Strings

using REPL
ltx = REPL.REPLCompletions.latex_symbols

function subindex(i::Int)
    return join('₀'+d for d in reverse(digits(i)))
end
function supindex(i::Int)
    return join(ltx["\\^$d"] for d in reverse(digits(i)))
end

export supindex, subindex

end # module
