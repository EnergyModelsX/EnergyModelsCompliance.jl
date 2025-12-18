"""
    EMC.compliance_element(a::Area)
    EMC.compliance_element(tm::TransmissionMode)

Returns two `NamedTuple`s corresponding to respectively the errors and warnings of the testing of
the indivdiual test functions. The called test functions are dependent on the chosen type:

!!! note "TransmissionMode"
    The following functions are called:

    - [`EMC.compliance_capacity`](@ref),
    - [`EMC.compliance_opex_var`](@ref), if the `TransmissionMode` has OPEX, checked through the
      function [`has_opex`](@extref EnergyModelsBase.has_opex),
    - [`EMC.compliance_opex_fixed`](@ref), if the `TransmissionMode` has OPEX, checked through the
      function [`has_opex`](@extref EnergyModelsBase.has_opex),
    - [`EMC.compliance_inputs`](@ref),
    - [`EMC.compliance_outputs`](@ref),
    - [`EMC.compliance_data`](@ref),
    - [`compliance_loss`](@ref) for [`PipeMode`](@extref EnergyModelsGeography.PipeMode),
    - [`compliance_con_rate`](@ref) for [`PipeMode`](@extref EnergyModelsGeography.PipeMode), and
    - [`compliance_bidirectional`](@ref).

    !!! warning
        [`EMC.compliance_data`](@ref) is in the current stage removed due to changes to the
        handling of `ExtensionData`.

!!! note "Areas"
    The following function is called:

    - [`compliance_area_availability`](@ref).
"""
function EMC.compliance_element(a::Area)
    err_avail = compliance_area_availability(a)
    return (availability=err_avail,), NamedTuple()
end
function EMC.compliance_element(tm::TransmissionMode)
    # Call the individual access functions for a developed tm
    warn_cap = EMC.compliance_capacity(tm)
    warn_opex_var = has_opex(tm) ? EMC.compliance_opex_var(tm) : false
    warn_opex_fixed = has_opex(tm) ? EMC.compliance_opex_fixed(tm) : false
    err_in, warn_in = EMC.compliance_inputs(tm)
    err_out, warn_out = EMC.compliance_outputs(tm)
    # warn_data = EMC.compliance_data(tm)
    warn_data = false

    warn_loss = compliance_loss(tm)
    warn_con_rate = compliance_con_rate(tm)
    err_bi = compliance_bidirectional(tm)

    return (inputs=err_in, outputs=err_out, bidirectional=err_bi),
        (capacity=warn_cap, opex_var=warn_opex_var, opex_fixed=warn_opex_fixed,
        inputs=warn_in, outputs=warn_out, loss=warn_loss, consumption_rate=warn_con_rate,
        data=warn_data)
end
