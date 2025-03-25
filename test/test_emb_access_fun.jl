@testset "Nodes" begin
    node = TestNode("1")
    sink = TestSink("1")
    stor_node = TestStorage{CyclicStrategic}("2", 1)

    # Test the capacity warnings
    msg = "The function `capacity(n)` is not working for the node type `TestNode`.\n" *
        "If you do not use the default constraint function " *
        "`constraints_capacity_installed`, either directly or through the default " *
        "method `create_node`, you can ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_capacity(node)
    disable_logging(Warn), (@test EMC.compliance_capacity(node)), disable_logging(Debug)

    EMB.capacity(n::TestNode) = FixedProfile(5)
    msg = "The function `capacity(n, t)` is not working for the node type " *
    "`TestNode`.\n" * "If you do not use the default constraint function " *
    "`constraints_capacity_installed`, either directly or through the default " *
    "method `create_node`, you can ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_capacity(node)
    disable_logging(Warn), (@test EMC.compliance_capacity(node)), disable_logging(Debug)
    Base.delete_method(@which capacity(node))

    # Test the variable OPEX warnings
    msg = "The function `opex_var(n)` is not working for the node type " *
        "`TestNode`.\n" *
        "If you do not use the default constraint function `constraints_opex_var`, " *
        "either directly or through the default method `create_node`, you can " *
        "ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_opex_var(node)
    disable_logging(Warn), (@test EMC.compliance_opex_var(node)), disable_logging(Debug)

    EMB.opex_var(n::TestNode) = FixedProfile(5)
    msg = "The function `opex_var(n, t)` is not working for the node type " *
        "`TestNode`.\n" *
        "If you do not use the default constraint function `constraints_opex_var`, " *
        "either directly or through the default method `create_node`, you can " *
        "ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_opex_var(node)
    disable_logging(Warn), (@test EMC.compliance_opex_var(node)), disable_logging(Debug)
    Base.delete_method(@which opex_var(node))

    EMB.surplus_penalty(n::TestSink) = FixedProfile(5)
    EMB.surplus_penalty(n::TestSink, t) = 5
    msg = "The function `deficit_penalty(n)` is not working for the node type " *
        "`TestSink`.\n" *
        "If you do not use the default constraint function `constraints_opex_var`, " *
        "either directly or through the default method `create_node`, you can " *
        "ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_opex_var(sink)
    disable_logging(Warn), (@test EMC.compliance_opex_var(sink)), disable_logging(Debug)

    EMB.deficit_penalty(n::TestSink) = FixedProfile(5)
    msg = "The function `deficit_penalty(n, t)` is not working for the node type " *
        "`TestSink`.\n" *
        "If you do not use the default constraint function `constraints_opex_var`, " *
        "either directly or through the default method `create_node`, you can " *
        "ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_opex_var(sink)
    disable_logging(Warn), (@test EMC.compliance_opex_var(sink)), disable_logging(Debug)
    Base.delete_method(@which deficit_penalty(sink))
    Base.delete_method(@which surplus_penalty(sink))
    Base.delete_method(@which surplus_penalty(sink, 1))

    EMB.deficit_penalty(n::TestSink) = FixedProfile(5)
    EMB.deficit_penalty(n::TestSink, t) = 5
    msg = "The function `surplus_penalty(n)` is not working for the node type " *
        "`TestSink`.\n" *
        "If you do not use the default constraint function `constraints_opex_var`, " *
        "either directly or through the default method `create_node`, you can " *
        "ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_opex_var(sink)
    disable_logging(Warn), (@test EMC.compliance_opex_var(sink)), disable_logging(Debug)

    EMB.surplus_penalty(n::TestSink) = FixedProfile(5)
    msg = "The function `surplus_penalty(n, t)` is not working for the node type " *
        "`TestSink`.\n" *
        "If you do not use the default constraint function `constraints_opex_var`, " *
        "either directly or through the default method `create_node`, you can " *
        "ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_opex_var(sink)
    disable_logging(Warn), (@test EMC.compliance_opex_var(sink)), disable_logging(Debug)
    Base.delete_method(@which surplus_penalty(sink))
    Base.delete_method(@which deficit_penalty(sink))
    Base.delete_method(@which deficit_penalty(sink, 1))

    # Test the fixed OPEX warnings
    msg = "The function `opex_fixed(n)` is not working for the node type " *
        "`TestNode`.\n" *
        "If you do not use the default constraint function `constraints_opex_fixed`, " *
        "either directly or through the default method `create_node`, you can " *
        "ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_opex_fixed(node)
    disable_logging(Warn), (@test EMC.compliance_opex_fixed(node)), disable_logging(Debug)

    EMB.opex_fixed(n::TestNode) = FixedProfile(5)
    msg =  "The function `opex_fixed(n, t_inv)` is not working for the " *
        "node type `TestNode`.\n" *
        "If you do not use the default constraint function `constraints_opex_fixed`, " *
        "either directly or through the default method `create_node`, you can " *
        "ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_opex_fixed(node)
    disable_logging(Warn), (@test EMC.compliance_opex_fixed(node)), disable_logging(Debug)
    Base.delete_method(@which opex_fixed(node))

    @test !EMC.compliance_opex_fixed(sink)

    # Test the input errors and warnings
    msg = "The function `inputs(n)` is not working for the node type `TestNode`.\n" *
        "As a consequence, the model will not construct."
    @test_logs (:error, msg) EMC.compliance_inputs(node)
    disable_logging(Error), (@test EMC.compliance_inputs(node)[1]), disable_logging(Debug)

    EMB.inputs(n::TestNode) = [1,2,3]
    msg = "The function `inputs(n)` does not return an `Array{<:Resource}` as " *
        "output for the node type `TestNode`.\n" *
        "As a consequence, the model will not construct."
    @test_logs (:error, msg) EMC.compliance_inputs(node)
    disable_logging(Error), (@test EMC.compliance_inputs(node)[1]), disable_logging(Debug)
    Base.delete_method(@which inputs(node))

    EMB.inputs(n::TestNode) = [ResourceCarrier("test", 0.0)]
    msg = "The function `inputs(n, p)` is not working for the node type " *
        "`TestNode`.\n" *
        "If you do not use the default constraint function `constraints_flow_in`, " *
        "either directly or through the default method `create_node`, you can " *
        "ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_inputs(node)
    disable_logging(Warn), (@test EMC.compliance_inputs(node)[2]), disable_logging(Debug)
    Base.delete_method(@which inputs(node))

    # Test the output errors and warnings
    msg = "The function `outputs(n)` is not working for the node type `TestNode`.\n" *
        "As a consequence, the model will not construct."
    @test_logs (:error, msg) EMC.compliance_outputs(node)
    disable_logging(Error), (@test EMC.compliance_outputs(node)[1]), disable_logging(Debug)

    EMB.outputs(n::TestNode) = [1,2,3]
    msg = "The function `outputs(n)` does not return an `Array{<:Resource}` as " *
        "output for the node type `TestNode`.\n" *
        "As a consequence, the model will not construct."
    @test_logs (:error, msg) EMC.compliance_outputs(node)
    disable_logging(Error), (@test EMC.compliance_outputs(node)[1]), disable_logging(Debug)
    Base.delete_method(@which outputs(node))

    EMB.outputs(n::TestNode) = [ResourceCarrier("test", 0.0)]
    msg = "The function `outputs(n, p)` is not working for the node type " *
        "`TestNode`.\n" *
        "If you do not use the default constraint function `constraints_flow_out`, " *
        "either directly or through the default method `create_node`, you can " *
        "ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_outputs(node)
    disable_logging(Warn), (@test EMC.compliance_outputs(node)[2]), disable_logging(Debug)
    Base.delete_method(@which outputs(node))

    # Test the data warning
    msg = "The function `node_data(n)` is not working for the node type `TestNode`.\n" *
        "If you do not use the default functions `create_node` and `investment_data` " *
        "(when using `EnergyModelsInvestments`),\n" *
        "you can ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_data(node)
    disable_logging(Warn), (@test EMC.compliance_data(node)), disable_logging(Debug)

    # Test the level function warning
    msg = "The function `level(n)` is not working for the storage type `TestStorage{CyclicStrategic}`.\n" *
        "If you do not use the default constraint functions " *
        "`constraints_capacity_installed`, `constraints_opex_fixed`, and " *
        "`constraints_opex_var` either directly or through the default method " *
        "`create_node`, you can ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_level(stor_node)
    disable_logging(Warn), (@test EMC.compliance_level(stor_node)), disable_logging(Debug)

    EMB.level(n::TestStorage) = n.lvl
    msg = "The fieldtype of the field returned by the function `level(n)` is not an " *
        "`AbstractStorageParameters` for the storage type `TestStorage{CyclicStrategic}`.\n" *
        "If you do not use the default constraint functions " *
        "`constraints_capacity_installed`, `constraints_opex_fixed`, and " *
        "`constraints_opex_var` either directly or through the default method " *
        "`create_node`, you can ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_level(stor_node)
    disable_logging(Warn), (@test EMC.compliance_level(stor_node)), disable_logging(Debug)
    Base.delete_method(@which level(stor_node))

    # Test the storage resource function warning
    msg = "The function `storage_resource(n)` is not working for the storage type " *
            "`TestStorage{CyclicStrategic}`.\n" *
            "If you do not use the default constraint functions " *
            "`constraints_flow_in`, `constraints_flow_out`, or " *
            "`constraints_level_aux` either directly or through the default method " *
            "`create_node`, you can ignore this warning."
    @test_logs (:warn, msg) EMC.compliance_stor_res(stor_node)
    disable_logging(Warn), (@test EMC.compliance_stor_res(stor_node)), disable_logging(Debug)
end
