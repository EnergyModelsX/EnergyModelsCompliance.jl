# Individual resources for the tests
ng = ResourceCarrier("NG", 0.2)
power = ResourceCarrier("Power", 0.0)
co2 = ResourceEmit("CO₂", 1.0)

@testset "Source nodes" begin
    node = RefSource(
        "NG source",                # Node id
        FixedProfile(100),          # Capacity in MW
        FixedProfile(30),           # Variable OPEX in EUR/MW
        FixedProfile(0),            # Fixed OPEX in EUR/MW/8h
        Dict(ng => 1),              # Output from the Node, in this case, ng
    )
    err_log, warn_log = compliance_element(node);
    𝒯 = TwoLevel(1,1,SimpleTimes(10,1))

    # Test of the case with and without specified co2
    test_case(node, 𝒯, warn_log; co2);
    test_case(node, 𝒯, warn_log);

    # Test that it still works with a warning
    warn_log = (opex_var=true,)
    test_case(node, 𝒯, warn_log; co2);
    test_case(node, 𝒯, warn_log);
end

@testset "NetworkNode nodes" begin
    # with co2 capture
    node = RefNetworkNode(
        "NG+CCS power plant",       # Node id
        FixedProfile(25),           # Capacity in MW
        FixedProfile(5.5),          # Variable OPEX in EUR/MWh
        FixedProfile(0),            # Fixed OPEX in EUR/MW/8h
        Dict(ng => 2),              # Input to the node with input ratio
        Dict(power => 1, co2 => 1), # Output from the node with output ratio
        # Line above: co2 is required as output for variable definition, but the
        # value does not matter
        [CaptureEnergyEmissions(0.9)],  # Additonal data for emissions and CO₂ capture
    )
    err_log, warn_log = compliance_element(node);
    𝒯 = TwoLevel(1,1,SimpleTimes(10,1))

    # Test of the case with and without specified co2
    test_case(node, 𝒯, warn_log; co2);
    test_case(node, 𝒯, warn_log);

    # Test that it still works with a warning
    warn_log = (capacity=true, opex_var=true)
    test_case(node, 𝒯, warn_log; co2);
    test_case(node, 𝒯, warn_log);

    # without co2 capture
    node = RefNetworkNode(
        "NG power plant",           # Node id
        FixedProfile(25),           # Capacity in MW
        FixedProfile(5.5),          # Variable OPEX in EUR/MWh
        FixedProfile(0),            # Fixed OPEX in EUR/MW/8h
        Dict(ng => 1.7),            # Input to the node with input ratio
        Dict(power => 1),           # Output from the node with output ratio
    )
    err_log, warn_log = compliance_element(node);
    𝒯 = TwoLevel(1,1,SimpleTimes(10,1))

    # Test of the case with and without specified co2
    test_case(node, 𝒯, warn_log; co2);
    test_case(node, 𝒯, warn_log);
end

@testset "Storage nodes" begin
    node = RefStorage{CyclicStrategic}(
        "CO2 storage",              # Node id
        StorCapOpex(
            FixedProfile(60),       # Charge capacity in MW
            FixedProfile(5),        # Storage variable OPEX for the charging in EUR/MWh
            FixedProfile(0)         # Storage fixed OPEX for the charging in EUR/(MW 8h)
        ),
        StorCap(FixedProfile(1e5)), # Storage capacity in MWh
        power,                      # Stored resource
        Dict(power => 1),           # Input resource with input ratio
        Dict(power => 1),           # Output from the node with output ratio
    )
    err_log, warn_log = compliance_element(node);
    𝒯 = TwoLevel(1,1,SimpleTimes(10,1))

    # Test of the case with and without specified co2
    test_case(node, 𝒯, warn_log; co2);
    test_case(node, 𝒯, warn_log);
end

@testset "Sink nodes" begin
    node = RefSink(
        "electricity demand",       # Node id
        OperationalProfile([20, 30, 40, 30]), # Demand in MW
        Dict(:surplus => FixedProfile(-100), :deficit => FixedProfile(1e6)),
        # Line above: Surplus and deficit penalty for the node in EUR/MWh
        Dict(power => 1),           # Energy demand and corresponding ratio
    )
    err_log, warn_log = compliance_element(node);
    𝒯 = TwoLevel(1,1,SimpleTimes(4,1))

    # Test of the case with and without specified co2
    test_case(node, 𝒯, warn_log; co2);
    test_case(node, 𝒯, warn_log);

    # Test that it still works with a warning
    warn_log = (capacity=true,)
    test_case(node, 𝒯, warn_log; co2);
    test_case(node, 𝒯, warn_log);
end
