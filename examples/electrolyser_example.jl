using Pkg
# Activate the local environment including EnergyModelsCompliance and EnergyModelsHydrogen
Pkg.activate(@__DIR__)
# Use dev version if run as part of tests
haskey(ENV, "EMX_TEST") && Pkg.develop(path = joinpath(@__DIR__, ".."))
# Install the dependencies.
Pkg.instantiate()

# Load of the packages. You need to load TimeStruct and EnergyModelsBase for the declaration
# of the resources and time profile, while EnergyModelsCompliance is required for the core
# functionality.
using TimeStruct
using EnergyModelsBase
using EnergyModelsCompliance
using EnergyModelsHydrogen

############################################################################################
# Step 1: Creating an instance of the newly developed node

# Define the different resources and their emission intensity in t CO₂/MWh
power = ResourceCarrier("Power", 0.0)
ng = ResourceCarrier("NG", 0.2)
h2 = ResourceCarrier("H₂", 0.0)
co2 = ResourceEmit("CO₂", 1.0)

# Create an instance of thew newly developed node
node = Reformer(
    "reformer",             # Node id
    FixedProfile(50),       # Installed capacity in MW
    FixedProfile(5),        # Variable OPEX in €/MWh
    FixedProfile(0),        # Fixed OPEX in €/MW/a
    Dict(ng => 1.25, power => 0.11),    # Input to the node with input ratio
    Dict(h2 => 1.0, co2 => 0),          # Output from the node with output ratio
    # Line above: CO2 is required as output for variable definition, but the
    # value does not matter
    Data[CaptureEnergyEmissions(0.92)], # CO₂ capture rate  as fraction

    LoadLimits(0.2, 1.0),   # Minimum and maximum load of the reformer as fraction

    # Hourly cost for startup [€/MW/h] and startup time [h]
    CommitParameters(FixedProfile(0.2), FixedProfile(5)),
    # Hourly cost for shutdown [€/MW/h] and shutdown time [h]
    CommitParameters(FixedProfile(0.2), FixedProfile(5)),
    # Hourly cost when offline [€/MW/h] and minimum off time [h]
    CommitParameters(FixedProfile(0.02), FixedProfile(10)),

    # Rate of change limit, corresponding to 10 % in both directions as fraction/h
    RampBi(FixedProfile(.1)),
)

############################################################################################
# Step 2: Identify whether the new node satisfy the existing access functions

# When you look at the values of both err_log and warn_log, you see that all values are
# false, indicating that the new node is in compliance with `EnergyModelsBase`
err_log, warn_log = compliance_element(node)

############################################################################################
# Step 3: Run the test case

# Create a simple time structure for identifying the production of the node
# The time structure is not really relevant, but it is advisable to use a `TwoLevel` structure
# with at least 10 operational periods.
𝒯 = TwoLevel(1, 1, SimpleTimes(10,1))

# Create and run the test case. co2 must be specified as we utilize it within the node for
# the emissions
test_case(node, 𝒯, warn_log; co2);
