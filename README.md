# EnergyModelsCompliance

[![DOI](https://joss.theoj.org/papers/10.21105/joss.06619/status.svg)](https://doi.org/10.21105/joss.06619)
[![Build Status](https://github.com/EnergyModelsX/EnergyModelsCompliance.jl/workflows/CI/badge.svg)](https://github.com/EnergyModelsX/EnergyModelsCompliance.jl/actions?query=workflow%3ACI)
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://energymodelsx.github.io/EnergyModelsCompliance.jl/stable/)
[![In Development](https://img.shields.io/badge/docs-dev-blue.svg)](https://energymodelsx.github.io/EnergyModelsCompliance.jl/dev/)

`EnergyModelsCompliance` is an extension package within the `EnergyModelsX` (`EMX`) framework.
It provides the user with the functionality for identifying potential problems in newly developed elements for the `EMX` framework.
While it can be used as a first step for checking new elements, thorough tests of new elements are always recommended to test whether the developed elements fulfill the needs.

## Usage

The usage of the package is best illustrated through the commented [`examples`](examples).
The examples showcase how the functions from `EnergyModelsCompliance` can be utilized to identify whether your newly developed element can be incorporated in `EnergyModelsBase` or `EnergyModelsGeography` models.

> [!WARNING]
> The package is not yet registered.
> It is hence necessary to first clone the package and manually add the package to the example environment through:
>
> ```julia
> ] dev ..
> ```

## Cite

If you find `EnergyModelsCompliance` useful in your work, we kindly request that you cite the following [publication](https://doi.org/10.21105/joss.06619):

```bibtex
@article{hellemo2024energymodelsx,
  title = {EnergyModelsX: Flexible Energy Systems Modelling with Multiple Dispatch},
  author = {Hellemo, Lars and B{\o}dal, Espen Flo and Holm, Sigmund Eggen and Pinel, Dimitri and Straus, Julian},
  journal = {Journal of Open Source Software},
  volume = {9},
  number = {97},
  pages = {6619},
  year = {2024},
  doi = {https://doi.org/10.21105/joss.06619},
}
```

## Project Funding

The development of `EnergyModelsCompliance` was funded by the European Union’s Horizon Europe research and innovation programme in the project [iDesignRES](https://idesignres.eu/) under grant agreement [101095849](https://doi.org/10.3030/101095849).
