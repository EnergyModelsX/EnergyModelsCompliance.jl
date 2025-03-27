"""
    test_case(n::Source, 𝒯::TimeStructure, warn_log; co2::ResourceEmit = ResourceEmit("CO₂", 1.0))
    test_case(n::NetworkNode, 𝒯::TimeStructure, warn_log; co2::ResourceEmit = ResourceEmit("CO₂", 1.0))
    test_case(n::Storage, 𝒯::TimeStructure, warn_log; co2::ResourceEmit = ResourceEmit("CO₂", 1.0))
    test_case(n::Sink, 𝒯::TimeStructure, warn_log; co2::ResourceEmit = ResourceEmit("CO₂", 1.0))

Default testset which tests that the developed [`Node`](@extref EnergyModelsBase.Node) `n`
can be included in an `EnergyModelsBase` model, and that the resulting model is solvable.

The testset automatically identifies a minimum working case for the given node structure and
solves this case. The [`Source`](@extref EnergyModelsBase.Source) node of the example has in
all versions (except if you test a source node) a variable OPEX of 0. This implies, that if
you test a [`Sink`](@extref EnergyModelsBase.Sink) node without a fixed demand, you must
provide parameters so that it is beneficial to deliver energy to the sink node. This can be
achieved through receiving a profit.

The same holds for a case in which you have a [`Storage`](@extref EnergyModelsBase.Storage)
node without an output.

The following default values are chosen:
- If we cannot use the function [`capacity`](@extref EnergyModelsBase.capacity), we use a
  capacity of 100. Otherwise, the capacity is sufficient for the capacity of the node.
- If we cannot use the function [`opex_var`](@extref EnergyModelsBase.opex_var) (in all
  cases except for `n::Sink`), we assume it is 2500 for calculating the penalties of the Sink.

!!! warning "Potential problems with the function"
    - If you use `JuMP.fix` for fixing storage charge or discharge variables, that is not
      providing a new method for `has_input` or `has_output`, some of the tests may fail.
      These functions are in this case related to `:cap_use` of a source or sink, as well as
      `:stor_charge_use` or `:stor_discharge_use`.
    - The function is not working properly if you have the co2 keyword argument as `input`
      to your node.
    - The function is not designed to evaluate a required sequence of linked nodes. As an
      example, CCS retrofit requires the direct coupling of two nodes. This cannot be
      generalized.
    - The function cannot be used for a link as you would need to provide `Node`s as values
      for the fields `:from` and `:to`.

# Arguments
- **`n::EMB.Node`** is the node that is tested.
- **`𝒯::TimeStructure`** is the chosen time structure. It should only contain a single
  strategic period.
- **`warn_log`** is the warning `NamedTuple` obtained through calling the function
  `compliance_element`.

# Keyword arguments
- **`co2::ResourceEmit`** is the CO₂ resource in the model. If your node does not include
  CO₂, you do not have to specify it.

# Tests
- The optimization problems leads to an optimal solution.
- The variable `:cap_use` of all connected nodes is above 0.1 in at least one of the time
  periods.

!!! tip "Source, NetworkNode, and Sink"
    We test furthermore:
    - The variable `:cap_use` of the node `n` is above 0.1 in at least one of the time
      periods.

!!! note "Storage"
    `Storage` nodes use a random source variable OPEX and a fixed sink demand to analyse the
    changes in the storage level. This implies that if the `Storage` node does not have an
    output, then it is crucial that it is beneficial to store the `Resource`. This can be
    achieved through negative OPEX terms that must be above
    We test furthermore:
    - The variables `:stor_level`, `:stor_charge_use`, and `:stor_discharge_use` of the node
      `n` are above 0.1 in at least one of the time periods.
"""
function test_case(
    n::Source,
    𝒯::TimeStructure,
    warn_log;
    co2::ResourceEmit=ResourceEmit("CO₂", 1.0)
)
    ## Extraction of relevant data from the node
    # The extraction utilizes the warnings as input to identify whether the individual
    # functions are valid for the Source `n`
    var_opex = warn_log.opex_var ? FixedProfile(500) : opex_var(n) * 5

    # Creation of the resources based on the inputs and outputs as well as the co2 instance
    𝒫 = unique!(vcat(outputs(n), [co2]))

    # Creation of the source and sink nodes based on the inputs and outputs of the node
    snk_nodes = EMB.Node[
        RefSink(
            "sink_" * repr(p),
            FixedProfile(0),
            Dict(:surplus => var_opex * (-0.95), :deficit => var_opex),
            Dict(p => 1),
        ) for p ∈ outputs(n)
    ]

    # Creation of the node vector
    𝒩 = vcat(snk_nodes, [n])

    # Creation of the source and sink links
    snk_links = Link[Direct("new_node-"*snk.id, n, snk) for snk ∈ snk_nodes]
    ℒ = vcat(snk_links)

    # Input data structure
    case = Case(𝒯, 𝒫, [𝒩, ℒ], [[get_nodes, get_links]])
    model = OperationalModel(
        Dict(co2 => FixedProfile(1e6)), # Emission cap for CO₂
        Dict(co2 => FixedProfile(150)), # Emission price for CO₂ in EUR/t
        co2,                            # CO₂ instance
    )

    # Create the optimization problem and solve it
    optimizer = optimizer_with_attributes(HiGHS.Optimizer, MOI.Silent() => true)
    m = run_model(case, model, optimizer)

    # Test that the problem results in optimality
    @testset "Default testset - $(typeof(n))" begin
        @test termination_status(m) == MOI.OPTIMAL

        # Test that the capacity of the node is utilized
        @test any(value.(m[:cap_use][n, t]) > 0.1 for t ∈ 𝒯)

        # Test that the links to the node are working
        @test all(any(value.(m[:cap_use][n_snk, t]) > 0.1 for t ∈ 𝒯) for n_snk ∈ snk_nodes)
    end
end
function test_case(
    n::NetworkNode,
    𝒯::TimeStructure,
    warn_log;
    co2::ResourceEmit=ResourceEmit("CO₂", 1.0)
)
    ## Extraction of relevant data from the node
    # The extraction utilizes the warnings as input to identify whether the individual
    # functions are valid for the NetworkNode `n`
    cap = warn_log.capacity ? FixedProfile(100) : capacity(n)*1.5
    var_opex = warn_log.opex_var ? FixedProfile(500) : opex_var(n) * 5
    dict_in = Dict(p => 1 for p ∈ inputs(n))

    # Creation of the resources based on the inputs and outputs as well as the co2 instance
    𝒫 = unique!(vcat(inputs(n), outputs(n), [co2]))

    # Creation of the source and sink nodes based on the inputs and outputs of the node
    src_nodes = EMB.Node[
        RefSource(
            "source_" * repr(p),
            cap * dict_in[p],
            FixedProfile(0),
            FixedProfile(0),
            Dict(p => 1),
        ) for p ∈ inputs(n)
    ]
    snk_nodes = EMB.Node[
        RefSink(
            "sink_" * repr(p),
            FixedProfile(0),
            Dict(:surplus => var_opex * (-0.95), :deficit => var_opex),
            Dict(p => 1),
        ) for p ∈ outputs(n)
    ]

    # Creation of the node vector
    𝒩 = vcat(src_nodes, snk_nodes)
    push!(𝒩, n)

    # Creation of the source and sink links
    src_links = Link[Direct(src.id*"-new_node", src, n) for src ∈ src_nodes]
    snk_links = Link[Direct("new_node-"*snk.id, n, snk) for snk ∈ snk_nodes]
    ℒ = vcat(src_links, snk_links)

    # Input data structure
    case = Case(𝒯, 𝒫, [𝒩, ℒ], [[get_nodes, get_links]])
    model = OperationalModel(
        Dict(co2 => FixedProfile(1e6)), # Emission cap for CO₂
        Dict(co2 => FixedProfile(150)), # Emission price for CO₂ in EUR/t
        co2,                            # CO₂ instance
    )

    # Create the optimization problem and solve it
    optimizer = optimizer_with_attributes(HiGHS.Optimizer, MOI.Silent() => true)
    m = run_model(case, model, optimizer)

    # Test that the problem results in optimality
    @testset "Default testset - $(typeof(n))" begin
        @test termination_status(m) == MOI.OPTIMAL

        # Test that the capacity of the node is utilized
        @test any(value.(m[:cap_use][n, t]) > 0.1 for t ∈ 𝒯)

        # Test that the links to the node are working
        @test all(any(value.(m[:cap_use][n_src, t]) > 0.1 for t ∈ 𝒯) for n_src ∈ src_nodes)
        @test all(any(value.(m[:cap_use][n_snk, t]) > 0.1 for t ∈ 𝒯) for n_snk ∈ snk_nodes)
    end
end
function test_case(
    n::Storage,
    𝒯::TimeStructure,
    warn_log;
    co2::ResourceEmit=ResourceEmit("CO₂", 1.0)
)
    # Creation of the resources based on the inputs and outputs as well as the co2 instance
    𝒫 = unique!(vcat(inputs(n), outputs(n), [co2]))

    # Creation of the link and node vector. Depending on whether the node has input or output
    # we create only the relevant nodes.
    cap = FixedProfile(100)
    n_op = length(first(strategic_periods(𝒯)))
    var_opex = OperationalProfile(rand(n_op)*100)
    𝒩 = EMB.Node[n]
    ℒ = Link[]
    if has_input(n)
        src_nodes = EMB.Node[
            RefSource(
                "source_" * repr(p),
                cap * 2,
                var_opex,
                FixedProfile(0),
                Dict(p => 1),
            ) for p ∈ inputs(n)
        ]
        append!(𝒩, src_nodes)
        append!(ℒ, Link[Direct(src.id*"-new_node", src, n) for src ∈ src_nodes])
    end
    if has_output(n)
        snk_nodes = EMB.Node[
            RefSink(
                "sink_" * repr(p),
                cap,
                Dict(:surplus => FixedProfile(0), :deficit => FixedProfile(1000)),
                Dict(p => 1),
            ) for p ∈ outputs(n)
        ]
        append!(𝒩, snk_nodes)
        append!(ℒ, Link[Direct("new_node-"*snk.id, n, snk) for snk ∈ snk_nodes])
    end

    # Input data structure
    case = Case(𝒯, 𝒫, [𝒩, ℒ], [[get_nodes, get_links]])
    model = OperationalModel(
        Dict(co2 => FixedProfile(1e6)), # Emission cap for CO₂
        Dict(co2 => FixedProfile(150)), # Emission price for CO₂ in EUR/t
        co2,                            # CO₂ instance
    )

    # Create the optimization problem and solve it
    optimizer = optimizer_with_attributes(HiGHS.Optimizer, MOI.Silent() => true)
    m = run_model(case, model, optimizer)

    # Test that the problem results in optimality
    @testset "Default testset - $(typeof(n))" begin
        @test termination_status(m) == MOI.OPTIMAL

        # Test that the capacity of the node is utilized
        @test any(value.(m[:stor_level][n, t]) > 0.1 for t ∈ 𝒯)
        has_input(n) && @test any(value.(m[:stor_charge_use][n, t]) > 0.1 for t ∈ 𝒯)
        has_output(n) && @test any(value.(m[:stor_discharge_use][n, t]) > 0.1 for t ∈ 𝒯)

        # Test that the links to the node are working
        has_input(n) && @test all(any(value.(m[:cap_use][n_src, t]) > 0.1 for t ∈ 𝒯) for n_src ∈ src_nodes)
        has_output(n) && @test all(any(value.(m[:cap_use][n_snk, t]) > 0.1 for t ∈ 𝒯) for n_snk ∈ snk_nodes)
    end
end
function test_case(
    n::Sink,
    𝒯::TimeStructure,
    warn_log;
    co2::ResourceEmit=ResourceEmit("CO₂", 1.0)
)
    ## Extraction of relevant data from the node
    # The extraction utilizes the warnings as input to identify whether the individual
    # functions are valid for the Sink `n`
    cap = warn_log.capacity ? FixedProfile(100) : capacity(n)    # Capacity

    # Creation of the resources based on the inputs and outputs as well as the co2 instance
    𝒫 = unique!(vcat(inputs(n), [co2]))

    # Creation of the source and sink nodes based on the inputs and outputs of the node
    src_nodes = EMB.Node[
        RefSource(
            "source_" * repr(p),
            cap,
            FixedProfile(0),
            FixedProfile(0),
            Dict(p => 1),
        ) for p ∈ inputs(n)
    ]

    # Creation of the node vector
    𝒩 = vcat(src_nodes, [n])

    # Creation of the source and sink links
    src_links = Link[Direct(src.id*"-new_node", src, n) for src ∈ src_nodes]
    ℒ = src_links

    # Input data structure
    case = Case(𝒯, 𝒫, [𝒩, ℒ], [[get_nodes, get_links]])
    model = OperationalModel(
        Dict(co2 => FixedProfile(1e6)), # Emission cap for CO₂
        Dict(co2 => FixedProfile(150)), # Emission price for CO₂ in EUR/t
        co2,                            # CO₂ instance
    )

    # Create the optimization problem and solve it
    optimizer = optimizer_with_attributes(HiGHS.Optimizer, MOI.Silent() => true)
    m = run_model(case, model, optimizer)

    # Test that the problem results in optimality
    @testset "Default testset - $(typeof(n))" begin
        @test termination_status(m) == MOI.OPTIMAL

        # Test that the capacity of the node is utilized
        @test any(value.(m[:cap_use][n, t]) > 0.1 for t ∈ 𝒯)

        # Test that the links to the node are working
        @test all(any(value.(m[:cap_use][n_src, t]) > 0.1 for t ∈ 𝒯) for n_src ∈ src_nodes)
    end
end
