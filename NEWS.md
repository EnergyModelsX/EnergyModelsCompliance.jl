# Release notes

## Version 0.1.0 (2025-03-xx)

Initial version of the package:

* Inclusion of compliance checks for new `Node`s and `Link`s
  * Checks highlight whether a `Node` or `Link` can work with existing functions or have a new method.
  * Checks mostly provide warnings, as errors are dependent on the chosen functions from `EnergyModelsBase`

* Inclusion of simple test case for `Node`
  * Test case can be used to see whether the couplings in `EnergyModelsBase` are working.
  * Tests that capacity is utilized.
