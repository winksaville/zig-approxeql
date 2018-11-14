const builtin = @import("builtin");
const TypeId = builtin.TypeId;

const std = @import("std");
const math = std.math;
const assert = std.debug.assert;
const warn = std.debug.warn;

const fepsilon = @import("fepsilon.zig").fepsilon;

// Set to true for debug output
const DBG = false;

/// Return true if x is approximately equal to y.
///   Based on `AlmostEqlRelativeAndAbs` at
///   https://randomascii.wordpress.com/2012/02/25/comparing-floating-point-numbers-2012-edition/
///
/// Note: It's possible to calculate max_diff at compile time by adding
/// a comptime attribute to digits parameter.
pub fn approxEql(x: var, y: var, digits: usize) bool {
    assert(@typeOf(x) == @typeOf(y));
    assert(@typeId(@typeOf(x)) == TypeId.Float);
    assert(@typeId(@typeOf(y)) == TypeId.Float);
    const T = @typeOf(x);

    if (!DBG) {
        if (digits == 0) return true;

        if (x == y) return true;
        if ((math.isNan(x) and math.isNan(y)) or (math.isNan(-x) and math.isNan(-y))) return true;
        if ((math.isInf(x) and math.isInf(y)) or (math.isInf(-x) and math.isInf(-y))) return true;

        var abs_diff = math.fabs(x - y);
        if (math.isNan(abs_diff) or math.isInf(abs_diff)) return false;

        var max_diff: T = math.pow(T, 10, -@intToFloat(T, digits - 1));
        if (abs_diff <= max_diff) return true;

        var largest = math.max(math.fabs(x), math.fabs(y));
        var scaled_max_diff = largest * max_diff / 10;

        return abs_diff <= scaled_max_diff;
    } else {
        var result: bool = undefined;
        warn("approxEql: x={} y={} digits={}", T(x), T(y), digits);
        defer {
            warn(" result={}\n", result);
        }

        if (digits == 0) {
            warn(" digits == 0");
            result = true;
            return result;
        }

        // Performance optimization if x and y are equal
        if (x == y) {
            warn(" x == y");
            result = true;
            return result;
        }

        // Check for nan and inf
        if ((math.isNan(x) and math.isNan(y)) or (math.isNan(-x) and math.isNan(-y))) {
            warn(" both nan");
            result = true;
            return true;
        }
        if ((math.isInf(x) and math.isInf(y)) or (math.isInf(-x) and math.isInf(-y))) {
            warn(" both nan");
            result = true;
            return true;
        }

        // Determine the difference and check if max_diff is a nan or inf
        var abs_diff = math.fabs(x - y);
        warn(" abs_diff={}", abs_diff);
        if (math.isNan(abs_diff) or math.isInf(abs_diff)) {
            warn(" nan or inf");
            result = false;
            return result;
        }

        // Determine our basic max_diff based on digits
        var max_diff: T = math.pow(T, 10, -@intToFloat(T, digits - 1));
        warn(" max_diff={}", max_diff);

        // Use max_diff unscalled to check for results close to zero.
        if (abs_diff <= max_diff) {
            warn(" close to 0");
            result = true;
            return result;
        }

        // Scale max_diff against largest of |x| and |y|.
        // Also tired scaled_max_diff = largest * fepsilon(T),
        // but that doesn't work large numbers near f32/f64_max.
        var largest = math.max(math.fabs(x), math.fabs(y));
        var scaled_max_diff = largest * max_diff / 10;
        var scaled_epsilon = largest * fepsilon(T); //  * 250;
        warn(" scaled_max_diff={} scaled_epsilon={}", scaled_max_diff, scaled_epsilon);

        // Compare and return result
        //result = (abs_diff <= scaled_epsilon);
        result = (abs_diff <= scaled_max_diff);
        return result;
    }
}

test "approxEql.nan.inf" {
    if (DBG) warn("\n");

    assert(approxEql(math.nan(f64), math.nan(f64), 17));
    assert(approxEql(-math.nan(f64), -math.nan(f64), 17));
    assert(approxEql(math.inf(f64), math.inf(f64), 17));
    assert(approxEql(-math.inf(f64), -math.inf(f64), 17));

    assert(!approxEql(math.nan(f64), f64(0), 17));
    assert(!approxEql(math.inf(f64), f64(0), 17));
    assert(!approxEql(f64(1), math.nan(f64), 17));
    assert(!approxEql(f64(2), math.inf(f64), 17));

    assert(approxEql(math.nan(f32), math.nan(f32), 17));
    assert(approxEql(-math.nan(f32), -math.nan(f32), 17));
    assert(approxEql(math.inf(f32), math.inf(f32), 17));
    assert(approxEql(-math.inf(f32), -math.inf(f32), 17));

    assert(!approxEql(math.nan(f32), f32(0), 17));
    assert(!approxEql(math.inf(f32), f32(0), 17));
    assert(!approxEql(f32(1), math.nan(f32), 17));
    assert(!approxEql(f32(2), math.inf(f32), 17));
}

test "approxEql.same" {
    if (DBG) warn("\n");
    const T = f64;
    var x: T = 0;
    var y: T = 0;

    assert(approxEql(x, y, 0));
    assert(approxEql(x, y, 1));
    assert(approxEql(x, y, 2));
    assert(approxEql(x, y, 3));
    assert(approxEql(x, y, 4));
    assert(approxEql(x, y, 5));
    assert(approxEql(x, y, 6));
    assert(approxEql(x, y, 7));
    assert(approxEql(x, y, 8));
    assert(approxEql(x, y, 9));
    assert(approxEql(x, y, 10));
    assert(approxEql(x, y, 11));
    assert(approxEql(x, y, 12));
    assert(approxEql(x, y, 13));
    assert(approxEql(x, y, 14));
    assert(approxEql(x, y, 15));
    assert(approxEql(x, y, 16));
    assert(approxEql(x, y, 17));

    assert(approxEql(T(123e-123), T(123e-123), 17));
    assert(approxEql(T(-123e-123), T(-123e-123), 17));
    assert(approxEql(T(-123e123), T(-123e123), 17));
    assert(approxEql(T(123e123), T(123e123), 17));
}

test "approxEql.0.fepsilon*1" {
    if (DBG) warn("\n");
    const T = f64;
    const et = fepsilon(T);
    var x: T = 0;
    var y: T = et * 1;
    assert(y == et);

    assert(approxEql(x, y, 0));
    assert(approxEql(x, y, 1));
    assert(approxEql(x, y, 2));
    assert(approxEql(x, y, 3));
    assert(approxEql(x, y, 4));
    assert(approxEql(x, y, 5));
    assert(approxEql(x, y, 6));
    assert(approxEql(x, y, 7));
    assert(approxEql(x, y, 8));
    assert(approxEql(x, y, 9));
    assert(approxEql(x, y, 10));
    assert(approxEql(x, y, 11));
    assert(approxEql(x, y, 12));
    assert(approxEql(x, y, 13));
    assert(approxEql(x, y, 14));
    assert(approxEql(x, y, 15));
    assert(approxEql(x, y, 16));
    assert(!approxEql(x, y, 17));
}

test "approxEql.0.fepsilon*4" {
    if (DBG) warn("\n");
    const T = f64;
    const et = fepsilon(T);
    var x: T = 0;
    var y: T = et * T(4);

    assert(approxEql(x, y, 0));
    assert(approxEql(x, y, 1));
    assert(approxEql(x, y, 2));
    assert(approxEql(x, y, 3));
    assert(approxEql(x, y, 4));
    assert(approxEql(x, y, 5));
    assert(approxEql(x, y, 6));
    assert(approxEql(x, y, 7));
    assert(approxEql(x, y, 8));
    assert(approxEql(x, y, 9));
    assert(approxEql(x, y, 10));
    assert(approxEql(x, y, 11));
    assert(approxEql(x, y, 12));
    assert(approxEql(x, y, 13));
    assert(approxEql(x, y, 14));
    assert(approxEql(x, y, 15));
    assert(approxEql(x, y, 16));
    assert(!approxEql(x, y, 17));
}

test "approxEql.0.fepsilon*5" {
    if (DBG) warn("\n");
    const T = f64;
    const et = fepsilon(T);
    var x: T = 0;
    var y: T = et * T(5);

    assert(approxEql(x, y, 0));
    assert(approxEql(x, y, 1));
    assert(approxEql(x, y, 2));
    assert(approxEql(x, y, 3));
    assert(approxEql(x, y, 4));
    assert(approxEql(x, y, 5));
    assert(approxEql(x, y, 6));
    assert(approxEql(x, y, 7));
    assert(approxEql(x, y, 8));
    assert(approxEql(x, y, 9));
    assert(approxEql(x, y, 10));
    assert(approxEql(x, y, 11));
    assert(approxEql(x, y, 12));
    assert(approxEql(x, y, 13));
    assert(approxEql(x, y, 14));
    assert(approxEql(x, y, 15));
    assert(!approxEql(x, y, 16));
    assert(!approxEql(x, y, 17));
}

test "approxEql.0.fepsilon*45" {
    if (DBG) warn("\n");
    const T = f64;
    const et = fepsilon(T);
    var x: T = 0;
    var y: T = et * T(45);

    assert(approxEql(x, y, 0));
    assert(approxEql(x, y, 1));
    assert(approxEql(x, y, 2));
    assert(approxEql(x, y, 3));
    assert(approxEql(x, y, 4));
    assert(approxEql(x, y, 5));
    assert(approxEql(x, y, 6));
    assert(approxEql(x, y, 7));
    assert(approxEql(x, y, 8));
    assert(approxEql(x, y, 9));
    assert(approxEql(x, y, 10));
    assert(approxEql(x, y, 11));
    assert(approxEql(x, y, 12));
    assert(approxEql(x, y, 13));
    assert(approxEql(x, y, 14));
    assert(approxEql(x, y, 15));
    assert(!approxEql(x, y, 16));
    assert(!approxEql(x, y, 17));
}

test "approxEql.0.fepsilon*46" {
    if (DBG) warn("\n");
    const T = f64;
    const et = fepsilon(T);
    var x: T = 0;
    var y: T = et * T(46);

    assert(approxEql(x, y, 0));
    assert(approxEql(x, y, 1));
    assert(approxEql(x, y, 2));
    assert(approxEql(x, y, 3));
    assert(approxEql(x, y, 4));
    assert(approxEql(x, y, 5));
    assert(approxEql(x, y, 6));
    assert(approxEql(x, y, 7));
    assert(approxEql(x, y, 8));
    assert(approxEql(x, y, 9));
    assert(approxEql(x, y, 10));
    assert(approxEql(x, y, 11));
    assert(approxEql(x, y, 12));
    assert(approxEql(x, y, 13));
    assert(approxEql(x, y, 14));
    assert(!approxEql(x, y, 15));
    assert(!approxEql(x, y, 16));
    assert(!approxEql(x, y, 17));
}

test "approxEql.0.fepsilon*450" {
    if (DBG) warn("\n");
    const T = f64;
    const et = fepsilon(T);
    var x: T = 0;
    var y: T = et * T(450);

    assert(approxEql(x, y, 0));
    assert(approxEql(x, y, 1));
    assert(approxEql(x, y, 2));
    assert(approxEql(x, y, 3));
    assert(approxEql(x, y, 4));
    assert(approxEql(x, y, 5));
    assert(approxEql(x, y, 6));
    assert(approxEql(x, y, 7));
    assert(approxEql(x, y, 8));
    assert(approxEql(x, y, 9));
    assert(approxEql(x, y, 10));
    assert(approxEql(x, y, 11));
    assert(approxEql(x, y, 12));
    assert(approxEql(x, y, 13));
    assert(approxEql(x, y, 14));
    assert(!approxEql(x, y, 15));
    assert(!approxEql(x, y, 16));
    assert(!approxEql(x, y, 17));
}

test "approxEql.0.fepsilon*451" {
    if (DBG) warn("\n");
    const T = f64;
    const et = fepsilon(T);
    var x: T = 0;
    var y: T = et * T(451);

    assert(approxEql(x, y, 0));
    assert(approxEql(x, y, 1));
    assert(approxEql(x, y, 2));
    assert(approxEql(x, y, 3));
    assert(approxEql(x, y, 4));
    assert(approxEql(x, y, 5));
    assert(approxEql(x, y, 6));
    assert(approxEql(x, y, 7));
    assert(approxEql(x, y, 8));
    assert(approxEql(x, y, 9));
    assert(approxEql(x, y, 10));
    assert(approxEql(x, y, 11));
    assert(approxEql(x, y, 12));
    assert(approxEql(x, y, 13));
    assert(!approxEql(x, y, 14));
    assert(!approxEql(x, y, 15));
    assert(!approxEql(x, y, 16));
    assert(!approxEql(x, y, 17));
}

/// Sum from start to end with a step of (end - start)/count for
/// count times.  So if start == 0 and end == 1 and count == 10 then
/// the step is 0.1 and because of the imprecision of floating point
/// errors are introduced.
fn sum(comptime T: type, start: T, end: T, count: usize) T {
    var step = (end - start) / @intToFloat(T, count);
    var r: T = start;

    var j: usize = 0;
    while (j < count) : (j += 1) {
        r += step;
    }
    return r;
}

test "approxEql.sum.near0.f64" {
    if (DBG) warn("\n");
    const T = f64;
    var x: T = 1;
    var end: T = sum(T, 0, x, 10000);
    if (DBG) warn("x={} end={}\n", x, end);
    assert(x != end);

    // "close to 0" is used and returned true
    assert(approxEql(x, end, 0));
    assert(approxEql(x, end, 1));
    assert(approxEql(x, end, 2));
    assert(approxEql(x, end, 3));
    assert(approxEql(x, end, 4));
    assert(approxEql(x, end, 5));
    assert(approxEql(x, end, 6));
    assert(approxEql(x, end, 7));
    assert(approxEql(x, end, 8));
    assert(approxEql(x, end, 9));
    assert(approxEql(x, end, 10));
    assert(approxEql(x, end, 11));
    assert(approxEql(x, end, 12));
    assert(approxEql(x, end, 13));
    assert(approxEql(x, end, 14));

    // "< 10" is used and either scaled_epsilon or scaled_max_diff returned false
    assert(!approxEql(x, end, 15));
    assert(!approxEql(x, end, 16));
    assert(!approxEql(x, end, 17));
}

test "approxEql.sum.near0.f32" {
    if (DBG) warn("\n");
    const T = f32;
    var x: T = 1;
    var end: T = sum(T, 0, x, 1000);
    if (DBG) warn("x={} end={}\n", x, end);
    assert(x != end);

    assert(approxEql(x, end, 0));
    assert(approxEql(x, end, 1));
    assert(approxEql(x, end, 2));
    assert(approxEql(x, end, 3));
    assert(approxEql(x, end, 4));
    assert(approxEql(x, end, 5));
    assert(approxEql(x, end, 6));

    // "< 10" is used and either scaled_epsilon or scaled_max_diff returned false
    assert(!approxEql(x, end, 7));
    assert(!approxEql(x, end, 8));
    assert(!approxEql(x, end, 9));
    assert(!approxEql(x, end, 10));
    assert(!approxEql(x, end, 11));
    assert(!approxEql(x, end, 12));
    assert(!approxEql(x, end, 13));
    assert(!approxEql(x, end, 14));
    assert(!approxEql(x, end, 15));
    assert(!approxEql(x, end, 16));
    assert(!approxEql(x, end, 17));
}

test "approxEql.sum.large.f64" {
    if (DBG) warn("\n");
    const T = f64;
    var x: T = math.f64_max / T(2);
    var end: T = sum(T, x / T(2), x, 1000);
    if (DBG) warn("x={} end={}\n", x, end);
    assert(x != end);

    // ">=10" is used abs_diff=4.939e294 and using scaled_epsilon=1.99e292 would have failed all
    // asserts by 0 digits. But largest_times_diff=8.98e306 and gave good results.
    assert(approxEql(x, end, 0));
    assert(approxEql(x, end, 1));
    assert(approxEql(x, end, 2));
    assert(approxEql(x, end, 3));
    assert(approxEql(x, end, 4));
    assert(approxEql(x, end, 5));
    assert(approxEql(x, end, 6));
    assert(approxEql(x, end, 7));
    assert(approxEql(x, end, 8));
    assert(approxEql(x, end, 9));
    assert(approxEql(x, end, 10));
    assert(approxEql(x, end, 11));
    assert(approxEql(x, end, 12));
    assert(approxEql(x, end, 13));
    assert(!approxEql(x, end, 14));
    assert(!approxEql(x, end, 15));
    assert(!approxEql(x, end, 16));
    assert(!approxEql(x, end, 17));
}

test "approxEql.sum.large.f32" {
    if (DBG) warn("\n");
    const T = f32;
    var x: T = math.f32_max / T(2);
    var end: T = sum(T, x / T(2), x, 100);
    if (DBG) warn("x={} end={}\n", x, end);
    assert(x != end);

    // abs_diff=7.09e31 and using scaled_epsilon=2.02e31 would have failed all
    // asserts by 0 digits. But largest_times_diff=1.70e37 and gave good results.
    assert(approxEql(x, end, 0));
    assert(approxEql(x, end, 1));
    assert(approxEql(x, end, 2));
    assert(approxEql(x, end, 3));
    assert(approxEql(x, end, 4));
    assert(approxEql(x, end, 5));
    assert(approxEql(x, end, 6));
    assert(!approxEql(x, end, 7));
    assert(!approxEql(x, end, 8));
    assert(!approxEql(x, end, 9));
    assert(!approxEql(x, end, 10));
    assert(!approxEql(x, end, 11));
    assert(!approxEql(x, end, 12));
    assert(!approxEql(x, end, 13));
    assert(!approxEql(x, end, 14));
    assert(!approxEql(x, end, 15));
    assert(!approxEql(x, end, 16));
    assert(!approxEql(x, end, 17));
}

/// Subtract from start down to end with a step of (start - end)/count
/// for count times. So if start == 1 and end == 0 and count == 10 then
/// the step is 0.1 and because of the imprecision of floating point
/// errors are introduced.
fn sub(comptime T: type, start: T, end: T, count: usize) T {
    var step = (start - end) / @intToFloat(T, count);
    var r: T = start;

    var j: usize = 0;
    while (j < count) : (j += 1) {
        r -= step;
    }
    return r;
}

test "approxEql.sub.near0.f64" {
    if (DBG) warn("\n");
    const T = f64;
    var x: T = 0;
    var end: T = sub(T, 1, x, 10000);
    if (DBG) warn("x={} end={}\n", x, end);
    assert(x != end);

    // Either scaled_epsilon or scaled_max_diff worked
    assert(approxEql(x, end, 0));
    assert(approxEql(x, end, 1));
    assert(approxEql(x, end, 2));
    assert(approxEql(x, end, 3));
    assert(approxEql(x, end, 4));
    assert(approxEql(x, end, 5));
    assert(approxEql(x, end, 6));
    assert(approxEql(x, end, 7));
    assert(approxEql(x, end, 8));
    assert(approxEql(x, end, 9));
    assert(approxEql(x, end, 10));
    assert(approxEql(x, end, 11));
    assert(approxEql(x, end, 12));
    assert(approxEql(x, end, 13));
    assert(approxEql(x, end, 14));
    assert(!approxEql(x, end, 15));
    assert(!approxEql(x, end, 16));
    assert(!approxEql(x, end, 17));
}

test "approxEql.sub.near0.f32" {
    if (DBG) warn("\n");
    const T = f32;
    var x: T = 0;
    var end: T = sub(T, 1, x, 1000);
    if (DBG) warn("x={} end={}\n", x, end);
    assert(x != end);

    // Either scaled_epsilon or scaled_max_diff worked
    assert(approxEql(x, end, 0));
    assert(approxEql(x, end, 1));
    assert(approxEql(x, end, 2));
    assert(approxEql(x, end, 3));
    assert(approxEql(x, end, 4));
    assert(approxEql(x, end, 5));
    assert(approxEql(x, end, 6));
    assert(!approxEql(x, end, 7));
    assert(!approxEql(x, end, 8));
    assert(!approxEql(x, end, 9));
    assert(!approxEql(x, end, 10));
    assert(!approxEql(x, end, 11));
    assert(!approxEql(x, end, 12));
    assert(!approxEql(x, end, 13));
    assert(!approxEql(x, end, 14));
    assert(!approxEql(x, end, 15));
    assert(!approxEql(x, end, 16));
    assert(!approxEql(x, end, 17));
}

test "approxEql.atan32" {
    const espilon: f32 = 0.000001;

    if (DBG) warn("\natan(f64(0.2))={}\n", math.atan(f64(0.2)));
    if (DBG) warn("atan(f32(0.2))={}\n", math.atan(f32(0.2)));

    assert(math.approxEq(f32, math.atan(f32(0.2)), 0.197396, espilon));
    assert(math.approxEq(f32, math.atan(f32(-0.2)), -0.197396, espilon));
    assert(math.approxEq(f32, math.atan(f32(0.3434)), 0.330783, espilon));
    assert(math.approxEq(f32, math.atan(f32(0.8923)), 0.728545, espilon));
    assert(math.approxEq(f32, math.atan(f32(1.5)), 0.982794, espilon));

    const digits = 7;
    assert(approxEql(math.atan(f32(0.2)), f32(0.197396), digits));
    assert(approxEql(math.atan(f32(-0.2)), f32(-0.197396), digits));
    assert(approxEql(math.atan(f32(0.3434)), f32(0.330783), digits));
    assert(approxEql(math.atan(f32(0.8923)), f32(0.728545), digits));
    assert(approxEql(math.atan(f32(1.5)), f32(0.982794), digits));
}

test "approxEql.123e12.3.digits" {
    if (DBG) warn("\n");
    assert(!approxEql(f32(122.0e12), f32(123e12), 3));
    assert(approxEql(f32(123.0e12), f32(123e12), 3));
    assert(!approxEql(f32(124.0e12), f32(123e12), 3));
}

test "approxEql.123e12.4.digits" {
    if (DBG) warn("\n");
    assert(!approxEql(f32(122.9e12), f32(123.0e12), 4));
    assert(approxEql(f32(123.0e12), f32(123.0e12), 4));
    assert(!approxEql(f32(123.1e12), f32(123.0e12), 4));
}

test "approxEql.993e12.3.digits" {
    if (DBG) warn("\n");
    assert(!approxEql(f32(992.0e12), f32(993e12), 3));
    assert(approxEql(f32(993.0e12), f32(993e12), 3));
    assert(!approxEql(f32(994.0e12), f32(993e12), 3));
}

test "approxEql.993e12.4.digits" {
    if (DBG) warn("\n");
    assert(!approxEql(f32(992.9e12), f32(993.0e12), 4));
    assert(approxEql(f32(993.0e12), f32(993.0e12), 4));
    assert(!approxEql(f32(993.1e12), f32(993.0e12), 4));
}
