# Release notes

## Version 0.1.0 (2025-03-27)

Initial version of the package:

* Inclusion of compliance checks for new `Node`s, `Link`s, `Area`s, and `TransmissionMode`s:
  * The checks highlight whether a `Node`, `Link`, `Area`s or `TransmissionMode` can work with existing functions.
  * The checks mostly provide warnings, as errors are dependent on the chosen functions from `EnergyModelsBase` or `EnergyModelsGeography`.

* Inclusion of simple test cases for `Node` and `TransmissionMode`:
  * The test cases can be used to see whether the couplings in `EnergyModelsBase` and `EnergyModelsGeography` are working.
  * The test cases ensure that the capacity of the elements is utilized.
