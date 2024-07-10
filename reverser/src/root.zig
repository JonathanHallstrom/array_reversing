const std = @import("std");
const builtin = @import("builtin");

const swap = std.mem.swap;
const doNotOptimizeAway = std.mem.doNotOptimizeAway;

const backend_supports_vectors = switch (builtin.zig_backend) {
    .stage2_llvm, .stage2_c => true,
    else => false,
};

inline fn reverseVector(comptime N: usize, comptime T: type, a: []T) [N]T {
    var res: [N]T = undefined;
    inline for (0..N) |i| {
        res[i] = a[N - i - 1];
    }
    return res;
}

/// In-place order reversal of a slice
pub fn reverse(comptime T: type, items: []T) void {
    var i: usize = 0;
    const end = items.len / 2;
    if (backend_supports_vectors and
        !@inComptime() and
        @bitSizeOf(T) > 0 and
        std.math.isPowerOfTwo(@bitSizeOf(T)))
    {
        if (std.simd.suggestVectorLength(T)) |simd_size| {
            if (simd_size <= end) {
                const simd_end = end - (simd_size - 1);
                while (i < simd_end) : (i += simd_size) {
                    const left_slice = items[i .. i + simd_size];
                    const right_slice = items[items.len - i - simd_size .. items.len - i];

                    const left_shuffled: [simd_size]T = reverseVector(simd_size, T, left_slice);
                    const right_shuffled: [simd_size]T = reverseVector(simd_size, T, right_slice);

                    @memcpy(right_slice, &left_shuffled);
                    @memcpy(left_slice, &right_shuffled);
                }
            }
        }
    }

    while (i < end) : (i += 1) {
        swap(T, &items[i], &items[items.len - i - 1]);
    }
}

const testing = std.testing;

test reverse {
    {
        var arr = [_]i32{ 5, 3, 1, 2, 4 };
        reverse(i32, arr[0..]);
        try testing.expectEqualSlices(i32, &arr, &.{ 4, 2, 1, 3, 5 });
    }
    {
        var arr = [_]u0{};
        reverse(u0, arr[0..]);
        try testing.expectEqualSlices(u0, &arr, &.{});
    }
    {
        var arr = [_]i64{ 19, 17, 15, 13, 11, 9, 7, 5, 3, 1, 2, 4, 6, 8, 10, 12, 14, 16, 18 };
        reverse(i64, arr[0..]);
        try testing.expectEqualSlices(i64, &arr, &.{ 18, 16, 14, 12, 10, 8, 6, 4, 2, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19 });
    }
    {
        var arr = [_][]const u8{ "a", "b", "c", "d" };
        reverse([]const u8, arr[0..]);
        try testing.expectEqualSlices([]const u8, &arr, &.{ "d", "c", "b", "a" });
    }
    {
        const MyType = union(enum) {
            a: [3]u8,
            b: u24,
            c,
        };
        var arr = [_]MyType{ .{ .a = .{ 0, 0, 0 } }, .{ .b = 0 }, .c };
        reverse(MyType, arr[0..]);
        try testing.expectEqualSlices(MyType, &arr, &([_]MyType{ .c, .{ .b = 0 }, .{ .a = .{ 0, 0, 0 } } }));
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
    reverse(u8, a[0..n]);
}

export fn reverse_simd_i8(a: [*]i8, n: usize) void {
    reverse(i8, a[0..n]);
}

export fn reverse_simd_u16(a: [*]u16, n: usize) void {
    reverse(u16, a[0..n]);
}

export fn reverse_simd_i16(a: [*]i16, n: usize) void {
    reverse(i16, a[0..n]);
}

export fn reverse_simd_u32(a: [*]u32, n: usize) void {
    reverse(u32, a[0..n]);
}

export fn reverse_simd_i32(a: [*]i32, n: usize) void {
    reverse(i32, a[0..n]);
}

export fn reverse_simd_u64(a: [*]u64, n: usize) void {
    reverse(u64, a[0..n]);
}

export fn reverse_simd_i64(a: [*]i64, n: usize) void {
    reverse(i64, a[0..n]);
}

test {
    var prng = std.rand.Xoroshiro128.init(0);
    const rand = prng.random();
    inline for ([_]type{ u0, u1, u2, u3, u4, u5, u6, u7, u8, u16, u24, u32, u48, u64, u128, u256 }) |T| {
        for (0..16) |_| {
            const arr: []T = try std.testing.allocator.alloc(T, rand.uintLessThan(usize, 128));
            defer std.testing.allocator.free(arr);
            for (arr) |*e| {
                e.* = rand.int(T);
            }
            const original = try std.testing.allocator.dupe(T, arr);
            defer std.testing.allocator.free(original);
            std.mem.reverse(T, arr);
            const reversed = try std.testing.allocator.dupe(T, arr);
            defer std.testing.allocator.free(reversed);
            std.mem.reverse(T, arr);

            reverse(T, arr);
            try std.testing.expectEqualSlices(T, reversed, arr);
            reverse(T, arr);
            try std.testing.expectEqualSlices(T, original, arr);
        }
    }
}
