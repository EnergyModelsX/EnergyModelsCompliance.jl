# [How to use the package](@id man-use)

## [Introduced concepts](@id man-use-concepts)

Compliance with the `EnergyModelsX` framework requires in general that

1. developed access and identification functions are available for the new elements, and
2. the new elements can be used within the framework without providing trivial solutions.

To this end, two functions are created.

### [Access and identification functions](@id man-use-concepts-acc_ident)

The function [`compliance_element`](@ref) investigates whether the currently used functions are working for the new element.
The function automatically deduces the supertype and calls the relevant subfunctions for the given element supertype.
Aside from printing errors and warnings, it returns two `NamedTuple` in which the values correspond to Booleans.

The first `NamedTuple` corresponds to the errors from the compliance checks.
Errors are recorded when the model would not build.
An example for such a function is [`inputs`](@extref EnergyModelsBase.inputs).
This function is called within the core structure of `EnergyModelsBase`, and hence, must both be applicable and return a `Vector{<:Resource}` as output.

The second `NamedTuple` corresponds to the warnings from the compliance checks.
Warnings imply that there may be a problem, if base functionality is utilized.
In this case, the model would not construct.
However, if a developer provide new methods for their developed node, it is possible to ignore the warnings.
An example is given by the function [`opex_fixed`](@extref EnergyModelsBase.opex_fixed).
This function is only called in the function [`constraints_opex_fixed`](@extref EnergyModelsBase.constraints_opex_fixed).
Hence, if you do not use the function, you can ignore the warning

### [Test case](@id man-use-concepts-test)

The function [`test_case`](@ref) can be used to create a simple test case for the developed element.
It is implemented for both new `Node`s and `TransmissionMode`s.
It should be used for identifying whether the developed element results in a trivial solution, that is no energy conversion or transmission.

The function creates a minimum working example given an instance of the element, a simple time structure, and the `warn_log` from the function [`compliance_element`](@ref).
It then tests whether the new element is utilized.

There are however a few important caveats when using the function for `Node`s.

1. If your node includes CO₂ capture or process emissions, you **must** specify the keyword argument `co2` with your CO₂ instance.
2. If you use `JuMP.fix` for fixing storage charge or discharge variables, that is not providing a new method for `has_input` or `has_output`, some of the tests may fail.
   These functions are in this case related to `:cap_use` of a source or sink, as well a `:stor_charge_use` or `:stor_discharge_use`.
3. The function does not allow that the specified CO₂ instance (through the keyword argument `co2`) is an input to the developed node.
4. The function is not designed to evaluate a required sequence of linked nodes.
   As an example, *[CCS retrofit](https://energymodelsx.github.io/EnergyModelsCO2.jl/stable/nodes/retrofit/)* requires the direct coupling of the node with a `NetworkNode`.
   This cannot be generalized.
5. If you test a [`Sink`](@extref EnergyModelsBase.Sink) node without a fixed demand, you must provide parameters so that it is beneficial to deliver energy to the sink node.
   This can be achieved through receiving a profit.

!!! warning "Rigorous testing"
    The developed function should only be used for identifying major problems with new elements.
    It does **not** provide a rigerous test for the new element.
    This is especially relevant for the mathematical formulation, as we cannot include automated tests for unknown mathematical formulation.
    It is hence necessary that you test your element further with changes in the input representing your specific element.

## [Examples](@id man-use-examples)

For the content of the individual examples, see the *[examples](https://github.com/EnergyModelsX/EnergyModelsCompliance.jl/tree/main/examples)* directory in the project repository.
The examples are commented to show how the package can be utilized.

!!! note
    The examples should provide you with an idea how to call the introduced functions.
    They use existing elements from different `EnergyModelsX` packages which are complying with the framework.
    They hence illustrate more the required input to the functions.
