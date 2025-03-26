@testset "Area" begin
    area = TestArea("1")
    msg = "The function `availability_node(a)` is not working for the areatype " *
        "`TestArea`.\n" *
        "As a consequence, the model will not construct."
    @test_logs (:error, msg) EMGExt.compliance_area_availability(area)
    disable_logging(Error), (@test EMGExt.compliance_area_availability(area)), disable_logging(Debug)

    EMG.availability_node(a::TestArea) = 1
    msg = "The function `availability_node(a)` does not return an `Availability` " *
        "node as output for the area type `TestArea`.\n" *
        "As a consequence, the model will not construct."
    @test_logs (:error, msg) EMGExt.compliance_area_availability(area)
    disable_logging(Error), (@test EMGExt.compliance_area_availability(area)), disable_logging(Debug)
    Base.delete_method(@which availability_node(area))
end

@testset "TransmissionMode" begin
    mode = TestMode("1")
    pipe = TestPipe("1")

    # Test the capacity warnings
    msg = "The function `capacity(tm)` is not working for the mode type `TestMode`.\n" *
        "If you do not use the default constraint function " *
        "`constraints_capacity_installed`, either directly or through the default " *
        "method `create_mode`, you can ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_capacity(mode)
    disable_logging(Warn), (@test EMC.compliance_capacity(mode)), disable_logging(Debug)

    EMB.capacity(tm::TestMode) = FixedProfile(5)
    msg = "The function `capacity(tm, t)` is not working for the mode type " *
        "`TestMode`.\n" * "If you do not use the default constraint function " *
        "`constraints_capacity_installed`, either directly or through the default " *
        "method `create_mode`, you can ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_capacity(mode)
    disable_logging(Warn), (@test EMC.compliance_capacity(mode)), disable_logging(Debug)
    Base.delete_method(@which capacity(mode))

    # Test the variable OPEX warnings
    msg = "The function `opex_var(tm)` is not working for the mode type " *
        "`TestMode`.\n" *
        "If you do not use the default constraint function `constraints_opex_var`, " *
        "either directly or through the default method `create_mode`, you can " *
        "ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_opex_var(mode)
    disable_logging(Warn), (@test EMC.compliance_opex_var(mode)), disable_logging(Debug)

    EMB.opex_var(tm::TestMode) = FixedProfile(5)
    msg = "The function `opex_var(tm, t)` is not working for the mode type " *
        "`TestMode`.\n" *
        "If you do not use the default constraint function `constraints_opex_var`, " *
        "either directly or through the default method `create_mode`, you can " *
        "ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_opex_var(mode)
    disable_logging(Warn), (@test EMC.compliance_opex_var(mode)), disable_logging(Debug)
    Base.delete_method(@which opex_var(mode))

    # Test the fixed OPEX warnings
    msg = "The function `opex_fixed(tm)` is not working for the mode type " *
        "`TestMode`.\n" *
        "If you do not use the default constraint function `constraints_opex_fixed`, " *
        "either directly or through the default method `create_mode`, you can " *
        "ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_opex_fixed(mode)
    disable_logging(Warn), (@test EMC.compliance_opex_fixed(mode)), disable_logging(Debug)

    EMB.opex_fixed(tm::TestMode) = FixedProfile(5)
    msg =  "The function `opex_fixed(tm, t_inv)` is not working for the " *
        "mode type `TestMode`.\n" *
        "If you do not use the default constraint function `constraints_opex_fixed`, " *
        "either directly or through the default method `create_mode`, you can " *
        "ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_opex_fixed(mode)
    disable_logging(Warn), (@test EMC.compliance_opex_fixed(mode)), disable_logging(Debug)
    Base.delete_method(@which opex_fixed(mode))

    # Test the input error
    msg = "The function `inputs(tm)` is not working for the mode type `TestMode`.\n" *
        "As a consequence, the model will not construct."
    @test_logs (:error, msg) EMC.compliance_inputs(mode)
    disable_logging(Error), (@test EMC.compliance_inputs(mode)[1]), disable_logging(Debug)

    EMB.inputs(tm::TestMode) = [1,2,3]
    msg = "The function `inputs(tm)` does not return an `Array{<:Resource}` as " *
        "output for the transmission mode type `TestMode`.\n" *
        "As a consequence, the model will not construct."
    @test_logs (:error, msg) EMC.compliance_inputs(mode)
    disable_logging(Error), (@test EMC.compliance_inputs(mode)[1]), disable_logging(Debug)
    Base.delete_method(@which inputs(mode))

    # Test the output error
    msg = "The function `outputs(tm)` is not working for the mode type `TestMode`.\n" *
        "As a consequence, the model will not construct."
    @test_logs (:error, msg) EMC.compliance_outputs(mode)
    disable_logging(Error), (@test EMC.compliance_outputs(mode)[1]), disable_logging(Debug)

    EMB.outputs(tm::TestMode) = [1,2,3]
    msg = "The function `outputs(tm)` does not return an `Array{<:Resource}` as " *
        "output for the transmission mode type `TestMode`.\n" *
        "As a consequence, the model will not construct."
    @test_logs (:error, msg) EMC.compliance_outputs(mode)
    disable_logging(Error), (@test EMC.compliance_outputs(mode)[1]), disable_logging(Debug)
    Base.delete_method(@which outputs(mode))

    # Test the data warning
    msg = "The function `mode_data(tm)` is not working for the mode type `TestMode`.\n" *
        "If you do not use the default functions `create_mode` and `investment_data` " *
        "(when using `EnergyModelsInvestments`),\n" *
        "you can ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_data(mode)
    disable_logging(Warn), (@test EMC.compliance_data(mode)), disable_logging(Debug)

    # Test the loss warnings
    msg = "The function `loss(tm)` is not working for the mode type " *
        "`TestMode`.\n" *
        "If you do not use the default constraint function `constraints_trans_loss`, " *
        "either directly or through the default method `create_mode`, you can " *
        "ignore this warning."
    @test_logs (:warn, msg) EMGExt.compliance_loss(mode)
    disable_logging(Warn), (@test EMGExt.compliance_loss(mode)), disable_logging(Debug)

    EMG.loss(tm::TestMode) = FixedProfile(5)
    msg = "The function `loss(tm, t)` is not working for the mode type " *
        "`TestMode`.\n" *
        "If you do not use the default constraint function `constraints_trans_loss`, " *
        "either directly or through the default method `create_mode`, you can " *
        "ignore this warning."
    @test_logs (:warn, msg) EMGExt.compliance_loss(mode)
    disable_logging(Warn), (@test EMGExt.compliance_loss(mode)), disable_logging(Debug)
    Base.delete_method(@which loss(mode))

    # Test the bidirectional error
    msg = "The function `is_bidirectional(tm)` is not working for the mode type " *
        "`TestMode`.\n" *
        "As a consequence, the model will not construct."
    @test_logs (:error, msg) EMGExt.compliance_bidirectional(mode)
    disable_logging(Error), (@test EMGExt.compliance_bidirectional(mode)), disable_logging(Debug)
    @test !EMGExt.compliance_bidirectional(pipe)

    # Test the consumnption rate warnings
    msg = "The function `consumption_rate(tm)` is not working for the pipe type " *
        "`TestPipe`.\n" *
        "If you do not use the default compute function `compute_trans_in`, " *
        "you can ignore this warning."
    @test_logs (:warn, msg) EMGExt.compliance_con_rate(pipe)
    disable_logging(Warn), (@test EMGExt.compliance_con_rate(pipe)), disable_logging(Debug)

    EMG.consumption_rate(tm::TestPipe) = FixedProfile(5)
    msg = "The function `consumption_rate(tm, t)` is not working for the " *
        "pipe type `TestPipe`.\n" *
        "If you do not use the compute constraint function `compute_trans_in`, " *
        "you can ignore this warning."
    @test_logs (:warn, msg) EMGExt.compliance_con_rate(pipe)
    disable_logging(Warn), (@test EMGExt.compliance_con_rate(pipe)), disable_logging(Debug)
    Base.delete_method(@which consumption_rate(pipe))
end
