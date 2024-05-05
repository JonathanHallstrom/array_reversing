#!/usr/bin/bash

run_benchmark() {
    local n="$1"
    echo "Running benchmark for u${n}:"

    #build benchmark
    $CXX -flto -static -std=c++17 -o bench_u${n}.out -Ofast -DDATA_TYPE=uint${n}_t reverse_bench.cpp -isystem benchmark/include -Lbenchmark/build/src -lbenchmark -lpthread  ../reverser/zig-out/lib/libreverser.a

    #run benchmark
    ./bench_u${n}.out --benchmark_min_time=2s --benchmark_format=csv > "bench_u${n}.csv"

    #plot result
    python3 plot.py -f bench_u${n}.csv --output bench_u${n}.png --logx --logy --xlabel "input size(number of u${n}s)" --ylabel "time(ns)"
}

run_benchmark 8
run_benchmark 16
run_benchmark 32
run_benchmark 64