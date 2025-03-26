# Individual resources for the tests
power = ResourceCarrier("Power", 0.0)
h2_hp = ResourceCarrier("H₂ʰᵖ", 0.0)
h2_lp = ResourceCarrier("H₂ˡᵖ", 0.0)
co2 = ResourceEmit("CO₂", 1.0)

@testset "Unidirectional modes" begin
    tm = PipeLinepackSimple(
        "pipeline",
        h2_hp,
        h2_lp,
        power,                # Consuming resource
        FixedProfile(0.05),   # Consumption rate
        FixedProfile(50),     # Capacity
        FixedProfile(0.01),   # Loss
        FixedProfile(0.1),    # Opex var
        FixedProfile(1.0),    # Opex fixed
        0.1,                  # Storage capacity
    )
    err_log, warn_log = compliance_element(tm);
    𝒯 = TwoLevel(1,1,SimpleTimes(10,1))

    # Test of the case with and without specified co2
    test_case(tm, 𝒯, warn_log; co2);
    test_case(tm, 𝒯, warn_log);

    # Test that it still works with a warning
    warn_log = (capacity=true,)
    test_case(tm, 𝒯, warn_log; co2);
    test_case(tm, 𝒯, warn_log);
end

@testset "Bidirectional modes" begin
    tm = RefDynamic(
        "Dynamic",
        power,
        FixedProfile(30.0),
        FixedProfile(0.01),
        FixedProfile(0.1),
        FixedProfile(1),
        2
    )
    err_log, warn_log = compliance_element(tm);
    𝒯 = TwoLevel(1,1,SimpleTimes(10,1))

    # Test of the case with and without specified co2
    test_case(tm, 𝒯, warn_log; co2);
    test_case(tm, 𝒯, warn_log);
end
