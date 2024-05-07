const std = @import("std");

fn reverseVector(comptime N: usize, comptime T: type, a: @Vector(N, T)) @Vector(N, T) {
    const reverse_mask = comptime blk: {
        var res: @Vector(N, i32) = undefined;
        for (0..N) |i| {
            res[N - i - 1] = i;
        }
        break :blk res;
    };
    return @shuffle(T, a, undefined, reverse_mask);
}

inline fn unlikely(x: bool) bool {
    @setCold(true);
    return x;
}

fn oneIteration(comptime T: type, a: []T, i: usize, comptime Len: comptime_int) void {
    const n = a.len;
    if (Len == 1) {
        const lhs = a[i];
        const rhs = a[n - i - 1];

        a[i] = rhs;
        a[n - i - 1] = lhs;
        return;
    }
    const left_slice = a[i .. i + Len];
    const right_slice = a[n - i - Len .. n - i];

    const left: [Len]T = left_slice[0..Len].*;
    const right: [Len]T = right_slice[0..Len].*;

    const left_shuffled: [Len]T = reverseVector(Len, T, left);
    const right_shuffled: [Len]T = reverseVector(Len, T, right);
    @memcpy(right_slice, left_shuffled[0..]);
    @memcpy(left_slice, right_shuffled[0..]);
}

pub fn reverseSimd(comptime T: type, a: []T) void {
    if (@sizeOf(T) > 8) return std.mem.reverse(T, a);
    const n = a.len;
    var i: usize = 0;
    const L1 = @max(8, 32 / @sizeOf(T));
    // inline for (0..L1 / 2) |_| {
    //     if (i == n / 2) return;
    //     oneIteration(T, a, i, 1);
    //     i += 1;
    // }
    while (i + L1 - 1 < n / 2) : (i += L1) {
        oneIteration(T, a, i, L1);
    }
    if (i + 7 < n / 2) {
        oneIteration(T, a, i, 8);
        i += 8;
    }
    if (i + 3 < n / 2) {
        oneIteration(T, a, i, 4);
        i += 4;
    }
    if (i + 1 < n / 2) {
        oneIteration(T, a, i, 2);
        i += 2;
    }
    inline for (0..@max(1, L1 - 14)) |_| {
        if (i == n / 2) return;
        oneIteration(T, a, i, 1);
        i += 1;
    }
}

export fn reverse_u8(a: [*]u8, n: usize) void {
    std.mem.reverse(u8, a[0..n]);
}

export fn reverse_i8(a: [*]i8, n: usize) void {
    std.mem.reverse(i8, a[0..n]);
}

export fn reverse_u16(a: [*]u16, n: usize) void {
    std.mem.reverse(u16, a[0..n]);
}

export fn reverse_i16(a: [*]i16, n: usize) void {
    std.mem.reverse(i16, a[0..n]);
}

export fn reverse_u32(a: [*]u32, n: usize) void {
    std.mem.reverse(u32, a[0..n]);
}

export fn reverse_i32(a: [*]i32, n: usize) void {
    std.mem.reverse(i32, a[0..n]);
}

export fn reverse_u64(a: [*]u64, n: usize) void {
    std.mem.reverse(u64, a[0..n]);
}

export fn reverse_i64(a: [*]i64, n: usize) void {
    std.mem.reverse(i64, a[0..n]);
}

export fn reverse_simd_u8(a: [*]u8, n: usize) void {
    reverseSimd(u8, a[0..n]);
}

export fn reverse_simd_i8(a: [*]i8, n: usize) void {
    reverseSimd(i8, a[0..n]);
}

export fn reverse_simd_u16(a: [*]u16, n: usize) void {
    reverseSimd(u16, a[0..n]);
}

export fn reverse_simd_i16(a: [*]i16, n: usize) void {
    reverseSimd(i16, a[0..n]);
}

export fn reverse_simd_u32(a: [*]u32, n: usize) void {
    reverseSimd(u32, a[0..n]);
}

export fn reverse_simd_i32(a: [*]i32, n: usize) void {
    reverseSimd(i32, a[0..n]);
}

export fn reverse_simd_u64(a: [*]u64, n: usize) void {
    reverseSimd(u64, a[0..n]);
}

export fn reverse_simd_i64(a: [*]i64, n: usize) void {
    reverseSimd(i64, a[0..n]);
}

comptime {
    @setEvalBranchQuota(1 << 20);
    var prng = std.rand.Xoroshiro128.init(0);
    const rand = prng.random();
    for ([_]type{ u8, u16, u32, u64, i8, i16, i32, i64 }) |T| {
        for (0..16) |_| {
            var arr: [rand.uintLessThan(usize, 128)]T = undefined;
            for (&arr) |*e| {
                e.* = rand.int(T);
            }
            const original = arr;
            std.mem.reverse(T, &arr);
            const reversed = arr;
            std.mem.reverse(T, &arr);

            reverseSimd(T, &arr);
            std.testing.expectEqualSlices(T, &reversed, &arr) catch {};
            reverseSimd(T, &arr);
            std.testing.expectEqualSlices(T, &original, &arr) catch {};
        }
    }
}
