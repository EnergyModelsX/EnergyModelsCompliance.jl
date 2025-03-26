# [Public library](@id lib-pub)

## [Index](@id lib-pub-idx)

```@index
Pages = ["public.md"]
```

## [`Node`s and `Link`s](@id lib-pub-node_link)

```@docs
compliance_element(n::EMB.Node)
test_case(n::Source, 𝒯::TimeStructure, warn; co2::ResourceEmit = ResourceEmit("CO₂", 1.0))
```

## [`Area`s and `TransmissionMode`s](@id lib-pub-area_mode)

```@docs
compliance_element(a::Area)
test_case(tm::TransmissionMode, 𝒯::TimeStructure, warn; co2::ResourceEmit = ResourceEmit("CO₂", 1.0))
```
