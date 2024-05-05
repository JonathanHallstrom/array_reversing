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

pub fn reverseSimd(comptime T: type, a: []T) void {
    const n = a.len;
    var i: usize = 0;

    // dont know of a good way to choose this value, 4 seems reasonable to me
    const Len1 = @max(4, 32 / @sizeOf(T));
    while (i + Len1 - 1 < n / 2) : (i += Len1) {
        const left_slice = a[i .. i + Len1];
        const right_slice = a[n - i - Len1 .. n - i];
        const left: [Len1]T = reverseVector(Len1, T, left_slice[0..Len1].*);
        const right: [Len1]T = reverseVector(Len1, T, right_slice[0..Len1].*);
        @memcpy(left_slice, right[0..]);
        @memcpy(right_slice, left[0..]);
    }
    const Len2 = 4;
    while (i + Len2 - 1 < n / 2) : (i += Len2) {
        const left_slice = a[i .. i + Len2];
        const right_slice = a[n - i - Len2 .. n - i];
        const left: [Len2]T = reverseVector(Len2, T, left_slice[0..Len2].*);
        const right: [Len2]T = reverseVector(Len2, T, right_slice[0..Len2].*);
        @memcpy(left_slice, right[0..]);
        @memcpy(right_slice, left[0..]);
    }
    var iters: usize = 0;
    while (i < n / 2) : (i += 1) {
        if (iters == Len2) unreachable;
        iters += 1;

        const lhs = a[i];
        const rhs = a[n - i - 1];
        a[i] = rhs;
        a[n - i - 1] = lhs;
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
