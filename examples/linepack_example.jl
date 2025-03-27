using Pkg
# Activate the local environment including EnergyModelsCompliance and EnergyModelsGeography
Pkg.activate(@__DIR__)
# Use dev version if run as part of tests
haskey(ENV, "EMX_TEST") && Pkg.develop(path = joinpath(@__DIR__, ".."))
# Install the dependencies.
Pkg.instantiate()

# Load of the packages. You need to load TimeStruct and EnergyModelsBase for the declaration
# of the resources and time profile, while EnergyModelsCompliance is required for the core
# functionality.
# EnergyModelsGeography is furthermore required to load the extension for testing
# TransmissionModes.
using TimeStruct
using EnergyModelsBase
using EnergyModelsCompliance
using EnergyModelsGeography

############################################################################################
# Step 1: Creating an instance of the newly developed node

# Define the different resources and their emission intensity in t CO₂/MWh
power = ResourceCarrier("Power", 0.0)
h2_hp = ResourceCarrier("H₂ʰᵖ", 0.0)
h2_lp = ResourceCarrier("H₂ˡᵖ", 0.0)
co2 = ResourceEmit("CO₂", 1.0)

# Create an instance of the newly developed tranmission mode
tm = PipeLinepackSimple(
    "pipeline",         # Transmission mode id
    h2_hp,              # Input to the transmisison mode
    h2_lp,              # Output from the transmisison mode
    power,              # Consumed resource required for transporting the main resource
    FixedProfile(0.05), # Consumption rate in MW/MW
    FixedProfile(50),   # Capacity in MW
    FixedProfile(0.01), # Loss as fraction
    FixedProfile(0.1),  # Variable OPEX in €/MWh
    FixedProfile(1.0),  # Fixed OPEX in €/MW/a
    0.1,                # Storage capacity as a fraction of the transmission capacity in MWh/MW
)

############################################################################################
# Step 2: Identify whether the new node satisfy the existing access functions

# When you look at the values of both err_log and warn_log, you see that all values are
# false, indicating that the new node is in compliance with `EnergyModelsBase` and
# `EnergyModelsGeography`
err_log, warn_log = compliance_element(tm)

############################################################################################
# Step 3: Run the test case

# Create a simple time structure for identifying the production of the node
# The time structure is not really relevant, but it is advisable to use a `TwoLevel` structure
# with at least 10 operational periods.
𝒯 = TwoLevel(1, 1, SimpleTimes(10,1))

# Create and run the test case. co2 must not be specified (but can) as we do not utilize it
# within the transmission mode for the emissions.
test_case(tm, 𝒯, warn_log; co2);
