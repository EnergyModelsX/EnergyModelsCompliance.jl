
@testset "Nodes" begin
    disable_logging(Error)
    # Test for a standard network node with variations
    node = TestNode("1")
    err_log, warn_log = compliance_element(node)
    @test all(err_log == (inputs=true, outputs=true))
    @test all(
        warn_log == (capacity=true, opex_var=true, opex_fixed=true,
            inputs=false, outputs=false, data=true)
    )
    EMB.outputs(n::TestNode) = [ResourceCarrier("test", 0.0)]
    err_log, warn_log = compliance_element(node)
    @test all(err_log == (inputs=true, outputs=false))
    @test all(
        warn_log == (capacity=true, opex_var=true, opex_fixed=true,
            inputs=false, outputs=true, data=true)
    )
    Base.delete_method(@which outputs(node))

    # Test for a storage node with variations
    stor_node = TestStorage{CyclicStrategic}("2", 1)
    err_log, warn_log = compliance_element(stor_node)
    @test all(err_log == (inputs=true, outputs=true))
    @test all(
        warn_log == (inputs=false, outputs=false, data=true, level=true, stor_res=true)
    )
    EMB.node_data(n::TestStorage) = Data[]
    err_log, warn_log = compliance_element(stor_node)
    @test all(err_log == (inputs=true, outputs=true))
    @test all(
        warn_log == (inputs=false, outputs=false, data=false, level=true, stor_res=true)
    )
    Base.delete_method(@which node_data(stor_node))

    disable_logging(Debug)
end

@testset "Links" begin
    struct TestLinkNone <: Link
    end
    struct TestLinkTo <: Link
        to::EMB.Node
    end
    struct TestLinkFrom <: Link
        from::EMB.Node
    end
    struct TestLinkNodeTo <: Link
        to::EMB.Node
        from
    end
    struct TestLinkNodeFrom <: Link
        to
        from::EMB.Node
    end

    # Test the logs from the links
    msg = "The developed link `TestLinkTo` does not have the field `:from`.\n" *
        "As a consequence, the model will not construct."
    @test_logs (:error, msg) compliance_element(TestLinkTo(TestNode("1")))
    msg = "The developed link `TestLinkFrom` does not have the field `:to`.\n" *
        "As a consequence, the model will not construct."
    @test_logs (:error, msg) compliance_element(TestLinkFrom(TestNode("1")))
    msg = "The field `:from` in the developed link `TestLinkNodeTo` is not restricted to " *
        "`EMB.Node`.\n" *
        "As a consequence, the model will not construct."
    @test_logs (:error, msg) compliance_element(TestLinkNodeTo(TestNode("1"), 1))
    msg = "The field `:to` in the developed link `TestLinkNodeFrom` is not restricted to " *
        "`EMB.Node`.\n" *
        "As a consequence, the model will not construct."
    @test_logs (:error, msg) compliance_element(TestLinkNodeFrom(1, TestNode("1")))

    # Test the correct output
    disable_logging(Error)
    field_none, _ = compliance_element(TestLinkNone())
    field_to, _ = compliance_element(TestLinkTo(TestNode("1")))
    field_from, _ = compliance_element(TestLinkFrom(TestNode("1")))
    field_to_node, _ = compliance_element(TestLinkNodeTo(TestNode("1"), 1))
    field_from_node, _ = compliance_element(TestLinkNodeFrom(1, TestNode("1")))
    disable_logging(Debug)
    @test all(field_none == (has_to=false, has_from=false, node_to=true, node_from=true))
    @test all(field_to == (has_to=true, has_from=false, node_to=true, node_from=true))
    @test all(field_from == (has_to=false, has_from=true, node_to=true, node_from=true))
    @test all(field_to_node == (has_to=true, has_from=true, node_to=true, node_from=false))
    @test all(field_from_node == (has_to=true, has_from=true, node_to=false, node_from=true))
end
