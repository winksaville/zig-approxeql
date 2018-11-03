const std = @import("std");
const assert = std.debug.assert;
const warn = std.debug.warn;
const math = std.math;

// Set to true for debug output
const DBG = false;

pub fn fepsilon(comptime T: type) T {
    return switch (T) {
        f64 => math.f64_epsilon,
        f32 => math.f32_epsilon,
        f16 => math.f16_epsilon,
        else => @compileError("fepsilon only supports f64, f32 or f16"),
    };
}

fn testFepsilon(comptime T: type) void {
    assert(fepsilon(T) != T(0));
    assert(fepsilon(T) == fepsilon(T));
    assert((fepsilon(T) * T(2)) == (fepsilon(T) + fepsilon(T)));

    var e1_cnt = T(1) / fepsilon(T);
    var e2_cnt = T(2) / fepsilon(T);
    var e3_cnt = T(3) / fepsilon(T);
    var e4_cnt = T(4) / fepsilon(T);

    if (DBG) {
        warn("fepsilon.{}={}\n", @typeName(T), fepsilon(T));
        warn("fepsilon.{} e2_cnt:{}-e1_cnt:{}={}\n", @typeName(T), e2_cnt, e1_cnt, e2_cnt - e1_cnt);
        warn("fepsilon.{} e4_cnt:{}-e3_cnt:{}={}\n", @typeName(T), e4_cnt, e3_cnt, e4_cnt - e3_cnt);
    }
    assert(e2_cnt - e1_cnt == e4_cnt - e3_cnt);
}

test "fepsilon.f64" {
    if (DBG) warn("\n");
    testFepsilon(f64);
}

test "fepsilon.f32" {
    if (DBG) warn("\n");
    testFepsilon(f32);
}

test "fepsilon.f16" {
    if (DBG) warn("\n");
    testFepsilon(f16);
}
