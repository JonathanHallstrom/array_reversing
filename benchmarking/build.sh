#!/usr/bin/bash

run_benchmark() {
	local n="$1"
	echo "Building benchmark for u${n}:"

	#build benchmark
	$CXX -std=c++17 -ggdb -o bench_u${n}.out -Ofast -DDATA_TYPE=uint${n}_t reverse_bench.cpp -isystem benchmark/include -Lbenchmark/build/src -lbenchmark -lpthread ../reverser/zig-out/lib/libreverser.a

}
echo "Building zig library"
(cd ../reverser; zig build -Doptimize=ReleaseSmall)
run_benchmark 8
run_benchmark 16
run_benchmark 32
run_benchmark 64
