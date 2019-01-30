using Statistics
using NumericalDataManipulation.Common

function merge_grids(G¹::DataGrid, G²::DataGrid;
    ntail::Int=5, ϵʳᵉˡ::Float64=0.4, meanΔ::Function=mean_log10)
    newknots = merge_knots(G¹.knots, G².knots; ntail=ntail, ϵʳᵉˡ=ϵʳᵉˡ, meanΔ=meanΔ)
    return DataGrid(newknots)
end
function merge_knots(V¹::Vector{Float64}, V²::Vector{Float64};
    ntail::Int=5, ϵʳᵉˡ::Float64=0.4, meanΔ::Function=mean_log10)
    @assert(issorted(V¹), "The first vector argument is not sorted in an ascending order.")
    @assert(issorted(V²), "The second vector argument is not sorted in an ascending order.")
    @assert(allunique(V¹), "The first vector argument must contain uniques elements.")
    @assert(allunique(V²), "The second vector argument must contain uniques elements.")
    V⁰ = vcat(V¹, V²)
    if !issorted(V⁰)
        sort!(V⁰)
    end
    if !allunique(V⁰)
        unique!(V⁰)
    end
    return unique_knots(V⁰; ntail=ntail, ϵʳᵉˡ=ϵʳᵉˡ, meanΔ=meanΔ)
end

function unique_knots(knots::Vector{Float64};
    ntail::Int=5, ϵʳᵉˡ::Float64=0.4, meanΔ::Function=mean_log10)
    @assert issorted(knots)
    @assert allunique(knots)
    @assert ntail ≥ 2
    @assert ϵʳᵉˡ > 0
    Δknots = Δknot_values(knots)
    @assert ntail < length(Δknots)

    Δ𝐆ˡᵒᵍ¹⁰ = meanΔ(nonzero(Δknots))
    @debug "Δ𝐆ˡᵒᵍ¹⁰ = $Δ𝐆ˡᵒᵍ¹⁰"
    @assert Δ𝐆ˡᵒᵍ¹⁰ ≠ 0

    dots = Vector{Float64}()
    K = length(knots)
    Δtail = Vector{Float64}()
    Δhead = Vector{Float64}()
    pushfirst!(Δtail, ∞)
    push!(Δhead, Δknots[1])
    for k = 1:K - 1
        # --- tail ---
        if k < ntail
            pushfirst!(Δtail, Δknots[k])
        elseif ntail ≤ k < K - 1
            pop!(Δtail)
            pushfirst!(Δtail, Δknots[k])
        else @assert k == K - 1
            pop!(Δtail)
            pushfirst!(Δtail, ∞)
        end
        @assert length(Δtail) ≥ 2
        # -------------
        # --- head ---
        if 1 ≤ k < K - 2
            pop!(Δhead)
            push!(Δhead, Δknots[k + 1])
        else
            pop!(Δhead)
            push!(Δhead, ∞)
        end
        @assert length(Δhead) == 1
        # ------------
        # --- current knots ---
        knotᵏ = knots[k]
        knotᵏ⁺¹ = knots[k + 1]
        # ---------------------

        @debug "--- BEGIN --- [$knotᵏ, $knotᵏ⁺¹]"
        @debug "-- begin --- ϵΔtail, ϵΔhead"
        ϵΔtail = relfinity(Δtail; D=Δ𝐆ˡᵒᵍ¹⁰, ϵʳᵉˡ=ϵʳᵉˡ)
        ϵΔhead = relfinity(Δhead; D=Δ𝐆ˡᵒᵍ¹⁰, ϵʳᵉˡ=ϵʳᵉˡ)
        @debug "ϵΔtail: $ϵΔtail"
        @debug "ϵΔhead: $ϵΔhead"
        @debug "--- end ---"
        if [1, ∞] == ϵΔtail[1:2]
            @debug "[1, ∞]"
            push!(dots, knotᵏ)
            @debug "[1, ∞] - pushed: $knotᵏ"
        elseif [0, ∞] == ϵΔtail[1:2]
            @debug "[0, ∞]"
            push!(dots, knotᵏ)
            @debug "[0, ∞] - pushed: $knotᵏ"
        elseif [1, 1] == ϵΔtail[1:2]
            @debug "[1, 1]"
            push!(dots, knotᵏ)
            @debug "[1, 1] - pushed: $knotᵏ"
        elseif [0, 1] == ϵΔtail[1:2]
            @debug "[0, 1]"
            if [1] == ϵΔhead
                @debug "[0, 1] - 1"
                if length(ϵΔtail) > 2 && ϵΔhead[1] == 1
                    push!(dots, (knotᵏ + knotᵏ⁺¹) / 2)
                    @debug "[0, 1] - 1 - pushed: $((knotᵏ + knotᵏ⁺¹) / 2)"
                else
                    @debug "[0, 1] - 1 - nothing pushed"
                end
            elseif [0] == ϵΔhead
                @debug "[0, 1] - 0"
                push!(dots, knotᵏ)
                @debug "[0, 1] - 0 - pushed: $knotᵏ"
            elseif [∞] == ϵΔhead
                @debug "[0, 1] - ∞"
                # The cases [0, ∞], [1, ∞] go next.
            end
        elseif [0, 0] == ϵΔtail[1:2]
            @debug "[0, 0]"
        elseif [1, 0] == ϵΔtail[1:2]
            @debug "[1, 0]"
            if length(ϵΔtail) == 2 || (length(ϵΔtail) > 2 && 0 == ϵΔtail[3])
                # TODO: maybe this branch must be the only one to calculate mean knots.
                last_dot = dots[end]
                Σδ, n = sum_until(
                    (δ::Float64, Σδ::Float64) ->
                        δ ∈ [∞, NaN, 1] || 0 ≠ relfinity(Σδ; D=Δ𝐆ˡᵒᵍ¹⁰, ϵʳᵉˡ=ϵʳᵉˡ),
                    Δtail[2:end])
                δ⁰⁵ = Σδ / 2
                if dots[end] > knotᵏ - δ⁰⁵
                    @warn "unsorted next knot: $(knotᵏ - δ⁰⁵), previous: $(dots[end]); tail: $Δtail, ϵΔtail: $ϵΔtail"
                end
                push!(dots, knotᵏ - δ⁰⁵)
                @debug "[1, 0] - pushed: $(knotᵏ - δ⁰⁵) (knotᵏ = $knotᵏ, δ⁰⁵ = $δ⁰⁵)"
            end
            # The cases [0, 1], [0, 0] were handled.
            # The case [1, 0] will be handled.
        elseif [∞, 0] == ϵΔtail[1:2]
            @debug "[∞, 0]"
            push!(dots, knotᵏ⁺¹)
            @debug "[∞, 0] - pushed: $knotᵏ⁺¹"
        elseif [∞, 1] == ϵΔtail[1:2]
            @debug "[∞, 1]"
            push!(dots, knotᵏ⁺¹)
            @debug "[∞, 1] - pushed: $knotᵏ⁺¹"
        end
        @debug "--- END ---"
    end
    return dots
end
