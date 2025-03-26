# [Types](@id lib-int)

## [Index](@id lib-int-idx)

```@index
Pages = ["types.md"]
```

## [`Node`s and `Link`s](@id lib-int-node_link)

```@docs
EMC.compliance_capacity(n::EMB.Node)
EMC.compliance_opex_var(n::EMB.Node)
EMC.compliance_opex_fixed(n::EMB.Node)
EMC.compliance_inputs(n::EMB.Node)
EMC.compliance_outputs(n::EMB.Node)
EMC.compliance_data(n::EMB.Node)
EMC.compliance_level
EMC.compliance_stor_res
```

## [`Area`s and `TransmissionMode`s](@id lib-int-area_mode)

```@docs
EMGExt.compliance_area_availability
EMC.compliance_capacity(tm::TransmissionMode)
EMC.compliance_opex_var(tm::TransmissionMode)
EMC.compliance_opex_fixed(tm::TransmissionMode)
EMC.compliance_inputs(tm::TransmissionMode)
EMC.compliance_outputs(tm::TransmissionMode)
EMC.compliance_data(tm::TransmissionMode)
EMGExt.compliance_loss
EMGExt.compliance_bidirectional
EMGExt.compliance_con_rate
```
