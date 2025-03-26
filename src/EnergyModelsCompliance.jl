module EnergyModelsCompliance

using TimeStruct
using EnergyModelsBase
using Test
using JuMP
using HiGHS

const EMB = EnergyModelsBase
const TS = TimeStruct

include("compliance_access_fun.jl")
include("compliance_ele.jl")
include("mwe_case.jl")

export compliance_element
export test_case

end
