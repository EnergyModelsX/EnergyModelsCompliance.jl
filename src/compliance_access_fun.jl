"""
    compliance_capacity(n::EMB.Node)

Returns a `Bool` indicating whether the function
[`capacity`](@extref EnergyModelsBase.capacity) is applicable for the developed
[`Node`](@extref EnergyModelsBase.Node).

The function checks both `capacity(n)` and `capacity(n, t)` even if the former is not
directly used.
"""
function compliance_capacity(n::EMB.Node)
    warn_b = false
    try
        _ = capacity(n)
        try
            _ = [capacity(n, t) for t ∈ SimpleTimes(5,1)]
        catch
            @warn(
                "The function `capacity(n, t)` is not working for the node type " *
                "`$(typeof(n))`.\n" *
                "If you do not use the default constraint function " *
                "`constraints_capacity_installed`, either directly or through the default " *
                "method `create_node`, you can ignore this warning."
            )
            warn_b = true
        end
    catch
        @warn(
            "The function `capacity(n)` is not working for the node type `$(typeof(n))`.\n" *
            "If you do not use the default constraint function " *
            "`constraints_capacity_installed`, either directly or through the default " *
            "method `create_node`, you can ignore this warning."
        )
        warn_b = true
    end
    return warn_b
end

"""
    compliance_opex_var(n::EMB.Node)
    compliance_opex_var(n::Sink)

Returns a `Bool` indicating whether the function
[`opex_var`](@extref EnergyModelsBase.opex_var) is applicable for the developed
[`Node`](@extref EnergyModelsBase.Node) or alternatively the functions
[`surplus_penalty`](@extref EnergyModelsBase.surplus_penalty) and
[`deficit_penalty`](@extref EnergyModelsBase.surplus_penalty).

The function checks both `opex_var(n)` (`surplus_penalty(n)` and `deficit_penalty(n)`)
and `opex_var(n, t)` (`surplus_penalty(n, t)` and `deficit_penalty(n, t)`) even if
the former is not directly used.
"""
function compliance_opex_var(n::EMB.Node)
    warn_b = false
    try
        _ = opex_var(n)
        try
            _ = [opex_var(n, t) for t ∈ SimpleTimes(5,1)]
        catch
            @warn(
                "The function `opex_var(n, t)` is not working for the node type " *
                "`$(typeof(n))`.\n" *
                "If you do not use the default constraint function `constraints_opex_var`, " *
                "either directly or through the default method `create_node`, you can " *
                "ignore this warning."
            )
            warn_b = true
        end
    catch
        @warn(
            "The function `opex_var(n)` is not working for the node type `$(typeof(n))`.\n" *
            "If you do not use the default constraint function `constraints_opex_var`, " *
            "either directly or through the default method `create_node`, you can " *
            "ignore this warning."
        )
        warn_b = true
    end
    return warn_b
end
function compliance_opex_var(n::Sink)
    warn_b = false
    try
        _ = surplus_penalty(n)
        try
            _ = [surplus_penalty(n, t) for t ∈ SimpleTimes(5,1)]
        catch
            @warn(
                "The function `surplus_penalty(n, t)` is not working for the node type " *
                "`$(typeof(n))`.\n" *
                "If you do not use the default constraint function `constraints_opex_var`, " *
                "either directly or through the default method `create_node`, you can " *
                "ignore this warning."
            )
            warn_b = true
        end
    catch
        @warn(
            "The function `surplus_penalty(n)` is not working for the node type " *
            "`$(typeof(n))`.\n" *
            "If you do not use the default constraint function `constraints_opex_var`, " *
            "either directly or through the default method `create_node`, you can " *
            "ignore this warning."
        )
        warn_b = true
    end
    try
        _ = deficit_penalty(n)
        try
            _ = [deficit_penalty(n, t) for t ∈ SimpleTimes(5,1)]
        catch
            @warn(
                "The function `deficit_penalty(n, t)` is not working for the node type " *
                "`$(typeof(n))`.\n" *
                "If you do not use the default constraint function `constraints_opex_var`, " *
                "either directly or through the default method `create_node`, you can " *
                "ignore this warning."
            )
            warn_b = true
        end
    catch
        @warn(
            "The function `deficit_penalty(n)` is not working for the node type " *
            "`$(typeof(n))`.\n" *
            "If you do not use the default constraint function `constraints_opex_var`, " *
            "either directly or through the default method `create_node`, you can " *
            "ignore this warning."
        )
        warn_b = true
    end
    return warn_b
end

"""
    compliance_opex_fixed(n::EMB.Node)
    compliance_opex_fixed(n::Sink)

Returns a `Bool` indicating whether the function
[`opex_fixed`](@extref EnergyModelsBase.opex_fixed) is applicable for the developed
[`Node`](@extref EnergyModelsBase.Node).

The function checks both `opex_fixed(n)` and `opex_fixed(n, t_inv)` even if the former
is not directly used.
"""
function compliance_opex_fixed(n::EMB.Node)
    warn_b = false
    try
        _ = opex_fixed(n)
        try
            _ = [opex_fixed(n, t_inv) for t_inv ∈ strategic_periods(SimpleTimes(5,1))]
        catch
            @warn(
                "The function `opex_fixed(n, t_inv)` is not working for the " *
                "node type `$(typeof(n))`.\n" *
                "If you do not use the default constraint function `constraints_opex_fixed`, " *
                "either directly or through the default method `create_node`, you can " *
                "ignore this warning."
            )
            warn_b = true
        end
    catch
        @warn(
            "The function `opex_fixed(n)` is not working for the node type " *
            "`$(typeof(n))`.\n" *
            "If you do not use the default constraint function `constraints_opex_fixed`, " *
            "either directly or through the default method `create_node`, you can " *
            "ignore this warning."
        )
        warn_b = true
    end
    return warn_b
end
compliance_opex_fixed(n::Sink) = false

"""
    compliance_inputs(n::EMB.Node)

Returns a `Tuple{Bool}` indicating whether the function
[`inputs`](@extref EnergyModelsBase.inputs) is applicable for the developed
[`Node`](@extref EnergyModelsBase.Node).

The first entry of the `Tuple` is indicating whether the model can build while the second
entry indicates whether problems with existing base functions may occur.

The function checks both `inputs(n)` and `inputs(n, p)`.
"""
function compliance_inputs(n::EMB.Node)
    err_b = false
    warn_b = false
    try
        𝒫 = inputs(n)
        if !isa(𝒫, Array{<:Resource})
            @error(
                "The function `inputs(n)` does not return an `Array{<:Resource}` as " *
                "output for the node type `$(typeof(n))`.\n" *
                "As a consequence, the model will not construct."
            )
            return true, warn_b
        end
        try
            _ = [inputs(n, p) for p ∈ 𝒫]
        catch
            @warn(
                "The function `inputs(n, p)` is not working for the node type " *
                "`$(typeof(n))`.\n" *
                "If you do not use the default constraint function `constraints_flow_in`, " *
                "either directly or through the default method `create_node`, you can " *
                "ignore this warning."
            )
            warn_b = true
        end
    catch
        @error(
            "The function `inputs(n)` is not working for the node type `$(typeof(n))`.\n" *
            "As a consequence, the model will not construct."
        )
        err_b = true
    end
    return err_b, warn_b
end

"""
    compliance_outputs(n::EMB.Node)

Returns a `Tuple{Bool}` indicating whether the function
[`outputs`](@extref EnergyModelsBase.outputs) is applicable for the developed
[`Node`](@extref EnergyModelsBase.Node).

The first entry of the `Tuple` is indicating whether the model can build while the second
entry indicates whether problems with existing base functions may occur.

The function checks both `outputs(n)` and `outputs(n, p)`.
"""
function compliance_outputs(n::EMB.Node)
    err_b = false
    warn_b = false
    try
        𝒫 = outputs(n)
        if !isa(𝒫, Array{<:Resource})
            @error(
                "The function `outputs(n)` does not return an `Array{<:Resource}` as " *
                "output for the node type `$(typeof(n))`.\n" *
                "As a consequence, the model will not construct."
            )
            return true, warn_b
        end
        try
            _ = [outputs(n, p) for p ∈ 𝒫]
        catch
            @warn(
                "The function `outputs(n, p)` is not working for the node type " *
                "`$(typeof(n))`.\n" *
                "If you do not use the default constraint function `constraints_flow_out`, " *
                "either directly or through the default method `create_node`, you can " *
                "ignore this warning."
            )
            warn_b = true
        end
    catch
        @error(
            "The function `outputs(n)` is not working for the node type `$(typeof(n))`.\n" *
            "As a consequence, the model will not construct."
        )
        err_b = true
    end
    return err_b, warn_b
end

"""
    compliance_data(n::EMB.Node)

Returns a `Bool` indicating whether the function
[`node_data`](@extref EnergyModelsBase.node_data) is applicable for the developed
[`Node`](@extref EnergyModelsBase.Node).
"""
function compliance_data(n::EMB.Node)
    warn_b = false
    try
        _ = node_data(n)
    catch
        @warn(
            "The function `node_data(n)` is not working for the node type `$(typeof(n))`.\n" *
            "If you do not use the default functions `create_node` and `investment_data` " *
            "(when using `EnergyModelsInvestments`),\n" *
            "you can ignore this warning."
        )
        warn_b = true
    end
    return warn_b
end

"""
    compliance_level(n::Storage)

Returns a `Bool` indicating whether the function
[`level`](@extref EnergyModelsBase.level) is applicable for the developed
[`Storage`](@extref EnergyModelsBase.Storage).
"""
function compliance_level(n::T) where {T<:Storage}
    warn_b = false
    try
        level_val = level(n)
        field_id = filter(id -> getproperty(n, id) == level_val, fieldnames(T))[1]
        if !(fieldtype(T, field_id) <: EMB.AbstractStorageParameters)
            @warn(
                "The fieldtype of the field returned by the function `level(n)` is not an " *
                "`AbstractStorageParameters` for the storage type `$(T)`.\n" *
                "If you do not use the default constraint functions " *
                "`constraints_capacity_installed`, `constraints_opex_fixed`, and " *
                "`constraints_opex_var` either directly or through the default method " *
                "`create_node`, you can ignore this warning."
            )
            warn_b = true
        end
    catch
        @warn(
            "The function `level(n)` is not working for the storage type `$(T)`.\n" *
            "If you do not use the default constraint functions " *
            "`constraints_capacity_installed`, `constraints_opex_fixed`, and " *
            "`constraints_opex_var` either directly or through the default method " *
            "`create_node`, you can ignore this warning."
        )
        warn_b = true
    end
    return warn_b
end

"""
    compliance_stor_res(n::Storage)

Returns a `Bool` indicating whether the function
[`storage_resource`](@extref EnergyModelsBase.storage_resource) is applicable for the
developed [`Storage`](@extref EnergyModelsBase.Storage).
"""
function compliance_stor_res(n::Storage)
    warn_b = false
    try
        _ = storage_resource(n)
    catch
        @warn(
            "The function `storage_resource(n)` is not working for the storage type " *
            "`$(typeof(n))`.\n" *
            "If you do not use the default constraint functions " *
            "`constraints_flow_in`, `constraints_flow_out`, or " *
            "`constraints_level_aux` either directly or through the default method " *
            "`create_node`, you can ignore this warning."
        )
        warn_b = true
    end
    return warn_b
end
