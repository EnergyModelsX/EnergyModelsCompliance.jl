using TimeStruct
using EnergyModelsBase
using EnergyModelsCompliance
using InteractiveUtils
using Logging
using Test

const EMB = EnergyModelsBase
const EMC = EnergyModelsCompliance
const TS = TimeStruct

const TEST_ATOL = 1e-6
ENV["EMX_TEST"] = true # Set flag for example scripts to check if they are run as part of the tests

@testset "Compliance" begin
end
