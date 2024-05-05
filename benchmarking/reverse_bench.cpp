#include <benchmark/benchmark.h>

#include <algorithm>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <vector>

extern "C" {
extern void reverse_u8(uint8_t *a, size_t n);
extern void reverse_i8(int8_t *a, size_t n);
extern void reverse_u16(uint16_t *a, size_t n);
extern void reverse_i16(int16_t *a, size_t n);
extern void reverse_u32(uint32_t *a, size_t n);
extern void reverse_i32(int32_t *a, size_t n);
extern void reverse_u64(uint64_t *a, size_t n);
extern void reverse_i64(int64_t *a, size_t n);

extern void reverse_simd_u8(uint8_t *a, size_t n);
extern void reverse_simd_i8(int8_t *a, size_t n);
extern void reverse_simd_u16(uint16_t *a, size_t n);
extern void reverse_simd_i16(int16_t *a, size_t n);
extern void reverse_simd_u32(uint32_t *a, size_t n);
extern void reverse_simd_i32(int32_t *a, size_t n);
extern void reverse_simd_u64(uint64_t *a, size_t n);
extern void reverse_simd_i64(int64_t *a, size_t n);
}

void std_reverse(int8_t *a, size_t n) { reverse_i8(a, n); };
void std_reverse(int16_t *a, size_t n) { reverse_i16(a, n); };
void std_reverse(int32_t *a, size_t n) { reverse_i32(a, n); };
void std_reverse(int64_t *a, size_t n) { reverse_i64(a, n); };
void std_reverse(uint8_t *a, size_t n) { reverse_u8(a, n); };
void std_reverse(uint16_t *a, size_t n) { reverse_u16(a, n); };
void std_reverse(uint32_t *a, size_t n) { reverse_u32(a, n); };
void std_reverse(uint64_t *a, size_t n) { reverse_u64(a, n); };

void my_reverse(int8_t *a, size_t n) { reverse_simd_i8(a, n); };
void my_reverse(int16_t *a, size_t n) { reverse_simd_i16(a, n); };
void my_reverse(int32_t *a, size_t n) { reverse_simd_i32(a, n); };
void my_reverse(int64_t *a, size_t n) { reverse_simd_i64(a, n); };
void my_reverse(uint8_t *a, size_t n) { reverse_simd_u8(a, n); };
void my_reverse(uint16_t *a, size_t n) { reverse_simd_u16(a, n); };
void my_reverse(uint32_t *a, size_t n) { reverse_simd_u32(a, n); };
void my_reverse(uint64_t *a, size_t n) { reverse_simd_u64(a, n); };

#ifndef DATA_TYPE
#warning no data type defined
#define DATA_TYPE uint8_t
#endif

const auto mult = 2ll;
const auto low = 2ll;
const auto high = 1ll << 30;

static void BM_std_reverse(benchmark::State &state) {
    std::vector<DATA_TYPE> arr(state.range(0));
    for (auto _: state) {
        std_reverse(arr.data(), arr.size());
        benchmark::DoNotOptimize(arr);
    }
    state.SetBytesProcessed(state.iterations() * arr.size() * sizeof(arr[0]));
}
BENCHMARK(BM_std_reverse)->RangeMultiplier(mult)->Range(low, high);

static void BM_my_reverse(benchmark::State &state) {
    std::vector<DATA_TYPE> arr(state.range(0));
    for (auto _: state) {
        my_reverse(arr.data(), arr.size());
        benchmark::DoNotOptimize(arr);
    }
    state.SetBytesProcessed(state.iterations() * arr.size() * sizeof(arr[0]));
}
BENCHMARK(BM_my_reverse)->RangeMultiplier(mult)->Range(low, high);

static void BM_memset(benchmark::State &state) {
    std::vector<DATA_TYPE> arr(state.range(0));
    for (auto _: state) {
        std::memset(arr.data(), 0, arr.size() * sizeof(arr[0]));
        benchmark::DoNotOptimize(arr);
    }
    state.SetBytesProcessed(state.iterations() * arr.size() * sizeof(arr[0]));
}
BENCHMARK(BM_memset)->RangeMultiplier(mult)->Range(low, high);

BENCHMARK_MAIN();