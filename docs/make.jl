using Documenter
using DocumenterInterLinks

using TimeStruct

using EnergyModelsBase
using EnergyModelsCompliance
using EnergyModelsGeography

const EMB = EnergyModelsBase
const EMC = EnergyModelsCompliance
const EMG = EnergyModelsGeography
const EMGExt = Base.get_extension(EMC, :EMGExt)

# Copy the NEWS.md file
cp("NEWS.md", "docs/src/manual/NEWS.md"; force=true)

links = InterLinks(
    "EnergyModelsBase" => "https://energymodelsx.github.io/EnergyModelsBase.jl/stable/",
    "EnergyModelsGeography" => "https://energymodelsx.github.io/EnergyModelsGeography.jl/stable/",
)


DocMeta.setdocmeta!(
    EnergyModelsCompliance,
    :DocTestSetup,
    :(using EnergyModelsCompliance);
    recursive = true,
)

makedocs(
    sitename = "EnergyModelsCompliance",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        edit_link = "main",
        assets = String[],
        ansicolor = true,
    ),
    modules = [
        EMC,
        EMGExt,
        ],
    pages = [
        "Home" => "index.md",
        "Manual" => Any[
            "Quick Start"=>"manual/quick-start.md",
            "How-to-use"=>"manual/use.md",
            "Release notes"=>"manual/NEWS.md",
        ],
        "Library" => Any[
            "Public"=> "library/public.md",
            "Internal"=>"library/internal.md",
        ],
    ],
    plugins = [links],
    remotes = nothing,
)

deploydocs(;
    repo = "github.com/EnergyModelsX/EnergyModelsCompliance.jl.git",
)
