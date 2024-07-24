# array_reversing

some benchmarking

## requirements 

[zig 0.12.0+](https://ziglang.org/)

c++17 compiler (used clang 19 in the benchmarks)

[google benchmark](https://github.com/google/benchmark/)

## example of running benchmark
```
git clone https://github.com/JonathanHallstrom/array_reversing.git
cd benchmarking
export CXX=clang++ && ./build.sh && ./runbench.sh && ./make_graphs.sh
```

update: PR was merged https://github.com/ziglang/zig/pull/20455/
