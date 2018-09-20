using Conda, Compat, VersionParsing
using Conda: _set_conda_env, bin_dir
using Compat
using Compat: @info
using Compat.Test

exe = Compat.Sys.iswindows() ? ".exe" : ""

Conda.update()

env = :test_conda_jl
@test Conda.exists("curl", env)
Conda.add("curl", env)

@testset "Install Python package" begin
    Conda.add("python", env)
    pythonpath = joinpath(Conda.python_dir(env), "python" * exe)
    @test isfile(pythonpath)

    cmd = _set_conda_env(`$pythonpath -c "import zmq"`, env)
    @test_throws Exception run(cmd)
    @test !success(cmd)
    Conda.add("pyzmq", env)
    run(cmd)
end

curlvers = Conda.version("curl",env)
@test curlvers >= v"5.0"
@test Conda.exists("curl==$curlvers", env)

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
