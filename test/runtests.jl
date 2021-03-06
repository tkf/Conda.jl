using Conda, BinDeps, Compat, VersionParsing
using Compat.Test

Conda.update()

env = :test_conda_jl
@test Conda.exists("curl", env)
Conda.add("curl", env)

curlvers = Conda.version("curl",env)
@test curlvers >= v"5.0"
@test Conda.exists("curl==$curlvers", env)

exe = Compat.Sys.iswindows() ? ".exe" : ""

curl_path = joinpath(Conda.bin_dir(env), "curl" * exe)
@test isfile(curl_path)

@test "curl" in Conda.search("cu*", env)

Conda.rm("curl", env)
@test !isfile(curl_path)

pythonpath = joinpath(Conda.PYTHONDIR, "python" * exe)
@test isfile(pythonpath)
pyversion = read(`$pythonpath -c "import sys; print(sys.version)"`, String)
@test pyversion[1:1] == Conda.MINICONDA_VERSION

Conda.add_channel("foo", env)
@test Conda.channels(env) == ["foo", "defaults"]
# Testing that calling the function twice do not fail
Conda.add_channel("foo", env)

Conda.rm_channel("foo", env)
@test Conda.channels(env) == ["defaults"]
