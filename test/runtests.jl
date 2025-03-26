using TimeStruct
using EnergyModelsBase
using EnergyModelsGeography
using EnergyModelsCompliance
using InteractiveUtils
using Logging
using Test

const EMB = EnergyModelsBase
const EMC = EnergyModelsCompliance
const EMG = EnergyModelsGeography
const EMGExt = Base.get_extension(EMC, :EMGExt)
const TS = TimeStruct

const TEST_ATOL = 1e-6
ENV["EMX_TEST"] = true # Set flag for example scripts to check if they are run as part of the tests

@testset "Compliance" begin
    include("emb_test_types.jl")    # Default test types to be used

    @testset "Compliance - EMB access functions" begin
        include("test_emb_access_fun.jl")
    end

    @testset "Compliance - EMB elements" begin
        include("test_emb_element.jl")
    end

    @testset "Compliance - EMB test cases" begin
        include("test_emb_mwe.jl")
    end

    include("emg_test_types.jl")    # Default test types to be used

    @testset "Compliance - EMG access functions" begin
        include("test_emg_access_fun.jl")
    end
end
