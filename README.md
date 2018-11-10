# Explore floating point approximately equal

THIS IS PROBABLY WRONG, do NOT use!

With floating point comparing for equality is frought with problems
and typically it can only be done approximately. For instance summing
a series of calculated numbers will likely not produce the exactly
expected results. For instance summing 0.1 10 times should result in
a value of 1.0 but it doesn't the value with an f32 is r=1.00000011e+00:

```
pub fn sum(comptime T: type, start: T, end: T, count: usize) T {
    var step = (end - start)/@intToFloat(T, count);
    var r: T = start;

    var j: usize = 0;
    while (j < count) : (j += 1) {
        r += step;
    }
    return r;
}

pub fn testSum() void {
    var r = sum(f32, 0, 1, 10);
    warn("r={}\n", r);
    assert(r != f32(1.0));
}
```

Therefore a notion of approximately equals is needed. [Here](https://www.google.com/search?q=floating+point+compare)
is a Google search and [here](https://randomascii.wordpress.com/2012/02/25/comparing-floating-point-numbers-2012-edition/)
was the first hit and seems to have good information.

I took what I've learned so I came up with my own approxEql in zig that uses
significant `digits` to calcuate an allowable max difference that can is then
used do determine equality. It "seems" to be working and the code is in
approxeql.zig, but I'm have ZERO EXPERTICE so this is probably wrong!!!

## Test DBG=false in approxeql.zig

```
Test 1/23 approxEql.nan.inf...OK
Test 2/23 approxEql.same...OK
Test 3/23 approxEql.0.fepsilon*1...OK
Test 4/23 approxEql.0.fepsilon*4...OK
Test 5/23 approxEql.0.fepsilon*5...OK
Test 6/23 approxEql.0.fepsilon*45...OK
Test 7/23 approxEql.0.fepsilon*46...OK
Test 8/23 approxEql.0.fepsilon*450...OK
Test 9/23 approxEql.0.fepsilon*451...OK
Test 10/23 approxEql.sum.near0.f64...OK
Test 11/23 approxEql.sum.near0.f32...OK
Test 12/23 approxEql.sum.large.f64...OK
Test 13/23 approxEql.sum.large.f32...OK
Test 14/23 approxEql.sub.near0.f64...OK
Test 15/23 approxEql.sub.near0.f32...OK
Test 16/23 approxEql.atan32...OK
Test 17/23 approxEql.123e12.3.digits...OK
Test 18/23 approxEql.123e12.4.digits...OK
Test 19/23 approxEql.993e12.3.digits...OK
Test 20/23 approxEql.993e12.4.digits...OK
Test 21/23 fepsilon.f64...OK
Test 22/23 fepsilon.f32...OK
Test 23/23 fepsilon.f16...OK
All tests passed.
```

## Test DBG=true in approxeql.zig

```
$ zig test approxeql.zig 
Test 1/23 approxEql.nan.inf...
approxEql: x=nan y=nan digits=17 both nan result=true
approxEql: x=-nan y=-nan digits=17 both nan result=true
approxEql: x=inf y=inf digits=17 x == y result=true
approxEql: x=-inf y=-inf digits=17 x == y result=true
approxEql: x=nan y=0.0e+00 digits=17 abs_diff=nan nan or inf result=false
approxEql: x=inf y=0.0e+00 digits=17 abs_diff=inf nan or inf result=false
approxEql: x=1.0e+00 y=nan digits=17 abs_diff=nan nan or inf result=false
approxEql: x=2.0e+00 y=inf digits=17 abs_diff=inf nan or inf result=false
approxEql: x=nan y=nan digits=17 both nan result=true
approxEql: x=-nan y=-nan digits=17 both nan result=true
approxEql: x=inf y=inf digits=17 x == y result=true
approxEql: x=-inf y=-inf digits=17 x == y result=true
approxEql: x=nan y=0.0e+00 digits=17 abs_diff=nan nan or inf result=false
approxEql: x=inf y=0.0e+00 digits=17 abs_diff=inf nan or inf result=false
approxEql: x=1.0e+00 y=nan digits=17 abs_diff=nan nan or inf result=false
approxEql: x=2.0e+00 y=inf digits=17 abs_diff=inf nan or inf result=false
OK
Test 2/23 approxEql.same...
approxEql: x=0.0e+00 y=0.0e+00 digits=0 digits == 0 result=true
approxEql: x=0.0e+00 y=0.0e+00 digits=1 x == y result=true
approxEql: x=0.0e+00 y=0.0e+00 digits=2 x == y result=true
approxEql: x=0.0e+00 y=0.0e+00 digits=3 x == y result=true
approxEql: x=0.0e+00 y=0.0e+00 digits=4 x == y result=true
approxEql: x=0.0e+00 y=0.0e+00 digits=5 x == y result=true
approxEql: x=0.0e+00 y=0.0e+00 digits=6 x == y result=true
approxEql: x=0.0e+00 y=0.0e+00 digits=7 x == y result=true
approxEql: x=0.0e+00 y=0.0e+00 digits=8 x == y result=true
approxEql: x=0.0e+00 y=0.0e+00 digits=9 x == y result=true
approxEql: x=0.0e+00 y=0.0e+00 digits=10 x == y result=true
approxEql: x=0.0e+00 y=0.0e+00 digits=11 x == y result=true
approxEql: x=0.0e+00 y=0.0e+00 digits=12 x == y result=true
approxEql: x=0.0e+00 y=0.0e+00 digits=13 x == y result=true
approxEql: x=0.0e+00 y=0.0e+00 digits=14 x == y result=true
approxEql: x=0.0e+00 y=0.0e+00 digits=15 x == y result=true
approxEql: x=0.0e+00 y=0.0e+00 digits=16 x == y result=true
approxEql: x=0.0e+00 y=0.0e+00 digits=17 x == y result=true
approxEql: x=1.23e-121 y=1.23e-121 digits=17 x == y result=true
approxEql: x=-1.23e-121 y=-1.23e-121 digits=17 x == y result=true
approxEql: x=-1.23e+125 y=-1.23e+125 digits=17 x == y result=true
approxEql: x=1.23e+125 y=1.23e+125 digits=17 x == y result=true
OK
Test 3/23 approxEql.0.fepsilon*1...
approxEql: x=0.0e+00 y=2.220446049250313e-16 digits=0 digits == 0 result=true
approxEql: x=0.0e+00 y=2.220446049250313e-16 digits=1 abs_diff=2.220446049250313e-16 max_diff=1.0e+00 close to 0 result=true
approxEql: x=0.0e+00 y=2.220446049250313e-16 digits=2 abs_diff=2.220446049250313e-16 max_diff=1.0e-01 close to 0 result=true
approxEql: x=0.0e+00 y=2.220446049250313e-16 digits=3 abs_diff=2.220446049250313e-16 max_diff=1.0e-02 close to 0 result=true
approxEql: x=0.0e+00 y=2.220446049250313e-16 digits=4 abs_diff=2.220446049250313e-16 max_diff=1.0e-03 close to 0 result=true
approxEql: x=0.0e+00 y=2.220446049250313e-16 digits=5 abs_diff=2.220446049250313e-16 max_diff=1.0e-04 close to 0 result=true
approxEql: x=0.0e+00 y=2.220446049250313e-16 digits=6 abs_diff=2.220446049250313e-16 max_diff=1.0e-05 close to 0 result=true
approxEql: x=0.0e+00 y=2.220446049250313e-16 digits=7 abs_diff=2.220446049250313e-16 max_diff=1.0e-06 close to 0 result=true
approxEql: x=0.0e+00 y=2.220446049250313e-16 digits=8 abs_diff=2.220446049250313e-16 max_diff=1.0e-07 close to 0 result=true
approxEql: x=0.0e+00 y=2.220446049250313e-16 digits=9 abs_diff=2.220446049250313e-16 max_diff=1.0e-08 close to 0 result=true
approxEql: x=0.0e+00 y=2.220446049250313e-16 digits=10 abs_diff=2.220446049250313e-16 max_diff=1.0e-09 close to 0 result=true
approxEql: x=0.0e+00 y=2.220446049250313e-16 digits=11 abs_diff=2.220446049250313e-16 max_diff=1.0e-10 close to 0 result=true
approxEql: x=0.0e+00 y=2.220446049250313e-16 digits=12 abs_diff=2.220446049250313e-16 max_diff=1.0e-11 close to 0 result=true
approxEql: x=0.0e+00 y=2.220446049250313e-16 digits=13 abs_diff=2.220446049250313e-16 max_diff=1.0e-12 close to 0 result=true
approxEql: x=0.0e+00 y=2.220446049250313e-16 digits=14 abs_diff=2.220446049250313e-16 max_diff=1.0e-13 close to 0 result=true
approxEql: x=0.0e+00 y=2.220446049250313e-16 digits=15 abs_diff=2.220446049250313e-16 max_diff=1.0e-14 close to 0 result=true
approxEql: x=0.0e+00 y=2.220446049250313e-16 digits=16 abs_diff=2.220446049250313e-16 max_diff=1.0e-15 close to 0 result=true
approxEql: x=0.0e+00 y=2.220446049250313e-16 digits=17 abs_diff=2.220446049250313e-16 max_diff=1.0e-16 scaled_max_diff=2.220446049250313e-33 scaled_epsilon=4.930380657631324e-32 result=false
OK
Test 4/23 approxEql.0.fepsilon*4...
approxEql: x=0.0e+00 y=8.881784197001253e-16 digits=0 digits == 0 result=true
approxEql: x=0.0e+00 y=8.881784197001253e-16 digits=1 abs_diff=8.881784197001253e-16 max_diff=1.0e+00 close to 0 result=true
approxEql: x=0.0e+00 y=8.881784197001253e-16 digits=2 abs_diff=8.881784197001253e-16 max_diff=1.0e-01 close to 0 result=true
approxEql: x=0.0e+00 y=8.881784197001253e-16 digits=3 abs_diff=8.881784197001253e-16 max_diff=1.0e-02 close to 0 result=true
approxEql: x=0.0e+00 y=8.881784197001253e-16 digits=4 abs_diff=8.881784197001253e-16 max_diff=1.0e-03 close to 0 result=true
approxEql: x=0.0e+00 y=8.881784197001253e-16 digits=5 abs_diff=8.881784197001253e-16 max_diff=1.0e-04 close to 0 result=true
approxEql: x=0.0e+00 y=8.881784197001253e-16 digits=6 abs_diff=8.881784197001253e-16 max_diff=1.0e-05 close to 0 result=true
approxEql: x=0.0e+00 y=8.881784197001253e-16 digits=7 abs_diff=8.881784197001253e-16 max_diff=1.0e-06 close to 0 result=true
approxEql: x=0.0e+00 y=8.881784197001253e-16 digits=8 abs_diff=8.881784197001253e-16 max_diff=1.0e-07 close to 0 result=true
approxEql: x=0.0e+00 y=8.881784197001253e-16 digits=9 abs_diff=8.881784197001253e-16 max_diff=1.0e-08 close to 0 result=true
approxEql: x=0.0e+00 y=8.881784197001253e-16 digits=10 abs_diff=8.881784197001253e-16 max_diff=1.0e-09 close to 0 result=true
approxEql: x=0.0e+00 y=8.881784197001253e-16 digits=11 abs_diff=8.881784197001253e-16 max_diff=1.0e-10 close to 0 result=true
approxEql: x=0.0e+00 y=8.881784197001253e-16 digits=12 abs_diff=8.881784197001253e-16 max_diff=1.0e-11 close to 0 result=true
approxEql: x=0.0e+00 y=8.881784197001253e-16 digits=13 abs_diff=8.881784197001253e-16 max_diff=1.0e-12 close to 0 result=true
approxEql: x=0.0e+00 y=8.881784197001253e-16 digits=14 abs_diff=8.881784197001253e-16 max_diff=1.0e-13 close to 0 result=true
approxEql: x=0.0e+00 y=8.881784197001253e-16 digits=15 abs_diff=8.881784197001253e-16 max_diff=1.0e-14 close to 0 result=true
approxEql: x=0.0e+00 y=8.881784197001253e-16 digits=16 abs_diff=8.881784197001253e-16 max_diff=1.0e-15 close to 0 result=true
approxEql: x=0.0e+00 y=8.881784197001253e-16 digits=17 abs_diff=8.881784197001253e-16 max_diff=1.0e-16 scaled_max_diff=8.881784197001252e-33 scaled_epsilon=1.9721522630525296e-31 result=false
OK
Test 5/23 approxEql.0.fepsilon*5...
approxEql: x=0.0e+00 y=1.1102230246251565e-15 digits=0 digits == 0 result=true
approxEql: x=0.0e+00 y=1.1102230246251565e-15 digits=1 abs_diff=1.1102230246251565e-15 max_diff=1.0e+00 close to 0 result=true
approxEql: x=0.0e+00 y=1.1102230246251565e-15 digits=2 abs_diff=1.1102230246251565e-15 max_diff=1.0e-01 close to 0 result=true
approxEql: x=0.0e+00 y=1.1102230246251565e-15 digits=3 abs_diff=1.1102230246251565e-15 max_diff=1.0e-02 close to 0 result=true
approxEql: x=0.0e+00 y=1.1102230246251565e-15 digits=4 abs_diff=1.1102230246251565e-15 max_diff=1.0e-03 close to 0 result=true
approxEql: x=0.0e+00 y=1.1102230246251565e-15 digits=5 abs_diff=1.1102230246251565e-15 max_diff=1.0e-04 close to 0 result=true
approxEql: x=0.0e+00 y=1.1102230246251565e-15 digits=6 abs_diff=1.1102230246251565e-15 max_diff=1.0e-05 close to 0 result=true
approxEql: x=0.0e+00 y=1.1102230246251565e-15 digits=7 abs_diff=1.1102230246251565e-15 max_diff=1.0e-06 close to 0 result=true
approxEql: x=0.0e+00 y=1.1102230246251565e-15 digits=8 abs_diff=1.1102230246251565e-15 max_diff=1.0e-07 close to 0 result=true
approxEql: x=0.0e+00 y=1.1102230246251565e-15 digits=9 abs_diff=1.1102230246251565e-15 max_diff=1.0e-08 close to 0 result=true
approxEql: x=0.0e+00 y=1.1102230246251565e-15 digits=10 abs_diff=1.1102230246251565e-15 max_diff=1.0e-09 close to 0 result=true
approxEql: x=0.0e+00 y=1.1102230246251565e-15 digits=11 abs_diff=1.1102230246251565e-15 max_diff=1.0e-10 close to 0 result=true
approxEql: x=0.0e+00 y=1.1102230246251565e-15 digits=12 abs_diff=1.1102230246251565e-15 max_diff=1.0e-11 close to 0 result=true
approxEql: x=0.0e+00 y=1.1102230246251565e-15 digits=13 abs_diff=1.1102230246251565e-15 max_diff=1.0e-12 close to 0 result=true
approxEql: x=0.0e+00 y=1.1102230246251565e-15 digits=14 abs_diff=1.1102230246251565e-15 max_diff=1.0e-13 close to 0 result=true
approxEql: x=0.0e+00 y=1.1102230246251565e-15 digits=15 abs_diff=1.1102230246251565e-15 max_diff=1.0e-14 close to 0 result=true
approxEql: x=0.0e+00 y=1.1102230246251565e-15 digits=16 abs_diff=1.1102230246251565e-15 max_diff=1.0e-15 scaled_max_diff=1.1102230246251566e-31 scaled_epsilon=2.465190328815662e-31 result=false
approxEql: x=0.0e+00 y=1.1102230246251565e-15 digits=17 abs_diff=1.1102230246251565e-15 max_diff=1.0e-16 scaled_max_diff=1.1102230246251567e-32 scaled_epsilon=2.465190328815662e-31 result=false
OK
Test 6/23 approxEql.0.fepsilon*45...
approxEql: x=0.0e+00 y=9.992007221626409e-15 digits=0 digits == 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-15 digits=1 abs_diff=9.992007221626409e-15 max_diff=1.0e+00 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-15 digits=2 abs_diff=9.992007221626409e-15 max_diff=1.0e-01 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-15 digits=3 abs_diff=9.992007221626409e-15 max_diff=1.0e-02 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-15 digits=4 abs_diff=9.992007221626409e-15 max_diff=1.0e-03 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-15 digits=5 abs_diff=9.992007221626409e-15 max_diff=1.0e-04 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-15 digits=6 abs_diff=9.992007221626409e-15 max_diff=1.0e-05 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-15 digits=7 abs_diff=9.992007221626409e-15 max_diff=1.0e-06 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-15 digits=8 abs_diff=9.992007221626409e-15 max_diff=1.0e-07 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-15 digits=9 abs_diff=9.992007221626409e-15 max_diff=1.0e-08 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-15 digits=10 abs_diff=9.992007221626409e-15 max_diff=1.0e-09 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-15 digits=11 abs_diff=9.992007221626409e-15 max_diff=1.0e-10 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-15 digits=12 abs_diff=9.992007221626409e-15 max_diff=1.0e-11 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-15 digits=13 abs_diff=9.992007221626409e-15 max_diff=1.0e-12 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-15 digits=14 abs_diff=9.992007221626409e-15 max_diff=1.0e-13 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-15 digits=15 abs_diff=9.992007221626409e-15 max_diff=1.0e-14 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-15 digits=16 abs_diff=9.992007221626409e-15 max_diff=1.0e-15 scaled_max_diff=9.99200722162641e-31 scaled_epsilon=2.2186712959340957e-30 result=false
approxEql: x=0.0e+00 y=9.992007221626409e-15 digits=17 abs_diff=9.992007221626409e-15 max_diff=1.0e-16 scaled_max_diff=9.99200722162641e-32 scaled_epsilon=2.2186712959340957e-30 result=false
OK
Test 7/23 approxEql.0.fepsilon*46...
approxEql: x=0.0e+00 y=1.021405182655144e-14 digits=0 digits == 0 result=true
approxEql: x=0.0e+00 y=1.021405182655144e-14 digits=1 abs_diff=1.021405182655144e-14 max_diff=1.0e+00 close to 0 result=true
approxEql: x=0.0e+00 y=1.021405182655144e-14 digits=2 abs_diff=1.021405182655144e-14 max_diff=1.0e-01 close to 0 result=true
approxEql: x=0.0e+00 y=1.021405182655144e-14 digits=3 abs_diff=1.021405182655144e-14 max_diff=1.0e-02 close to 0 result=true
approxEql: x=0.0e+00 y=1.021405182655144e-14 digits=4 abs_diff=1.021405182655144e-14 max_diff=1.0e-03 close to 0 result=true
approxEql: x=0.0e+00 y=1.021405182655144e-14 digits=5 abs_diff=1.021405182655144e-14 max_diff=1.0e-04 close to 0 result=true
approxEql: x=0.0e+00 y=1.021405182655144e-14 digits=6 abs_diff=1.021405182655144e-14 max_diff=1.0e-05 close to 0 result=true
approxEql: x=0.0e+00 y=1.021405182655144e-14 digits=7 abs_diff=1.021405182655144e-14 max_diff=1.0e-06 close to 0 result=true
approxEql: x=0.0e+00 y=1.021405182655144e-14 digits=8 abs_diff=1.021405182655144e-14 max_diff=1.0e-07 close to 0 result=true
approxEql: x=0.0e+00 y=1.021405182655144e-14 digits=9 abs_diff=1.021405182655144e-14 max_diff=1.0e-08 close to 0 result=true
approxEql: x=0.0e+00 y=1.021405182655144e-14 digits=10 abs_diff=1.021405182655144e-14 max_diff=1.0e-09 close to 0 result=true
approxEql: x=0.0e+00 y=1.021405182655144e-14 digits=11 abs_diff=1.021405182655144e-14 max_diff=1.0e-10 close to 0 result=true
approxEql: x=0.0e+00 y=1.021405182655144e-14 digits=12 abs_diff=1.021405182655144e-14 max_diff=1.0e-11 close to 0 result=true
approxEql: x=0.0e+00 y=1.021405182655144e-14 digits=13 abs_diff=1.021405182655144e-14 max_diff=1.0e-12 close to 0 result=true
approxEql: x=0.0e+00 y=1.021405182655144e-14 digits=14 abs_diff=1.021405182655144e-14 max_diff=1.0e-13 close to 0 result=true
approxEql: x=0.0e+00 y=1.021405182655144e-14 digits=15 abs_diff=1.021405182655144e-14 max_diff=1.0e-14 scaled_max_diff=1.0214051826551439e-29 scaled_epsilon=2.267975102510409e-30 result=false
approxEql: x=0.0e+00 y=1.021405182655144e-14 digits=16 abs_diff=1.021405182655144e-14 max_diff=1.0e-15 scaled_max_diff=1.0214051826551441e-30 scaled_epsilon=2.267975102510409e-30 result=false
approxEql: x=0.0e+00 y=1.021405182655144e-14 digits=17 abs_diff=1.021405182655144e-14 max_diff=1.0e-16 scaled_max_diff=1.021405182655144e-31 scaled_epsilon=2.267975102510409e-30 result=false
OK
Test 8/23 approxEql.0.fepsilon*450...
approxEql: x=0.0e+00 y=9.992007221626409e-14 digits=0 digits == 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-14 digits=1 abs_diff=9.992007221626409e-14 max_diff=1.0e+00 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-14 digits=2 abs_diff=9.992007221626409e-14 max_diff=1.0e-01 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-14 digits=3 abs_diff=9.992007221626409e-14 max_diff=1.0e-02 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-14 digits=4 abs_diff=9.992007221626409e-14 max_diff=1.0e-03 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-14 digits=5 abs_diff=9.992007221626409e-14 max_diff=1.0e-04 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-14 digits=6 abs_diff=9.992007221626409e-14 max_diff=1.0e-05 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-14 digits=7 abs_diff=9.992007221626409e-14 max_diff=1.0e-06 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-14 digits=8 abs_diff=9.992007221626409e-14 max_diff=1.0e-07 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-14 digits=9 abs_diff=9.992007221626409e-14 max_diff=1.0e-08 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-14 digits=10 abs_diff=9.992007221626409e-14 max_diff=1.0e-09 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-14 digits=11 abs_diff=9.992007221626409e-14 max_diff=1.0e-10 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-14 digits=12 abs_diff=9.992007221626409e-14 max_diff=1.0e-11 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-14 digits=13 abs_diff=9.992007221626409e-14 max_diff=1.0e-12 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-14 digits=14 abs_diff=9.992007221626409e-14 max_diff=1.0e-13 close to 0 result=true
approxEql: x=0.0e+00 y=9.992007221626409e-14 digits=15 abs_diff=9.992007221626409e-14 max_diff=1.0e-14 scaled_max_diff=9.992007221626409e-29 scaled_epsilon=2.2186712959340957e-29 result=false
approxEql: x=0.0e+00 y=9.992007221626409e-14 digits=16 abs_diff=9.992007221626409e-14 max_diff=1.0e-15 scaled_max_diff=9.99200722162641e-30 scaled_epsilon=2.2186712959340957e-29 result=false
approxEql: x=0.0e+00 y=9.992007221626409e-14 digits=17 abs_diff=9.992007221626409e-14 max_diff=1.0e-16 scaled_max_diff=9.992007221626408e-31 scaled_epsilon=2.2186712959340957e-29 result=false
OK
Test 9/23 approxEql.0.fepsilon*451...
approxEql: x=0.0e+00 y=1.0014211682118912e-13 digits=0 digits == 0 result=true
approxEql: x=0.0e+00 y=1.0014211682118912e-13 digits=1 abs_diff=1.0014211682118912e-13 max_diff=1.0e+00 close to 0 result=true
approxEql: x=0.0e+00 y=1.0014211682118912e-13 digits=2 abs_diff=1.0014211682118912e-13 max_diff=1.0e-01 close to 0 result=true
approxEql: x=0.0e+00 y=1.0014211682118912e-13 digits=3 abs_diff=1.0014211682118912e-13 max_diff=1.0e-02 close to 0 result=true
approxEql: x=0.0e+00 y=1.0014211682118912e-13 digits=4 abs_diff=1.0014211682118912e-13 max_diff=1.0e-03 close to 0 result=true
approxEql: x=0.0e+00 y=1.0014211682118912e-13 digits=5 abs_diff=1.0014211682118912e-13 max_diff=1.0e-04 close to 0 result=true
approxEql: x=0.0e+00 y=1.0014211682118912e-13 digits=6 abs_diff=1.0014211682118912e-13 max_diff=1.0e-05 close to 0 result=true
approxEql: x=0.0e+00 y=1.0014211682118912e-13 digits=7 abs_diff=1.0014211682118912e-13 max_diff=1.0e-06 close to 0 result=true
approxEql: x=0.0e+00 y=1.0014211682118912e-13 digits=8 abs_diff=1.0014211682118912e-13 max_diff=1.0e-07 close to 0 result=true
approxEql: x=0.0e+00 y=1.0014211682118912e-13 digits=9 abs_diff=1.0014211682118912e-13 max_diff=1.0e-08 close to 0 result=true
approxEql: x=0.0e+00 y=1.0014211682118912e-13 digits=10 abs_diff=1.0014211682118912e-13 max_diff=1.0e-09 close to 0 result=true
approxEql: x=0.0e+00 y=1.0014211682118912e-13 digits=11 abs_diff=1.0014211682118912e-13 max_diff=1.0e-10 close to 0 result=true
approxEql: x=0.0e+00 y=1.0014211682118912e-13 digits=12 abs_diff=1.0014211682118912e-13 max_diff=1.0e-11 close to 0 result=true
approxEql: x=0.0e+00 y=1.0014211682118912e-13 digits=13 abs_diff=1.0014211682118912e-13 max_diff=1.0e-12 close to 0 result=true
approxEql: x=0.0e+00 y=1.0014211682118912e-13 digits=14 abs_diff=1.0014211682118912e-13 max_diff=1.0e-13 scaled_max_diff=1.0014211682118914e-27 scaled_epsilon=2.223601676591727e-29 result=false
approxEql: x=0.0e+00 y=1.0014211682118912e-13 digits=15 abs_diff=1.0014211682118912e-13 max_diff=1.0e-14 scaled_max_diff=1.0014211682118912e-28 scaled_epsilon=2.223601676591727e-29 result=false
approxEql: x=0.0e+00 y=1.0014211682118912e-13 digits=16 abs_diff=1.0014211682118912e-13 max_diff=1.0e-15 scaled_max_diff=1.0014211682118913e-29 scaled_epsilon=2.223601676591727e-29 result=false
approxEql: x=0.0e+00 y=1.0014211682118912e-13 digits=17 abs_diff=1.0014211682118912e-13 max_diff=1.0e-16 scaled_max_diff=1.0014211682118911e-30 scaled_epsilon=2.223601676591727e-29 result=false
OK
Test 10/23 approxEql.sum.near0.f64...
x=1.0e+00 end=9.999999999999062e-01
approxEql: x=1.0e+00 y=9.999999999999062e-01 digits=0 digits == 0 result=true
approxEql: x=1.0e+00 y=9.999999999999062e-01 digits=1 abs_diff=9.381384558082573e-14 max_diff=1.0e+00 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999062e-01 digits=2 abs_diff=9.381384558082573e-14 max_diff=1.0e-01 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999062e-01 digits=3 abs_diff=9.381384558082573e-14 max_diff=1.0e-02 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999062e-01 digits=4 abs_diff=9.381384558082573e-14 max_diff=1.0e-03 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999062e-01 digits=5 abs_diff=9.381384558082573e-14 max_diff=1.0e-04 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999062e-01 digits=6 abs_diff=9.381384558082573e-14 max_diff=1.0e-05 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999062e-01 digits=7 abs_diff=9.381384558082573e-14 max_diff=1.0e-06 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999062e-01 digits=8 abs_diff=9.381384558082573e-14 max_diff=1.0e-07 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999062e-01 digits=9 abs_diff=9.381384558082573e-14 max_diff=1.0e-08 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999062e-01 digits=10 abs_diff=9.381384558082573e-14 max_diff=1.0e-09 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999062e-01 digits=11 abs_diff=9.381384558082573e-14 max_diff=1.0e-10 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999062e-01 digits=12 abs_diff=9.381384558082573e-14 max_diff=1.0e-11 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999062e-01 digits=13 abs_diff=9.381384558082573e-14 max_diff=1.0e-12 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999062e-01 digits=14 abs_diff=9.381384558082573e-14 max_diff=1.0e-13 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999062e-01 digits=15 abs_diff=9.381384558082573e-14 max_diff=1.0e-14 scaled_max_diff=1.0e-15 scaled_epsilon=2.220446049250313e-16 result=false
approxEql: x=1.0e+00 y=9.999999999999062e-01 digits=16 abs_diff=9.381384558082573e-14 max_diff=1.0e-15 scaled_max_diff=1.0000000000000001e-16 scaled_epsilon=2.220446049250313e-16 result=false
approxEql: x=1.0e+00 y=9.999999999999062e-01 digits=17 abs_diff=9.381384558082573e-14 max_diff=1.0e-16 scaled_max_diff=9.999999999999999e-18 scaled_epsilon=2.220446049250313e-16 result=false
OK
Test 11/23 approxEql.sum.near0.f32...
x=1.0e+00 end=9.99990701e-01
approxEql: x=1.0e+00 y=9.99990701e-01 digits=0 digits == 0 result=true
approxEql: x=1.0e+00 y=9.99990701e-01 digits=1 abs_diff=9.29832458e-06 max_diff=1.0e+00 close to 0 result=true
approxEql: x=1.0e+00 y=9.99990701e-01 digits=2 abs_diff=9.29832458e-06 max_diff=1.00000001e-01 close to 0 result=true
approxEql: x=1.0e+00 y=9.99990701e-01 digits=3 abs_diff=9.29832458e-06 max_diff=9.99999977e-03 close to 0 result=true
approxEql: x=1.0e+00 y=9.99990701e-01 digits=4 abs_diff=9.29832458e-06 max_diff=1.00000004e-03 close to 0 result=true
approxEql: x=1.0e+00 y=9.99990701e-01 digits=5 abs_diff=9.29832458e-06 max_diff=9.99999974e-05 close to 0 result=true
approxEql: x=1.0e+00 y=9.99990701e-01 digits=6 abs_diff=9.29832458e-06 max_diff=9.99999974e-06 close to 0 result=true
approxEql: x=1.0e+00 y=9.99990701e-01 digits=7 abs_diff=9.29832458e-06 max_diff=9.99999997e-07 scaled_max_diff=1.00000001e-07 scaled_epsilon=1.19209289e-07 result=false
approxEql: x=1.0e+00 y=9.99990701e-01 digits=8 abs_diff=9.29832458e-06 max_diff=1.00000001e-07 scaled_max_diff=9.99999993e-09 scaled_epsilon=1.19209289e-07 result=false
approxEql: x=1.0e+00 y=9.99990701e-01 digits=9 abs_diff=9.29832458e-06 max_diff=9.99999993e-09 scaled_max_diff=9.99999971e-10 scaled_epsilon=1.19209289e-07 result=false
approxEql: x=1.0e+00 y=9.99990701e-01 digits=10 abs_diff=9.29832458e-06 max_diff=9.99999971e-10 scaled_max_diff=9.99999943e-11 scaled_epsilon=1.19209289e-07 result=false
approxEql: x=1.0e+00 y=9.99990701e-01 digits=11 abs_diff=9.29832458e-06 max_diff=1.00000001e-10 scaled_max_diff=9.99999996e-12 scaled_epsilon=1.19209289e-07 result=false
approxEql: x=1.0e+00 y=9.99990701e-01 digits=12 abs_diff=9.29832458e-06 max_diff=9.99999996e-12 scaled_max_diff=9.99999996e-13 scaled_epsilon=1.19209289e-07 result=false
approxEql: x=1.0e+00 y=9.99990701e-01 digits=13 abs_diff=9.29832458e-06 max_diff=9.99999996e-13 scaled_max_diff=9.99999982e-14 scaled_epsilon=1.19209289e-07 result=false
approxEql: x=1.0e+00 y=9.99990701e-01 digits=14 abs_diff=9.29832458e-06 max_diff=1.00000005e-13 scaled_max_diff=1.00000006e-14 scaled_epsilon=1.19209289e-07 result=false
approxEql: x=1.0e+00 y=9.99990701e-01 digits=15 abs_diff=9.29832458e-06 max_diff=9.99999982e-15 scaled_max_diff=1.00000000e-15 scaled_epsilon=1.19209289e-07 result=false
approxEql: x=1.0e+00 y=9.99990701e-01 digits=16 abs_diff=9.29832458e-06 max_diff=1.00000000e-15 scaled_max_diff=1.00000001e-16 scaled_epsilon=1.19209289e-07 result=false
approxEql: x=1.0e+00 y=9.99990701e-01 digits=17 abs_diff=9.29832458e-06 max_diff=9.99999950e-17 scaled_max_diff=9.99999983e-18 scaled_epsilon=1.19209289e-07 result=false
OK
Test 12/23 approxEql.sum.large.f64...
x=8.988465674311579e+307 end=8.988465674311085e+307
approxEql: x=8.988465674311579e+307 y=8.988465674311085e+307 digits=0 digits == 0 result=true
approxEql: x=8.988465674311579e+307 y=8.988465674311085e+307 digits=1 abs_diff=4.9397047660984315e+294 max_diff=1.0e+00 scaled_max_diff=8.988465674311579e+306 scaled_epsilon=1.9958403095347196e+292 result=true
approxEql: x=8.988465674311579e+307 y=8.988465674311085e+307 digits=2 abs_diff=4.9397047660984315e+294 max_diff=1.0e-01 scaled_max_diff=8.988465674311578e+305 scaled_epsilon=1.9958403095347196e+292 result=true
approxEql: x=8.988465674311579e+307 y=8.988465674311085e+307 digits=3 abs_diff=4.9397047660984315e+294 max_diff=1.0e-02 scaled_max_diff=8.988465674311578e+304 scaled_epsilon=1.9958403095347196e+292 result=true
approxEql: x=8.988465674311579e+307 y=8.988465674311085e+307 digits=4 abs_diff=4.9397047660984315e+294 max_diff=1.0e-03 scaled_max_diff=8.988465674311578e+303 scaled_epsilon=1.9958403095347196e+292 result=true
approxEql: x=8.988465674311579e+307 y=8.988465674311085e+307 digits=5 abs_diff=4.9397047660984315e+294 max_diff=1.0e-04 scaled_max_diff=8.988465674311579e+302 scaled_epsilon=1.9958403095347196e+292 result=true
approxEql: x=8.988465674311579e+307 y=8.988465674311085e+307 digits=6 abs_diff=4.9397047660984315e+294 max_diff=1.0e-05 scaled_max_diff=8.98846567431158e+301 scaled_epsilon=1.9958403095347196e+292 result=true
approxEql: x=8.988465674311579e+307 y=8.988465674311085e+307 digits=7 abs_diff=4.9397047660984315e+294 max_diff=1.0e-06 scaled_max_diff=8.988465674311577e+300 scaled_epsilon=1.9958403095347196e+292 result=true
approxEql: x=8.988465674311579e+307 y=8.988465674311085e+307 digits=8 abs_diff=4.9397047660984315e+294 max_diff=1.0e-07 scaled_max_diff=8.988465674311578e+299 scaled_epsilon=1.9958403095347196e+292 result=true
approxEql: x=8.988465674311579e+307 y=8.988465674311085e+307 digits=9 abs_diff=4.9397047660984315e+294 max_diff=1.0e-08 scaled_max_diff=8.988465674311578e+298 scaled_epsilon=1.9958403095347196e+292 result=true
approxEql: x=8.988465674311579e+307 y=8.988465674311085e+307 digits=10 abs_diff=4.9397047660984315e+294 max_diff=1.0e-09 scaled_max_diff=8.988465674311579e+297 scaled_epsilon=1.9958403095347196e+292 result=true
approxEql: x=8.988465674311579e+307 y=8.988465674311085e+307 digits=11 abs_diff=4.9397047660984315e+294 max_diff=1.0e-10 scaled_max_diff=8.988465674311579e+296 scaled_epsilon=1.9958403095347196e+292 result=true
approxEql: x=8.988465674311579e+307 y=8.988465674311085e+307 digits=12 abs_diff=4.9397047660984315e+294 max_diff=1.0e-11 scaled_max_diff=8.988465674311578e+295 scaled_epsilon=1.9958403095347196e+292 result=true
approxEql: x=8.988465674311579e+307 y=8.988465674311085e+307 digits=13 abs_diff=4.9397047660984315e+294 max_diff=1.0e-12 scaled_max_diff=8.988465674311578e+294 scaled_epsilon=1.9958403095347196e+292 result=true
approxEql: x=8.988465674311579e+307 y=8.988465674311085e+307 digits=14 abs_diff=4.9397047660984315e+294 max_diff=1.0e-13 scaled_max_diff=8.988465674311578e+293 scaled_epsilon=1.9958403095347196e+292 result=false
approxEql: x=8.988465674311579e+307 y=8.988465674311085e+307 digits=15 abs_diff=4.9397047660984315e+294 max_diff=1.0e-14 scaled_max_diff=8.988465674311578e+292 scaled_epsilon=1.9958403095347196e+292 result=false
approxEql: x=8.988465674311579e+307 y=8.988465674311085e+307 digits=16 abs_diff=4.9397047660984315e+294 max_diff=1.0e-15 scaled_max_diff=8.988465674311578e+291 scaled_epsilon=1.9958403095347196e+292 result=false
approxEql: x=8.988465674311579e+307 y=8.988465674311085e+307 digits=17 abs_diff=4.9397047660984315e+294 max_diff=1.0e-16 scaled_max_diff=8.988465674311579e+290 scaled_epsilon=1.9958403095347196e+292 result=false
OK
Test 13/23 approxEql.sum.large.f32...
x=1.70141173e+38 end=1.70141102e+38
approxEql: x=1.70141173e+38 y=1.70141102e+38 digits=0 digits == 0 result=true
approxEql: x=1.70141173e+38 y=1.70141102e+38 digits=1 abs_diff=7.09884336e+31 max_diff=1.0e+00 scaled_max_diff=1.70141173e+37 scaled_epsilon=2.02824083e+31 result=true
approxEql: x=1.70141173e+38 y=1.70141102e+38 digits=2 abs_diff=7.09884336e+31 max_diff=1.00000001e-01 scaled_max_diff=1.70141179e+36 scaled_epsilon=2.02824083e+31 result=true
approxEql: x=1.70141173e+38 y=1.70141102e+38 digits=3 abs_diff=7.09884336e+31 max_diff=9.99999977e-03 scaled_max_diff=1.70141171e+35 scaled_epsilon=2.02824083e+31 result=true
approxEql: x=1.70141173e+38 y=1.70141102e+38 digits=4 abs_diff=7.09884336e+31 max_diff=1.00000004e-03 scaled_max_diff=1.70141166e+34 scaled_epsilon=2.02824083e+31 result=true
approxEql: x=1.70141173e+38 y=1.70141102e+38 digits=5 abs_diff=7.09884336e+31 max_diff=9.99999974e-05 scaled_max_diff=1.70141163e+33 scaled_epsilon=2.02824083e+31 result=true
approxEql: x=1.70141173e+38 y=1.70141102e+38 digits=6 abs_diff=7.09884336e+31 max_diff=9.99999974e-06 scaled_max_diff=1.70141163e+32 scaled_epsilon=2.02824083e+31 result=true
approxEql: x=1.70141173e+38 y=1.70141102e+38 digits=7 abs_diff=7.09884336e+31 max_diff=9.99999997e-07 scaled_max_diff=1.70141161e+31 scaled_epsilon=2.02824083e+31 result=false
approxEql: x=1.70141173e+38 y=1.70141102e+38 digits=8 abs_diff=7.09884336e+31 max_diff=1.00000001e-07 scaled_max_diff=1.70141167e+30 scaled_epsilon=2.02824083e+31 result=false
approxEql: x=1.70141173e+38 y=1.70141102e+38 digits=9 abs_diff=7.09884336e+31 max_diff=9.99999993e-09 scaled_max_diff=1.70141159e+29 scaled_epsilon=2.02824083e+31 result=false
approxEql: x=1.70141173e+38 y=1.70141102e+38 digits=10 abs_diff=7.09884336e+31 max_diff=9.99999971e-10 scaled_max_diff=1.70141162e+28 scaled_epsilon=2.02824083e+31 result=false
approxEql: x=1.70141173e+38 y=1.70141102e+38 digits=11 abs_diff=7.09884336e+31 max_diff=1.00000001e-10 scaled_max_diff=1.70141168e+27 scaled_epsilon=2.02824083e+31 result=false
approxEql: x=1.70141173e+38 y=1.70141102e+38 digits=12 abs_diff=7.09884336e+31 max_diff=9.99999996e-12 scaled_max_diff=1.70141164e+26 scaled_epsilon=2.02824083e+31 result=false
approxEql: x=1.70141173e+38 y=1.70141102e+38 digits=13 abs_diff=7.09884336e+31 max_diff=9.99999996e-13 scaled_max_diff=1.70141168e+25 scaled_epsilon=2.02824083e+31 result=false
approxEql: x=1.70141173e+38 y=1.70141102e+38 digits=14 abs_diff=7.09884336e+31 max_diff=1.00000005e-13 scaled_max_diff=1.70141180e+24 scaled_epsilon=2.02824083e+31 result=false
approxEql: x=1.70141173e+38 y=1.70141102e+38 digits=15 abs_diff=7.09884336e+31 max_diff=9.99999982e-15 scaled_max_diff=1.70141166e+23 scaled_epsilon=2.02824083e+31 result=false
approxEql: x=1.70141173e+38 y=1.70141102e+38 digits=16 abs_diff=7.09884336e+31 max_diff=1.00000000e-15 scaled_max_diff=1.70141163e+22 scaled_epsilon=2.02824083e+31 result=false
approxEql: x=1.70141173e+38 y=1.70141102e+38 digits=17 abs_diff=7.09884336e+31 max_diff=9.99999950e-17 scaled_max_diff=1.70141166e+21 scaled_epsilon=2.02824083e+31 result=false
OK
Test 14/23 approxEql.sub.near0.f64...
x=0.0e+00 end=9.381755897326649e-14
approxEql: x=0.0e+00 y=9.381755897326649e-14 digits=0 digits == 0 result=true
approxEql: x=0.0e+00 y=9.381755897326649e-14 digits=1 abs_diff=9.381755897326649e-14 max_diff=1.0e+00 close to 0 result=true
approxEql: x=0.0e+00 y=9.381755897326649e-14 digits=2 abs_diff=9.381755897326649e-14 max_diff=1.0e-01 close to 0 result=true
approxEql: x=0.0e+00 y=9.381755897326649e-14 digits=3 abs_diff=9.381755897326649e-14 max_diff=1.0e-02 close to 0 result=true
approxEql: x=0.0e+00 y=9.381755897326649e-14 digits=4 abs_diff=9.381755897326649e-14 max_diff=1.0e-03 close to 0 result=true
approxEql: x=0.0e+00 y=9.381755897326649e-14 digits=5 abs_diff=9.381755897326649e-14 max_diff=1.0e-04 close to 0 result=true
approxEql: x=0.0e+00 y=9.381755897326649e-14 digits=6 abs_diff=9.381755897326649e-14 max_diff=1.0e-05 close to 0 result=true
approxEql: x=0.0e+00 y=9.381755897326649e-14 digits=7 abs_diff=9.381755897326649e-14 max_diff=1.0e-06 close to 0 result=true
approxEql: x=0.0e+00 y=9.381755897326649e-14 digits=8 abs_diff=9.381755897326649e-14 max_diff=1.0e-07 close to 0 result=true
approxEql: x=0.0e+00 y=9.381755897326649e-14 digits=9 abs_diff=9.381755897326649e-14 max_diff=1.0e-08 close to 0 result=true
approxEql: x=0.0e+00 y=9.381755897326649e-14 digits=10 abs_diff=9.381755897326649e-14 max_diff=1.0e-09 close to 0 result=true
approxEql: x=0.0e+00 y=9.381755897326649e-14 digits=11 abs_diff=9.381755897326649e-14 max_diff=1.0e-10 close to 0 result=true
approxEql: x=0.0e+00 y=9.381755897326649e-14 digits=12 abs_diff=9.381755897326649e-14 max_diff=1.0e-11 close to 0 result=true
approxEql: x=0.0e+00 y=9.381755897326649e-14 digits=13 abs_diff=9.381755897326649e-14 max_diff=1.0e-12 close to 0 result=true
approxEql: x=0.0e+00 y=9.381755897326649e-14 digits=14 abs_diff=9.381755897326649e-14 max_diff=1.0e-13 close to 0 result=true
approxEql: x=0.0e+00 y=9.381755897326649e-14 digits=15 abs_diff=9.381755897326649e-14 max_diff=1.0e-14 scaled_max_diff=9.38175589732665e-29 scaled_epsilon=2.0831682817249784e-29 result=false
approxEql: x=0.0e+00 y=9.381755897326649e-14 digits=16 abs_diff=9.381755897326649e-14 max_diff=1.0e-15 scaled_max_diff=9.38175589732665e-30 scaled_epsilon=2.0831682817249784e-29 result=false
approxEql: x=0.0e+00 y=9.381755897326649e-14 digits=17 abs_diff=9.381755897326649e-14 max_diff=1.0e-16 scaled_max_diff=9.38175589732665e-31 scaled_epsilon=2.0831682817249784e-29 result=false
OK
Test 15/23 approxEql.sub.near0.f32...
x=0.0e+00 end=9.32463444e-06
approxEql: x=0.0e+00 y=9.32463444e-06 digits=0 digits == 0 result=true
approxEql: x=0.0e+00 y=9.32463444e-06 digits=1 abs_diff=9.32463444e-06 max_diff=1.0e+00 close to 0 result=true
approxEql: x=0.0e+00 y=9.32463444e-06 digits=2 abs_diff=9.32463444e-06 max_diff=1.00000001e-01 close to 0 result=true
approxEql: x=0.0e+00 y=9.32463444e-06 digits=3 abs_diff=9.32463444e-06 max_diff=9.99999977e-03 close to 0 result=true
approxEql: x=0.0e+00 y=9.32463444e-06 digits=4 abs_diff=9.32463444e-06 max_diff=1.00000004e-03 close to 0 result=true
approxEql: x=0.0e+00 y=9.32463444e-06 digits=5 abs_diff=9.32463444e-06 max_diff=9.99999974e-05 close to 0 result=true
approxEql: x=0.0e+00 y=9.32463444e-06 digits=6 abs_diff=9.32463444e-06 max_diff=9.99999974e-06 close to 0 result=true
approxEql: x=0.0e+00 y=9.32463444e-06 digits=7 abs_diff=9.32463444e-06 max_diff=9.99999997e-07 scaled_max_diff=9.32463524e-13 scaled_epsilon=1.11158304e-12 result=false
approxEql: x=0.0e+00 y=9.32463444e-06 digits=8 abs_diff=9.32463444e-06 max_diff=1.00000001e-07 scaled_max_diff=9.32463402e-14 scaled_epsilon=1.11158304e-12 result=false
approxEql: x=0.0e+00 y=9.32463444e-06 digits=9 abs_diff=9.32463444e-06 max_diff=9.99999993e-09 scaled_max_diff=9.32463504e-15 scaled_epsilon=1.11158304e-12 result=false
approxEql: x=0.0e+00 y=9.32463444e-06 digits=10 abs_diff=9.32463444e-06 max_diff=9.99999971e-10 scaled_max_diff=9.32463419e-16 scaled_epsilon=1.11158304e-12 result=false
approxEql: x=0.0e+00 y=9.32463444e-06 digits=11 abs_diff=9.32463444e-06 max_diff=1.00000001e-10 scaled_max_diff=9.32463432e-17 scaled_epsilon=1.11158304e-12 result=false
approxEql: x=0.0e+00 y=9.32463444e-06 digits=12 abs_diff=9.32463444e-06 max_diff=9.99999996e-12 scaled_max_diff=9.32463416e-18 scaled_epsilon=1.11158304e-12 result=false
approxEql: x=0.0e+00 y=9.32463444e-06 digits=13 abs_diff=9.32463444e-06 max_diff=9.99999996e-13 scaled_max_diff=9.32463437e-19 scaled_epsilon=1.11158304e-12 result=false
approxEql: x=0.0e+00 y=9.32463444e-06 digits=14 abs_diff=9.32463444e-06 max_diff=1.00000005e-13 scaled_max_diff=9.32463514e-20 scaled_epsilon=1.11158304e-12 result=false
approxEql: x=0.0e+00 y=9.32463444e-06 digits=15 abs_diff=9.32463444e-06 max_diff=9.99999982e-15 scaled_max_diff=9.32463417e-21 scaled_epsilon=1.11158304e-12 result=false
approxEql: x=0.0e+00 y=9.32463444e-06 digits=16 abs_diff=9.32463444e-06 max_diff=1.00000000e-15 scaled_max_diff=9.32463377e-22 scaled_epsilon=1.11158304e-12 result=false
approxEql: x=0.0e+00 y=9.32463444e-06 digits=17 abs_diff=9.32463444e-06 max_diff=9.99999950e-17 scaled_max_diff=9.32463377e-23 scaled_epsilon=1.11158304e-12 result=false
OK
Test 16/23 approxEql.atan32...
atan(f64(0.2))=1.9739555984988078e-01
atan(f32(0.2))=1.97395563e-01
approxEql: x=1.97395563e-01 y=1.97395995e-01 digits=7 abs_diff=4.32133674e-07 max_diff=9.99999997e-07 close to 0 result=true
approxEql: x=-1.97395563e-01 y=-1.97395995e-01 digits=7 abs_diff=4.32133674e-07 max_diff=9.99999997e-07 close to 0 result=true
approxEql: x=3.30783039e-01 y=3.30783009e-01 digits=7 abs_diff=2.98023223e-08 max_diff=9.99999997e-07 close to 0 result=true
approxEql: x=7.28544652e-01 y=7.28545010e-01 digits=7 abs_diff=3.57627868e-07 max_diff=9.99999997e-07 close to 0 result=true
approxEql: x=9.82793748e-01 y=9.82793986e-01 digits=7 abs_diff=2.38418579e-07 max_diff=9.99999997e-07 close to 0 result=true
OK
Test 17/23 approxEql.123e12.3.digits...
approxEql: x=1.21999997e+14 y=1.23000003e+14 digits=3 abs_diff=1.00000595e+12 max_diff=9.99999977e-03 scaled_max_diff=1.22999996e+11 scaled_epsilon=1.4662743e+07 result=false
approxEql: x=1.23000003e+14 y=1.23000003e+14 digits=3 x == y result=true
approxEql: x=1.24000000e+14 y=1.23000003e+14 digits=3 abs_diff=9.99997571e+11 max_diff=9.99999977e-03 scaled_max_diff=1.23999993e+11 scaled_epsilon=1.4781952e+07 result=false
OK
Test 18/23 approxEql.123e12.4.digits...
approxEql: x=1.22900002e+14 y=1.23000003e+14 digits=4 abs_diff=1.00000595e+11 max_diff=1.00000004e-03 scaled_max_diff=1.23000012e+10 scaled_epsilon=1.4662743e+07 result=false
approxEql: x=1.23000003e+14 y=1.23000003e+14 digits=4 x == y result=true
approxEql: x=1.23100003e+14 y=1.23000003e+14 digits=4 abs_diff=1.00000595e+11 max_diff=1.00000004e-03 scaled_max_diff=1.23100016e+10 scaled_epsilon=1.4674664e+07 result=false
OK
Test 19/23 approxEql.993e12.3.digits...
approxEql: x=9.92000006e+14 y=9.92999995e+14 digits=3 abs_diff=9.99989182e+11 max_diff=9.99999977e-03 scaled_max_diff=9.93000030e+11 scaled_epsilon=1.18374824e+08 result=false
approxEql: x=9.92999995e+14 y=9.92999995e+14 digits=3 x == y result=true
approxEql: x=9.93999984e+14 y=9.92999995e+14 digits=3 abs_diff=9.99989182e+11 max_diff=9.99999977e-03 scaled_max_diff=9.93999912e+11 scaled_epsilon=1.18494032e+08 result=false
OK
Test 20/23 approxEql.993e12.4.digits...
approxEql: x=9.92900003e+14 y=9.92999995e+14 digits=4 abs_diff=9.99922073e+10 max_diff=1.00000004e-03 scaled_max_diff=9.92999997e+10 scaled_epsilon=1.18374824e+08 result=false
approxEql: x=9.92999995e+14 y=9.92999995e+14 digits=4 x == y result=true
approxEql: x=9.93099987e+14 y=9.92999995e+14 digits=4 abs_diff=9.99922073e+10 max_diff=1.00000004e-03 scaled_max_diff=9.93100021e+10 scaled_epsilon=1.18386744e+08 result=false
OK
Test 21/23 fepsilon.f64...OK
Test 22/23 fepsilon.f32...OK
Test 23/23 fepsilon.f16...OK
All tests passed.
```
