#!/usr/bin/bash

make_graph() {
	local n="$1"
	echo "Generating graph for u${n}:"
	
	#plot result
	python3 plot.py -f bench_u${n}.csv --output bench_u${n}.png --logx --logy -m "bytes_per_second" --xlabel "input size(number of u${n}s)" --ylabel "throughput(bytes/s)" 
}

make_graph 8
make_graph 16
make_graph 32
make_graph 64
