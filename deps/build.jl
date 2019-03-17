using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libsass"], :libsass_so),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/piever/SassBuilder/releases/download/v3.5.5-1"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/libsass.v3.5.5.aarch64-linux-gnu.tar.gz", "6c04e15fe9485207cd7cc1327b87b883c85d9f0e0e5f8aafd81b5244f9db4a80"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/libsass.v3.5.5.aarch64-linux-musl.tar.gz", "60bc726ea57191c03acf8ac96c6f0f5630515b73ca0a7b86299909b328efa448"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/libsass.v3.5.5.arm-linux-gnueabihf.tar.gz", "024822bbf15fc82c18966c0e16d17fab8792757328ceb44518752e52c02f6807"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/libsass.v3.5.5.arm-linux-musleabihf.tar.gz", "7ead3aa331cd2082ef3e14f81101c4abebe2cd6d1ae4133813d1c01ab064d34c"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/libsass.v3.5.5.i686-linux-gnu.tar.gz", "0afce3dced23efa55a7ddc762cb3064fabcea7fcd37ef3c72f2a290f38d24307"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/libsass.v3.5.5.i686-linux-musl.tar.gz", "b46d2f1c92dfa3ff4fc028380da00ac1d0b79b019d5694d6f79fa378e7208e92"),
    Windows(:i686) => ("$bin_prefix/libsass.v3.5.5.i686-w64-mingw32.tar.gz", "bad6acf124d6649b8ec4b021cdfd88aecfc4151734f2c5ce1683fda07f6fb236"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/libsass.v3.5.5.powerpc64le-linux-gnu.tar.gz", "fcfc2d96cbead84577cdf2d8e9810612037d8a67fc4861bb7e92d2009edee588"),
    MacOS(:x86_64) => ("$bin_prefix/libsass.v3.5.5.x86_64-apple-darwin14.tar.gz", "a2f8768639f49a7444fd815b6a4e572c650495059272c70af73dec149fde7ee0"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/libsass.v3.5.5.x86_64-linux-gnu.tar.gz", "28316732cbe46c1047db3068824468b8a620b750b311bcef1b430c00de81092e"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/libsass.v3.5.5.x86_64-linux-musl.tar.gz", "25c7925c9b57fce19a646c040484bd5f6a21603a27561469f319b96c462f8241"),
    FreeBSD(:x86_64) => ("$bin_prefix/libsass.v3.5.5.x86_64-unknown-freebsd11.1.tar.gz", "12a2b5739b186a14189b369101fac2241790104697cc7480ded0783f757231a1"),
    Windows(:x86_64, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/libsass.v3.5.5.x86_64-w64-mingw32-gcc7.tar.gz", "c24fb85e81b8e2329651592406b4d371bea1e24f9dc7157f1534660945582ec9"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
