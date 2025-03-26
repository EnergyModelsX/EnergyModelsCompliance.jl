module EMGExt

using TimeStruct
using EnergyModelsBase
using EnergyModelsCompliance
using EnergyModelsGeography
using Test
using JuMP
using HiGHS

const EMB = EnergyModelsBase
const EMG = EnergyModelsGeography
const EMC = EnergyModelsCompliance
const TS = TimeStruct

include("compliance_access_fun.jl")
include("compliance_ele.jl")

end
