#!/usr/bin/bash

run_benchmark() {
	local n="$1"
	echo "Running benchmark for u${n}:"

	#run benchmark
	./bench_u${n}.out --benchmark_min_time=1s --benchmark_format=csv >"bench_u${n}.csv"
}

run_benchmark 8
run_benchmark 16
run_benchmark 32
run_benchmark 64
