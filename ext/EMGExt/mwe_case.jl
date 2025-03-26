
"""
    EMC.test_case(tm::TransmissionMode, 𝒯::TimeStructure, warn_log; co2::ResourceEmit = ResourceEmit("CO₂", 1.0))

Default testset which tests that the developed [`TransmissionMode`](@extref EnergyModelsGeography.TransmissionMode)
`tm` can be included in an `EnergyModelsGeography` model that solves.

The testset automatically identifies a minimum working case for the given transmission mode
structure. The minimum working example includes 2 areas that are only connected by the given
`TransmissionMode`. Area 1 is the `:from` area and includes sources for supplying all inputs
of the `TransmissionMode`. Area 2 is the `:to` area and includes sinks for all outputs of
the `TransmissionMode`. Both areas also include the opposite if bidirectional transport is
allowed. In this case, the profit is positive in either area 1 or area 2.

The following default values are chosen:
- If we cannot use the function [`capacity`](@extref EnergyModelsBase.capacity), we use a
  capacity of 100. Otherwise, the capacity is sufficient for the capacity of the mode.
- The profit in the sinks is 150 and the penalty 1e4.

# Arguments
- **`tm::TransmissionMode`** is the transmission mode that is tested.
- **`𝒯::TimeStructure`** is the chosen time structure. It should only contain a single
  strategic period.
- **`warn_log`** is the warning `NamedTuple` obtained through calling the function
  `acccess_functionality`.

# Tests
- The optimization problems leads to an optimal solution.
- The variable `:cap_use` of all connected nodes is above 0.1 in at least one of the time
  periods. All source and sink nodes in the two areas are checked.
- The variables `:trans_in` and `:trans_out` are above 0.1 in at least one of the time
  periods.
"""
function EMC.test_case(
    tm::TransmissionMode,
    𝒯::TimeStructure,
    warn_log;
    co2::ResourceEmit=ResourceEmit("CO₂", 1.0)
)
    ## Extraction of relevant data from the transmission mode
    # The extraction utilizes the resources from the TransmissionMode as well as whether it
    # is bidirectional to identify how the system must look like
    cap_src = warn_log.capacity ? FixedProfile(100) : capacity(tm) * 1.5
    if EMG.is_bidirectional(tm)
        n_op = length(first(strategic_periods(𝒯)))
        n_1 = round(Int, n_op/2)
        n_2 = n_op - n_1
        var_opex_1 = OperationalProfile(vcat(-150*ones(n_1), zeros(n_2)))
        var_opex_2 = OperationalProfile(vcat(zeros(n_2), -150*ones(n_1)))
    else
        var_opex_2 = FixedProfile(-150)
    end

    # Creation of the resources based on the inputs and outputs as well as the co2 instance
    𝒫 = unique!(vcat(inputs(tm), outputs(tm), [co2]))

    ## Creation of the nodes and links of the first area
    # The first area is the `:from` area, and hence, requires the source
    src_nodes_1 = EMB.Node[
        RefSource(
            "area_1-source_" * repr(p),
            cap_src,
            FixedProfile(0),
            FixedProfile(0),
            Dict(p => 1),
        )
        for p ∈ inputs(tm)
    ]
    𝒩₁ = EMB.Node[GeoAvailability("area_1", 𝒫)]
    append!(𝒩₁, src_nodes_1)
    src_links_1 = Link[Direct(src.id*"-av", src, 𝒩₁[1]) for src ∈ src_nodes_1]
    ℒ₁ = src_links_1

    # Addition of the required nodes and links for bidirectional transport, if the transmission
    # mode allows for bidirectional transport
    if EMG.is_bidirectional(tm)
        snk_nodes_1 = EMB.Node[
            RefSink(
                "area_1-sink_" * repr(p),
                FixedProfile(0),
                Dict(:surplus => var_opex_1, :deficit => FixedProfile(1e4)),
                Dict(p => 1),
            ) for p ∈ outputs(tm)
        ]
    else
        snk_nodes_1 = EMB.Node[]
    end
    append!(𝒩₁, snk_nodes_1)
    snk_links_1 = Link[Direct("av-"*snk.id, 𝒩₁[1], snk) for snk ∈ snk_nodes_1]
    append!(ℒ₁, snk_links_1)

    ## Creation of the nodes and links of the second area
    # The second area is the `:to` area, and hence, requires the sink
    snk_nodes_2 = EMB.Node[
        RefSink(
            "area_2-sink_" * repr(p),
            FixedProfile(0),
            Dict(:surplus => var_opex_2, :deficit => FixedProfile(1e4)),
            Dict(p => 1),
        ) for p ∈ outputs(tm)
    ]
    𝒩₂ = EMB.Node[GeoAvailability("area_2", 𝒫)]
    append!(𝒩₂, snk_nodes_2)
    snk_links_2 = Link[Direct("av-"*snk.id, 𝒩₂[1], snk) for snk ∈ snk_nodes_2]
    ℒ₂ = snk_links_2

    # Addition of the required nodes and links for bidirectional transport, if the transmission
    # mode allows for bidirectional transport
    if EMG.is_bidirectional(tm)
        src_nodes_2 = EMB.Node[
            RefSource(
                "area_2-source_" * repr(p),
                cap_src,
                FixedProfile(0),
                FixedProfile(0),
                Dict(p => 1),
            )
            for p ∈ inputs(tm)
        ]
    else
        src_nodes_2 = EMB.Node[]
    end
    append!(𝒩₂, src_nodes_2)
    src_links_2 = Link[Direct(src.id*"-av", src, 𝒩₂[1]) for src ∈ src_nodes_2]
    append!(ℒ₂, src_links_2)

    # Creation of the element vectors for the case
    𝒩 = vcat(𝒩₁, 𝒩₂)
    ℒ = vcat(ℒ₁, ℒ₂)
    𝒜 = [RefArea(1, "area_1", 1, 1, 𝒩₁[1]), RefArea(2, "area_2", 1, 1, 𝒩₂[1])]
    ℒᵗʳᵃⁿˢ = [Transmission(𝒜[1], 𝒜[2], TransmissionMode[tm])]

    case = Case(𝒯, 𝒫, [𝒩, ℒ, 𝒜, ℒᵗʳᵃⁿˢ], [[get_nodes, get_links], [get_areas, get_transmissions]])
    model = OperationalModel(
        Dict(co2 => FixedProfile(1e6)), # Emission cap for CO₂
        Dict(co2 => FixedProfile(150)), # Emission price for CO₂ in EUR/t
        co2,                            # CO₂ instance
    )

    # Create the optimization problem and solve it
    optimizer = optimizer_with_attributes(HiGHS.Optimizer, MOI.Silent() => true)
    m = run_model(case, model, optimizer)

    # Test that the problem results in optimality
    @testset "Default testset - $(typeof(tm))" begin
        @test termination_status(m) == MOI.OPTIMAL

        # Test that the capacity of the mode is utilized
        @test any(value.(m[:trans_in][tm, t]) > 0.1 for t ∈ 𝒯)
        @test any(value.(m[:trans_out][tm, t]) > 0.1 for t ∈ 𝒯)

        # Test that the links to the mode are working
        @test all(
            any(value.(m[:cap_use][n_src, t]) > 0.1 for t ∈ 𝒯)
        for n_src ∈ vcat(src_nodes_1, src_nodes_2))
        @test all(
            any(value.(m[:cap_use][n_snk, t]) > 0.1 for t ∈ 𝒯)
        for n_snk ∈ vcat(snk_nodes_1, snk_nodes_2))
    end
end
