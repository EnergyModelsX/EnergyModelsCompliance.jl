@testset "Run examples" begin
    exdir = joinpath(@__DIR__, "../examples")
    files = filter(endswith(".jl"), readdir(exdir))
    for file ∈ files
        @testset "Example $file" begin
            redirect_stdio(stdout = devnull) do
                include(joinpath(exdir, file))
            end
        end
    end
    Pkg.activate(@__DIR__)
end
