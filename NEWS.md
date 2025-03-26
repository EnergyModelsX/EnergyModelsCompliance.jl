# Release notes

## Version 0.1.0 (2025-03-xx)

Initial version of the package:

* Inclusion of compliance checks for new `Node`s, `Link`s, `Area`s, and `TransmissionMode`s:
  * Checks highlight whether a `Node` or `Link` can work with existing functions or have a new method.
  * Checks mostly provide warnings, as errors are dependent on the chosen functions from `EnergyModelsBase` or `EnergyModelsGeography`.

* Inclusion of simple test case for `Node` and `TransmissionMode`:
  * Test case can be used to see whether the couplings in `EnergyModelsBase` `EnergyModelsGeography` are working.
  * Tests that capacity is utilized.
