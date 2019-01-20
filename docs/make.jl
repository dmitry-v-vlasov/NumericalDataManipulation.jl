using Documenter, NumericalDataManipulation

makedocs(
    modules = [NumericalDataManipulation],
    format = :html,
    checkdocs = :exports,
    sitename = "NumericalDataManipulation.jl",
    pages = Any["index.md"]
)

deploydocs(
    repo = "github.com/dmitry-v-vlasov/NumericalDataManipulation.jl.git",
)
