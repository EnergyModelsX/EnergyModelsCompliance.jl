"""
    compliance_element(n::EMB.Node)
    compliance_element(n::Storage)
    compliance_element(l::Link)

Returns two `NamedTuple`s corresponding to respectively the errors and warnings of the testing of
the indivdiual test functions. The called test functions are dependent on the chosen type:

!!! note "Node"
    The following functions are called:

    - [`compliance_capacity`](@ref), not for `Storage` nodes,
    - [`compliance_opex_var`](@ref), not for `Storage` nodes,
    - [`compliance_opex_fixed`](@ref), not for `Storage` nodes,
    - [`compliance_inputs`](@ref), if the node has an input, checked through the function
      [`has_input`](@extref EnergyModelsBase.has_input),
    - [`compliance_outputs`](@ref), if the node has an output, checked through the function
      [`has_output`](@extref EnergyModelsBase.has_output),
    - [`compliance_data`](@ref),
    - [`compliance_level`](@ref) for `Storage` nodes, including a check that the `level` is
      corresponding to an [`AbstractStorageParameters`](@extref EnergyModelsBase.AbstractStorageParameters), and
    - [`compliance_stor_res`](@ref) for `Storage` nodes.

!!! tip "Link"
    `Link`s are more flexible than `Node`s. As a consequence, we do not check whether the
    access functions are working. Instead, it is checked whether `Link`s have the fields
    `:from` and `:to` and that either of them is restricted to a n.
"""
function compliance_element(n::EMB.Node)
    # Call the individual access functions for a developed Node
    warn_cap = compliance_capacity(n)
    warn_opex_var = compliance_opex_var(n)
    warn_opex_fixed = compliance_opex_fixed(n)
    if has_input(n)
        err_in, warn_in = compliance_inputs(n)
    else
        err_in, warn_in = false, false
    end
    if has_output(n)
        err_out, warn_out = compliance_outputs(n)
    else
        err_out, warn_out = false, false
    end
    warn_data = compliance_data(n)

    return (inputs=err_in, outputs=err_out),
        (capacity=warn_cap, opex_var=warn_opex_var, opex_fixed=warn_opex_fixed,
        inputs=warn_in, outputs=warn_out, data=warn_data)
end
function compliance_element(n::Storage)
    # Call the individual access functions for a developed Node
    if has_input(n)
        err_in, warn_in = compliance_inputs(n)
    else
        err_in, warn_in = false, false
    end
    if has_output(n)
        err_out, warn_out = compliance_outputs(n)
    else
        err_out, warn_out = false, false
    end
    warn_data = compliance_data(n)
    warn_level = compliance_level(n)
    warn_stor_res = compliance_stor_res(n)

    return (inputs=err_in, outputs=err_out),
        (inputs=warn_in, outputs=warn_out, data=warn_data, level=warn_level,
        stor_res=warn_stor_res)
end
function compliance_element(l::T) where {T<:Link}
    fields = fieldnames(T)
    has_to = :to ∈ fields
    node_to = true
    if !has_to
        @error(
            "The developed link `$(T)` does not have the field `:to`.\n" *
            "As a consequence, the model will not construct."
        )
    else
        if !(fieldtype(T, :to) <: EMB.Node)
            @error(
                "The field `:to` in the developed link `$(T)` is not restricted to " *
                "`EMB.Node`.\n" *
                "As a consequence, the model will not construct."
            )
            node_to = false
        end
    end
    has_from = :from ∈ fields
    node_from = true
    if !has_from
        @error(
            "The developed link `$(T)` does not have the field `:from`.\n" *
            "As a consequence, the model will not construct."
        )
    else
        if !(fieldtype(T, :from) <: EMB.Node)
            @error(
                "The field `:from` in the developed link `$(T)` is not restricted to " *
                "`EMB.Node`.\n" *
                "As a consequence, the model will not construct."
            )
            node_from = false
        end
    end
    return (has_to=has_to, has_from=has_from, node_to=node_to, node_from=node_from),
        NamedTuple()
end
