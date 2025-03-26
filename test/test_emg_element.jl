@testset "Areas" begin
    disable_logging(Error)
    area = TestArea("1")
    err_log, warn_log = EMC.compliance_element(area)
    @test all(err_log == (availability=true,))
    @test isempty(warn_log)

    EMG.availability_node(a::TestArea) =
        GeoAvailability("avail", Resource[ResourceCarrier("test", 0.0)])
    err_log, warn_log = EMC.compliance_element(area)
    println(err_log)
    @test all(err_log == (availability=false,))
    @test isempty(warn_log)
    Base.delete_method(@which availability_node(area))
end

@testset "TransmissionModes" begin
    disable_logging(Error)
    # Test for a standard transmission mode with variations
    mode = TestMode("1")
    err_log, warn_log = EMC.compliance_element(mode)
    @test all(err_log == (inputs=true, outputs=true, bidirectional=true))
    @test all(
        warn_log == (capacity=true, opex_var=true, opex_fixed=true,
            inputs=false, outputs=false, loss=true, consumption_rate=false, data=true)
    )
    EMB.outputs(tm::TestMode) = [ResourceCarrier("test", 0.0)]
    EMG.loss(tm::TestMode) = FixedProfile(10)
    EMG.loss(tm::TestMode, t) = 0
    err_log, warn_log = EMC.compliance_element(mode)
    @test all(err_log == (inputs=true, outputs=false, bidirectional=true))
    @test all(
        warn_log == (capacity=true, opex_var=true, opex_fixed=true,
            inputs=false, outputs=false, loss=false, consumption_rate=false, data=true)
    )
    Base.delete_method(@which outputs(mode))
    Base.delete_method(@which loss(mode))
    Base.delete_method(@which loss(mode, 1))

    # Test for a pipeline transmission mode with variations
    pipe = TestPipe("1")
    EMG.mode_data(tm::TestPipe) = Data[]
    EMG.consumption_rate(tm::TestPipe) = FixedProfile(0.1)
    EMG.consumption_rate(tm::TestPipe, t) = 0.1
    err_log, warn_log = EMC.compliance_element(pipe)
    println(err_log)
    @test all(err_log == (inputs=true, outputs=true, bidirectional=false))
    @test all(
        warn_log == (capacity=true, opex_var=true, opex_fixed=true,
            inputs=false, outputs=false, loss=true, consumption_rate=false, data=false)
    )
    Base.delete_method(@which mode_data(pipe))
    Base.delete_method(@which consumption_rate(pipe))
    Base.delete_method(@which consumption_rate(pipe, 1))
    disable_logging(Debug)
end
