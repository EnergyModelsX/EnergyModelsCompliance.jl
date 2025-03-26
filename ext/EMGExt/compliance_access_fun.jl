"""
    compliance_area_availability(a::Area)

Returns a `Bool` indicating whether the function
[`availability_node`](@extref EnergyModelsGeography.availability_node) is applicable for the
developed [`Area`].(@extref EnergyModelsGeography.Area)
"""
function compliance_area_availability(a::Area)
    err_b = false
    try
        n = availability_node(a)
        if !isa(n, Availability)
            @error(
                "The function `availability_node(a)` does not return an `Availability` " *
                "node as output for the area type `$(typeof(a))`.\n" *
                "As a consequence, the model will not construct."
            )
            return true
        end
    catch
        @error(
            "The function `availability_node(a)` is not working for the areatype " *
            "`$(typeof(a))`.\n" *
            "As a consequence, the model will not construct."
        )
        err_b = true
    end
    return err_b
end

"""
    EMC.compliance_capacity(tm::TransmissionMode)

Returns a `Bool` indicating whether the function
[`capacity`](@extref EnergyModelsBase.capacity) is applicable for the developed
[`Node`](@extref EnergyModelsBase.Node).

The function checks both `capacity(tm)` and `capacity(tm, t)` even if the former is not
directly used.
"""
function EMC.compliance_capacity(tm::TransmissionMode)
    warn_b = false
    try
        _ = capacity(tm)
        try
            _ = [capacity(tm, t) for t ∈ SimpleTimes(5,1)]
        catch
            @warn(
                "The function `capacity(tm, t)` is not working for the mode type " *
                "`$(typeof(tm))`.\n" *
                "If you do not use the default constraint function " *
                "`constraints_capacity_installed`, either directly or through the default " *
                "method `create_mode`, you can ignore this warning."
            )
            warn_b = true
        end
    catch
        @warn(
            "The function `capacity(tm)` is not working for the mode type `$(typeof(tm))`.\n" *
            "If you do not use the default constraint function " *
            "`constraints_capacity_installed`, either directly or through the default " *
            "method `create_mode`, you can ignore this warning."
        )
        warn_b = true
    end
    return warn_b
end

"""
    EMC.compliance_opex_var(tm::TransmissionMode)

Returns a `Bool` indicating whether the function
[`opex_var`](@extref EnergyModelsBase.opex_var) is applicable for the developed
[`TransmissionMode`](@extref EnergyModelsGeography.TransmissionMode).

The function checks both `opex_var(tm)` and `opex_var(tm, t)` even if the former is not
directly used.
"""
function EMC.compliance_opex_var(tm::TransmissionMode)
    warn_b = false
    try
        _ = opex_var(tm)
        try
            _ = [opex_var(tm, t) for t ∈ SimpleTimes(5,1)]
        catch
            @warn(
                "The function `opex_var(tm, t)` is not working for the mode type " *
                "`$(typeof(tm))`.\n" *
                "If you do not use the default constraint function `constraints_opex_var`, " *
                "either directly or through the default method `create_mode`, you can " *
                "ignore this warning."
            )
            warn_b = true
        end
    catch
        @warn(
            "The function `opex_var(tm)` is not working for the mode type `$(typeof(tm))`.\n" *
            "If you do not use the default constraint function `constraints_opex_var`, " *
            "either directly or through the default method `create_mode`, you can " *
            "ignore this warning."
        )
        warn_b = true
    end
    return warn_b
end

"""
    EMC.compliance_opex_fixed(tm::TransmissionMode)

Returns a `Bool` indicating whether the function
[`opex_fixed`](@extref EnergyModelsBase.opex_fixed) is applicable for the developed
[`TransmissionMode`](@extref EnergyModelsGeography.TransmissionMode).

The function checks both `opex_fixed(tm)` and `opex_fixed(tm, t_inv)` even if the former
is not directly used.
"""
function EMC.compliance_opex_fixed(tm::TransmissionMode)
    warn_b = false
    try
        _ = opex_fixed(tm)
        try
            _ = [opex_fixed(tm, t_inv) for t_inv ∈ strategic_periods(SimpleTimes(5,1))]
        catch
            @warn(
                "The function `opex_fixed(tm, t_inv)` is not working for the " *
                "mode type `$(typeof(tm))`.\n" *
                "If you do not use the default constraint function `constraints_opex_fixed`, " *
                "either directly or through the default method `create_mode`, you can " *
                "ignore this warning."
            )
            warn_b = true
        end
    catch
        @warn(
            "The function `opex_fixed(tm)` is not working for the mode type " *
            "`$(typeof(tm))`.\n" *
            "If you do not use the default constraint function `constraints_opex_fixed`, " *
            "either directly or through the default method `create_mode`, you can " *
            "ignore this warning."
        )
        warn_b = true
    end
    return warn_b
end

"""
    EMC.compliance_inputs(tm::TransmissionMode)

Returns a `Bool` indicating whether the function [`inputs`](@extref EnergyModelsBase.inputs)
is applicable for the developed [`TransmissionMode`](@extref EnergyModelsGeography.TransmissionMode).

The first entry of the `Tuple` is indicating whether the model can build while the second
entry is always false.
"""
function EMC.compliance_inputs(tm::TransmissionMode)
    err_b = false
    warn_b = false
    try
        𝒫 = inputs(tm)
        if !isa(𝒫, Array{<:Resource})
            @error(
                "The function `inputs(tm)` does not return an `Array{<:Resource}` as " *
                "output for the transmission mode type `$(typeof(tm))`.\n" *
                "As a consequence, the model will not construct."
            )
            return true, warn_b
        end
    catch
        @error(
            "The function `inputs(tm)` is not working for the mode type `$(typeof(tm))`.\n" *
            "As a consequence, the model will not construct."
        )
        err_b = true
    end
    return err_b, warn_b
end

"""
    EMC.compliance_outputs(tm::TransmissionMode)

Returns a `Bool` indicating whether the function [`outputs`](@extref EnergyModelsBase.outputs)
is applicable for the developed [`TransmissionMode`](@extref EnergyModelsGeography.TransmissionMode).

The first entry of the `Tuple` is indicating whether the model can build while the second
entry is always false.
"""
function EMC.compliance_outputs(tm::TransmissionMode)
    err_b = false
    warn_b = false
    try
        𝒫 = outputs(tm)
        if !isa(𝒫, Array{<:Resource})
            @error(
                "The function `outputs(tm)` does not return an `Array{<:Resource}` as " *
                "output for the transmission mode type `$(typeof(tm))`.\n" *
                "As a consequence, the model will not construct."
            )
            return true, warn_b
        end
    catch
        @error(
            "The function `outputs(tm)` is not working for the mode type `$(typeof(tm))`.\n" *
            "As a consequence, the model will not construct."
        )
        err_b = true
    end
    return err_b, warn_b
end

"""
    EMC.compliance_data(tm::TransmissionMode)

Returns a `Bool` indicating whether the function
[`mode_data`](@extref EnergyModelsGeography.mode_data) is applicable for the developed
[`TransmissionMode`](@extref EnergyModelsGeography.TransmissionMode).
"""
function EMC.compliance_data(tm::TransmissionMode)
    warn_b = false
    try
        _ = mode_data(tm)
    catch
        @warn(
            "The function `mode_data(tm)` is not working for the mode type `$(typeof(tm))`.\n" *
            "If you do not use the default functions `create_mode` and `investment_data` " *
            "(when using `EnergyModelsInvestments`),\n" *
            "you can ignore this warning."
        )
        warn_b = true
    end
    return warn_b
end

"""
    compliance_loss(tm::TransmissionMode)

Returns a `Bool` indicating whether the function
[`loss`](@extref EnergyModelsGeography.loss) is applicable for the developed
[`TransmissionMode`](@extref EnergyModelsGeography.TransmissionMode).

The function checks both `loss(tm)` and `loss(tm, t)` even if the former
is not directly used.
"""
function compliance_loss(tm::TransmissionMode)
    warn_b = false
    try
        _ = loss(tm)
        try
            _ = [loss(tm, t) for t ∈ SimpleTimes(5,1)]
        catch
            @warn(
                "The function `loss(tm, t)` is not working for the " *
                "mode type `$(typeof(tm))`.\n" *
                "If you do not use the default constraint function `constraints_trans_loss`, " *
                "either directly or through the default method `create_mode`, you can " *
                "ignore this warning."
            )
            warn_b = true
        end
    catch
        @warn(
            "The function `loss(tm)` is not working for the mode type " *
            "`$(typeof(tm))`.\n" *
            "If you do not use the default constraint function `constraints_trans_loss`, " *
            "either directly or through the default method `create_mode`, you can " *
            "ignore this warning."
        )
        warn_b = true
    end
    return warn_b
end

"""
    compliance_bidirectional(tm::TransmissionMode)

Returns a `Bool` indicating whether the function
[`is_bidirectional`](@extref EnergyModelsGeography.is_bidirectional) is applicable for the
developed [`TransmissionMode`](@extref EnergyModelsGeography.TransmissionMode).

It is not required, if you create a new [`PipeMode`](@extref EnergyModelsGeography.PipeMode).
"""
function compliance_bidirectional(tm::TransmissionMode)
    err_b = false
    try
        err_b = EMG.is_bidirectional(tm)
    catch
        @error(
            "The function `is_bidirectional(tm)` is not working for the mode type " *
            "`$(typeof(tm))`.\n" *
            "As a consequence, the model will not construct."
        )
        err_b = true
    end
    return err_b
end

"""
    compliance_con_rate(tm::TransmissionMode)
    compliance_con_rate(tm::PipeMode)

Returns a `Bool` indicating whether the function
[`consumption_rate`](@extref EnergyModelsGeography.consumption_rate) is applicable for the
developed [`TransmissionMode`](@extref EnergyModelsGeography.TransmissionMode).

It is only required, if you create a new [`PipeMode`](@extref EnergyModelsGeography.PipeMode).

The function checks both `consumption_rate(tm)` and `consumption_rate(tm, t)` even if
the former is not directly used.
"""
compliance_con_rate(tm::TransmissionMode) = false
function compliance_con_rate(tm::PipeMode)
    warn_b = false
    try
        _ = consumption_rate(tm)
        try
            _ = [consumption_rate(tm, t) for t ∈ SimpleTimes(5,1)]
        catch
            @warn(
                "The function `consumption_rate(tm, t)` is not working for the " *
                "pipe type `$(typeof(tm))`.\n" *
                "If you do not use the compute constraint function `compute_trans_in`, " *
                "you can ignore this warning."
            )
            warn_b = true
        end
    catch
        @warn(
            "The function `consumption_rate(tm)` is not working for the pipe type " *
            "`$(typeof(tm))`.\n" *
            "If you do not use the default compute function `compute_trans_in`, " *
            "you can ignore this warning."
        )
        warn_b = true
    end
    return warn_b
end
