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

# Test

```
$ zig test approxeql.zig 
Test 1/18 approxEql.nan.inf...OK
Test 2/18 approxEql.same...OK
Test 3/18 approxEql.epsilon*1...OK
Test 4/18 approxEql.epsilon*4...OK
Test 5/18 approxEql.epsilon*5...OK
Test 6/18 approxEql.epsilon*45...OK
Test 7/18 approxEql.epsilon*46...OK
Test 8/18 approxEql.epsilon*450...OK
Test 9/18 approxEql.epsilon*451...OK
Test 10/18 approxEql.sum.f64...OK
Test 11/18 approxEql.sum.f32...OK
Test 12/18 approxEql.sum.f64...OK
Test 13/18 approxEql.sum.f32...OK
Test 14/18 approxEql.sub.f64...OK
Test 15/18 approxEql.sub.f32...OK
Test 16/18 epsilon.f64...OK
Test 17/18 epsilon.f32...OK
Test 18/18 epsilon.f16...OK
All tests passed.
```

With `const DBG = true` in the approxeql.zig:
```
$ zig test approxeql.zig 
Test 1/18 approxEql.nan.inf...
approxEql: x=nan y=nan digits=17 abs_diff=nan nan or inf result=false
OK
Test 2/18 approxEql.same...
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
Test 3/18 approxEql.epsilon*1...
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
approxEql: x=0.0e+00 y=2.220446049250313e-16 digits=17 abs_diff=2.220446049250313e-16 max_diff=1.0e-16 scaled_max_diff=2.220446049250313e-32 result=false
OK
Test 4/18 approxEql.epsilon*4...
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
approxEql: x=0.0e+00 y=8.881784197001253e-16 digits=17 abs_diff=8.881784197001253e-16 max_diff=1.0e-16 scaled_max_diff=8.881784197001252e-32 result=false
OK
Test 5/18 approxEql.epsilon*5...
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
approxEql: x=0.0e+00 y=1.1102230246251565e-15 digits=16 abs_diff=1.1102230246251565e-15 max_diff=1.0e-15 scaled_max_diff=1.1102230246251567e-30 result=false
approxEql: x=0.0e+00 y=1.1102230246251565e-15 digits=17 abs_diff=1.1102230246251565e-15 max_diff=1.0e-16 scaled_max_diff=1.1102230246251566e-31 result=false
OK
Test 6/18 approxEql.epsilon*45...
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
approxEql: x=0.0e+00 y=9.992007221626409e-15 digits=16 abs_diff=9.992007221626409e-15 max_diff=1.0e-15 scaled_max_diff=9.99200722162641e-30 result=false
approxEql: x=0.0e+00 y=9.992007221626409e-15 digits=17 abs_diff=9.992007221626409e-15 max_diff=1.0e-16 scaled_max_diff=9.992007221626408e-31 result=false
OK
Test 7/18 approxEql.epsilon*46...
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
approxEql: x=0.0e+00 y=1.021405182655144e-14 digits=15 abs_diff=1.021405182655144e-14 max_diff=1.0e-14 scaled_max_diff=1.021405182655144e-28 result=false
approxEql: x=0.0e+00 y=1.021405182655144e-14 digits=16 abs_diff=1.021405182655144e-14 max_diff=1.0e-15 scaled_max_diff=1.0214051826551441e-29 result=false
approxEql: x=0.0e+00 y=1.021405182655144e-14 digits=17 abs_diff=1.021405182655144e-14 max_diff=1.0e-16 scaled_max_diff=1.021405182655144e-30 result=false
OK
Test 8/18 approxEql.epsilon*450...
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
approxEql: x=0.0e+00 y=9.992007221626409e-14 digits=15 abs_diff=9.992007221626409e-14 max_diff=1.0e-14 scaled_max_diff=9.992007221626408e-28 result=false
approxEql: x=0.0e+00 y=9.992007221626409e-14 digits=16 abs_diff=9.992007221626409e-14 max_diff=1.0e-15 scaled_max_diff=9.99200722162641e-29 result=false
approxEql: x=0.0e+00 y=9.992007221626409e-14 digits=17 abs_diff=9.992007221626409e-14 max_diff=1.0e-16 scaled_max_diff=9.992007221626408e-30 result=false
OK
Test 9/18 approxEql.epsilon*451...
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
approxEql: x=0.0e+00 y=1.0014211682118912e-13 digits=14 abs_diff=1.0014211682118912e-13 max_diff=1.0e-13 scaled_max_diff=1.0014211682118913e-26 result=false
approxEql: x=0.0e+00 y=1.0014211682118912e-13 digits=15 abs_diff=1.0014211682118912e-13 max_diff=1.0e-14 scaled_max_diff=1.0014211682118912e-27 result=false
approxEql: x=0.0e+00 y=1.0014211682118912e-13 digits=16 abs_diff=1.0014211682118912e-13 max_diff=1.0e-15 scaled_max_diff=1.0014211682118913e-28 result=false
approxEql: x=0.0e+00 y=1.0014211682118912e-13 digits=17 abs_diff=1.0014211682118912e-13 max_diff=1.0e-16 scaled_max_diff=1.0014211682118912e-29 result=false
OK
Test 10/18 approxEql.sum.f64...
x=1.0e+00 end=9.999999999999999e-01
approxEql: x=1.0e+00 y=9.999999999999999e-01 digits=0 digits == 0 result=true
approxEql: x=1.0e+00 y=9.999999999999999e-01 digits=1 abs_diff=1.1102230246251566e-16 max_diff=1.0e+00 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999999e-01 digits=2 abs_diff=1.1102230246251566e-16 max_diff=1.0e-01 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999999e-01 digits=3 abs_diff=1.1102230246251566e-16 max_diff=1.0e-02 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999999e-01 digits=4 abs_diff=1.1102230246251566e-16 max_diff=1.0e-03 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999999e-01 digits=5 abs_diff=1.1102230246251566e-16 max_diff=1.0e-04 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999999e-01 digits=6 abs_diff=1.1102230246251566e-16 max_diff=1.0e-05 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999999e-01 digits=7 abs_diff=1.1102230246251566e-16 max_diff=1.0e-06 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999999e-01 digits=8 abs_diff=1.1102230246251566e-16 max_diff=1.0e-07 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999999e-01 digits=9 abs_diff=1.1102230246251566e-16 max_diff=1.0e-08 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999999e-01 digits=10 abs_diff=1.1102230246251566e-16 max_diff=1.0e-09 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999999e-01 digits=11 abs_diff=1.1102230246251566e-16 max_diff=1.0e-10 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999999e-01 digits=12 abs_diff=1.1102230246251566e-16 max_diff=1.0e-11 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999999e-01 digits=13 abs_diff=1.1102230246251566e-16 max_diff=1.0e-12 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999999e-01 digits=14 abs_diff=1.1102230246251566e-16 max_diff=1.0e-13 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999999e-01 digits=15 abs_diff=1.1102230246251566e-16 max_diff=1.0e-14 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999999e-01 digits=16 abs_diff=1.1102230246251566e-16 max_diff=1.0e-15 close to 0 result=true
approxEql: x=1.0e+00 y=9.999999999999999e-01 digits=17 abs_diff=1.1102230246251566e-16 max_diff=1.0e-16 scaled_max_diff=1.0e-16 result=false
OK
Test 11/18 approxEql.sum.f32...
x=1.0e+00 end=1.00000011e+00
approxEql: x=1.0e+00 y=1.00000011e+00 digits=0 digits == 0 result=true
approxEql: x=1.0e+00 y=1.00000011e+00 digits=1 abs_diff=1.19209289e-07 max_diff=1.0e+00 close to 0 result=true
approxEql: x=1.0e+00 y=1.00000011e+00 digits=2 abs_diff=1.19209289e-07 max_diff=1.00000001e-01 close to 0 result=true
approxEql: x=1.0e+00 y=1.00000011e+00 digits=3 abs_diff=1.19209289e-07 max_diff=9.99999977e-03 close to 0 result=true
approxEql: x=1.0e+00 y=1.00000011e+00 digits=4 abs_diff=1.19209289e-07 max_diff=1.00000004e-03 close to 0 result=true
approxEql: x=1.0e+00 y=1.00000011e+00 digits=5 abs_diff=1.19209289e-07 max_diff=9.99999974e-05 close to 0 result=true
approxEql: x=1.0e+00 y=1.00000011e+00 digits=6 abs_diff=1.19209289e-07 max_diff=9.99999974e-06 close to 0 result=true
approxEql: x=1.0e+00 y=1.00000011e+00 digits=7 abs_diff=1.19209289e-07 max_diff=9.99999997e-07 close to 0 result=true
approxEql: x=1.0e+00 y=1.00000011e+00 digits=8 abs_diff=1.19209289e-07 max_diff=1.00000001e-07 scaled_max_diff=1.00000015e-07 result=false
approxEql: x=1.0e+00 y=1.00000011e+00 digits=9 abs_diff=1.19209289e-07 max_diff=9.99999993e-09 scaled_max_diff=1.00000008e-08 result=false
approxEql: x=1.0e+00 y=1.00000011e+00 digits=10 abs_diff=1.19209289e-07 max_diff=9.99999971e-10 scaled_max_diff=1.00000008e-09 result=false
approxEql: x=1.0e+00 y=1.00000011e+00 digits=11 abs_diff=1.19209289e-07 max_diff=1.00000001e-10 scaled_max_diff=1.00000015e-10 result=false
approxEql: x=1.0e+00 y=1.00000011e+00 digits=12 abs_diff=1.19209289e-07 max_diff=9.99999996e-12 scaled_max_diff=1.00000008e-11 result=false
approxEql: x=1.0e+00 y=1.00000011e+00 digits=13 abs_diff=1.19209289e-07 max_diff=9.99999996e-13 scaled_max_diff=1.00000010e-12 result=false
approxEql: x=1.0e+00 y=1.00000011e+00 digits=14 abs_diff=1.19209289e-07 max_diff=1.00000005e-13 scaled_max_diff=1.00000018e-13 result=false
approxEql: x=1.0e+00 y=1.00000011e+00 digits=15 abs_diff=1.19209289e-07 max_diff=9.99999982e-15 scaled_max_diff=1.00000006e-14 result=false
approxEql: x=1.0e+00 y=1.00000011e+00 digits=16 abs_diff=1.19209289e-07 max_diff=1.00000000e-15 scaled_max_diff=1.00000010e-15 result=false
approxEql: x=1.0e+00 y=1.00000011e+00 digits=17 abs_diff=1.19209289e-07 max_diff=9.99999950e-17 scaled_max_diff=1.00000008e-16 result=false
OK
Test 12/18 approxEql.sum.f64...
x=1.24e+125 end=1.2400000003757477e+125
approxEql: x=1.24e+125 y=1.2400000003757477e+125 digits=0 digits == 0 result=true
approxEql: x=1.24e+125 y=1.2400000003757477e+125 digits=1 abs_diff=3.757476491363379e+115 max_diff=1.0e+00 scaled_max_diff=1.2400000003757477e+125 result=true
approxEql: x=1.24e+125 y=1.2400000003757477e+125 digits=2 abs_diff=3.757476491363379e+115 max_diff=1.0e-01 scaled_max_diff=1.2400000003757478e+124 result=true
approxEql: x=1.24e+125 y=1.2400000003757477e+125 digits=3 abs_diff=3.757476491363379e+115 max_diff=1.0e-02 scaled_max_diff=1.2400000003757477e+123 result=true
approxEql: x=1.24e+125 y=1.2400000003757477e+125 digits=4 abs_diff=3.757476491363379e+115 max_diff=1.0e-03 scaled_max_diff=1.2400000003757478e+122 result=true
approxEql: x=1.24e+125 y=1.2400000003757477e+125 digits=5 abs_diff=3.757476491363379e+115 max_diff=1.0e-04 scaled_max_diff=1.2400000003757477e+121 result=true
approxEql: x=1.24e+125 y=1.2400000003757477e+125 digits=6 abs_diff=3.757476491363379e+115 max_diff=1.0e-05 scaled_max_diff=1.2400000003757479e+120 result=true
approxEql: x=1.24e+125 y=1.2400000003757477e+125 digits=7 abs_diff=3.757476491363379e+115 max_diff=1.0e-06 scaled_max_diff=1.2400000003757476e+119 result=true
approxEql: x=1.24e+125 y=1.2400000003757477e+125 digits=8 abs_diff=3.757476491363379e+115 max_diff=1.0e-07 scaled_max_diff=1.2400000003757478e+118 result=true
approxEql: x=1.24e+125 y=1.2400000003757477e+125 digits=9 abs_diff=3.757476491363379e+115 max_diff=1.0e-08 scaled_max_diff=1.2400000003757477e+117 result=true
approxEql: x=1.24e+125 y=1.2400000003757477e+125 digits=10 abs_diff=3.757476491363379e+115 max_diff=1.0e-09 scaled_max_diff=1.2400000003757478e+116 result=true
approxEql: x=1.24e+125 y=1.2400000003757477e+125 digits=11 abs_diff=3.757476491363379e+115 max_diff=1.0e-10 scaled_max_diff=1.2400000003757478e+115 result=false
approxEql: x=1.24e+125 y=1.2400000003757477e+125 digits=12 abs_diff=3.757476491363379e+115 max_diff=1.0e-11 scaled_max_diff=1.2400000003757478e+114 result=false
approxEql: x=1.24e+125 y=1.2400000003757477e+125 digits=13 abs_diff=3.757476491363379e+115 max_diff=1.0e-12 scaled_max_diff=1.2400000003757477e+113 result=false
approxEql: x=1.24e+125 y=1.2400000003757477e+125 digits=14 abs_diff=3.757476491363379e+115 max_diff=1.0e-13 scaled_max_diff=1.2400000003757477e+112 result=false
approxEql: x=1.24e+125 y=1.2400000003757477e+125 digits=15 abs_diff=3.757476491363379e+115 max_diff=1.0e-14 scaled_max_diff=1.2400000003757477e+111 result=false
approxEql: x=1.24e+125 y=1.2400000003757477e+125 digits=16 abs_diff=3.757476491363379e+115 max_diff=1.0e-15 scaled_max_diff=1.2400000003757478e+110 result=false
approxEql: x=1.24e+125 y=1.2400000003757477e+125 digits=17 abs_diff=3.757476491363379e+115 max_diff=1.0e-16 scaled_max_diff=1.2400000003757477e+109 result=false
OK
Test 13/18 approxEql.sum.f32...
x=1.24000004e+23 end=1.23990790e+23
approxEql: x=1.24000004e+23 y=1.23990790e+23 digits=0 digits == 0 result=true
approxEql: x=1.24000004e+23 y=1.23990790e+23 digits=1 abs_diff=9.21436483e+18 max_diff=1.0e+00 scaled_max_diff=1.24000004e+23 result=true
approxEql: x=1.24000004e+23 y=1.23990790e+23 digits=2 abs_diff=9.21436483e+18 max_diff=1.00000001e-01 scaled_max_diff=1.24000006e+22 result=true
approxEql: x=1.24000004e+23 y=1.23990790e+23 digits=3 abs_diff=9.21436483e+18 max_diff=9.99999977e-03 scaled_max_diff=1.24000001e+21 result=true
approxEql: x=1.24000004e+23 y=1.23990790e+23 digits=4 abs_diff=9.21436483e+18 max_diff=1.00000004e-03 scaled_max_diff=1.24000009e+20 result=true
approxEql: x=1.24000004e+23 y=1.23990790e+23 digits=5 abs_diff=9.21436483e+18 max_diff=9.99999974e-05 scaled_max_diff=1.23999996e+19 result=true
approxEql: x=1.24000004e+23 y=1.23990790e+23 digits=6 abs_diff=9.21436483e+18 max_diff=9.99999974e-06 scaled_max_diff=1.24000007e+18 result=false
approxEql: x=1.24000004e+23 y=1.23990790e+23 digits=7 abs_diff=9.21436483e+18 max_diff=9.99999997e-07 scaled_max_diff=1.24000000e+17 result=false
approxEql: x=1.24000004e+23 y=1.23990790e+23 digits=8 abs_diff=9.21436483e+18 max_diff=1.00000001e-07 scaled_max_diff=1.24000000e+16 result=false
approxEql: x=1.24000004e+23 y=1.23990790e+23 digits=9 abs_diff=9.21436483e+18 max_diff=9.99999993e-09 scaled_max_diff=1.24000000e+15 result=false
approxEql: x=1.24000004e+23 y=1.23990790e+23 digits=10 abs_diff=9.21436483e+18 max_diff=9.99999971e-10 scaled_max_diff=1.24000000e+14 result=false
approxEql: x=1.24000004e+23 y=1.23990790e+23 digits=11 abs_diff=9.21436483e+18 max_diff=1.00000001e-10 scaled_max_diff=1.24000004e+13 result=false
approxEql: x=1.24000004e+23 y=1.23990790e+23 digits=12 abs_diff=9.21436483e+18 max_diff=9.99999996e-12 scaled_max_diff=1.24000010e+12 result=false
approxEql: x=1.24000004e+23 y=1.23990790e+23 digits=13 abs_diff=9.21436483e+18 max_diff=9.99999996e-13 scaled_max_diff=1.24000002e+11 result=false
approxEql: x=1.24000004e+23 y=1.23990790e+23 digits=14 abs_diff=9.21436483e+18 max_diff=1.00000005e-13 scaled_max_diff=1.24000010e+10 result=false
approxEql: x=1.24000004e+23 y=1.23990790e+23 digits=15 abs_diff=9.21436483e+18 max_diff=9.99999982e-15 scaled_max_diff=1.24e+09 result=false
approxEql: x=1.24000004e+23 y=1.23990790e+23 digits=16 abs_diff=9.21436483e+18 max_diff=1.00000000e-15 scaled_max_diff=1.24000008e+08 result=false
approxEql: x=1.24000004e+23 y=1.23990790e+23 digits=17 abs_diff=9.21436483e+18 max_diff=9.99999950e-17 scaled_max_diff=1.24e+07 result=false
OK
Test 14/18 approxEql.sub.f64...
x=0.0e+00 end=1.3877787807814457e-16
approxEql: x=0.0e+00 y=1.3877787807814457e-16 digits=0 digits == 0 result=true
approxEql: x=0.0e+00 y=1.3877787807814457e-16 digits=1 abs_diff=1.3877787807814457e-16 max_diff=1.0e+00 close to 0 result=true
approxEql: x=0.0e+00 y=1.3877787807814457e-16 digits=2 abs_diff=1.3877787807814457e-16 max_diff=1.0e-01 close to 0 result=true
approxEql: x=0.0e+00 y=1.3877787807814457e-16 digits=3 abs_diff=1.3877787807814457e-16 max_diff=1.0e-02 close to 0 result=true
approxEql: x=0.0e+00 y=1.3877787807814457e-16 digits=4 abs_diff=1.3877787807814457e-16 max_diff=1.0e-03 close to 0 result=true
approxEql: x=0.0e+00 y=1.3877787807814457e-16 digits=5 abs_diff=1.3877787807814457e-16 max_diff=1.0e-04 close to 0 result=true
approxEql: x=0.0e+00 y=1.3877787807814457e-16 digits=6 abs_diff=1.3877787807814457e-16 max_diff=1.0e-05 close to 0 result=true
approxEql: x=0.0e+00 y=1.3877787807814457e-16 digits=7 abs_diff=1.3877787807814457e-16 max_diff=1.0e-06 close to 0 result=true
approxEql: x=0.0e+00 y=1.3877787807814457e-16 digits=8 abs_diff=1.3877787807814457e-16 max_diff=1.0e-07 close to 0 result=true
approxEql: x=0.0e+00 y=1.3877787807814457e-16 digits=9 abs_diff=1.3877787807814457e-16 max_diff=1.0e-08 close to 0 result=true
approxEql: x=0.0e+00 y=1.3877787807814457e-16 digits=10 abs_diff=1.3877787807814457e-16 max_diff=1.0e-09 close to 0 result=true
approxEql: x=0.0e+00 y=1.3877787807814457e-16 digits=11 abs_diff=1.3877787807814457e-16 max_diff=1.0e-10 close to 0 result=true
approxEql: x=0.0e+00 y=1.3877787807814457e-16 digits=12 abs_diff=1.3877787807814457e-16 max_diff=1.0e-11 close to 0 result=true
approxEql: x=0.0e+00 y=1.3877787807814457e-16 digits=13 abs_diff=1.3877787807814457e-16 max_diff=1.0e-12 close to 0 result=true
approxEql: x=0.0e+00 y=1.3877787807814457e-16 digits=14 abs_diff=1.3877787807814457e-16 max_diff=1.0e-13 close to 0 result=true
approxEql: x=0.0e+00 y=1.3877787807814457e-16 digits=15 abs_diff=1.3877787807814457e-16 max_diff=1.0e-14 close to 0 result=true
approxEql: x=0.0e+00 y=1.3877787807814457e-16 digits=16 abs_diff=1.3877787807814457e-16 max_diff=1.0e-15 close to 0 result=true
approxEql: x=0.0e+00 y=1.3877787807814457e-16 digits=17 abs_diff=1.3877787807814457e-16 max_diff=1.0e-16 scaled_max_diff=1.3877787807814458e-32 result=false
OK
Test 15/18 approxEql.sub.f32...
x=0.0e+00 end=-7.45058059e-08
approxEql: x=0.0e+00 y=-7.45058059e-08 digits=0 digits == 0 result=true
approxEql: x=0.0e+00 y=-7.45058059e-08 digits=1 abs_diff=7.45058059e-08 max_diff=1.0e+00 close to 0 result=true
approxEql: x=0.0e+00 y=-7.45058059e-08 digits=2 abs_diff=7.45058059e-08 max_diff=1.00000001e-01 close to 0 result=true
approxEql: x=0.0e+00 y=-7.45058059e-08 digits=3 abs_diff=7.45058059e-08 max_diff=9.99999977e-03 close to 0 result=true
approxEql: x=0.0e+00 y=-7.45058059e-08 digits=4 abs_diff=7.45058059e-08 max_diff=1.00000004e-03 close to 0 result=true
approxEql: x=0.0e+00 y=-7.45058059e-08 digits=5 abs_diff=7.45058059e-08 max_diff=9.99999974e-05 close to 0 result=true
approxEql: x=0.0e+00 y=-7.45058059e-08 digits=6 abs_diff=7.45058059e-08 max_diff=9.99999974e-06 close to 0 result=true
approxEql: x=0.0e+00 y=-7.45058059e-08 digits=7 abs_diff=7.45058059e-08 max_diff=9.99999997e-07 close to 0 result=true
approxEql: x=0.0e+00 y=-7.45058059e-08 digits=8 abs_diff=7.45058059e-08 max_diff=1.00000001e-07 close to 0 result=true
approxEql: x=0.0e+00 y=-7.45058059e-08 digits=9 abs_diff=7.45058059e-08 max_diff=9.99999993e-09 scaled_max_diff=7.45058068e-16 result=false
approxEql: x=0.0e+00 y=-7.45058059e-08 digits=10 abs_diff=7.45058059e-08 max_diff=9.99999971e-10 scaled_max_diff=7.45058055e-17 result=false
approxEql: x=0.0e+00 y=-7.45058059e-08 digits=11 abs_diff=7.45058059e-08 max_diff=1.00000001e-10 scaled_max_diff=7.45058038e-18 result=false
approxEql: x=0.0e+00 y=-7.45058059e-08 digits=12 abs_diff=7.45058059e-08 max_diff=9.99999996e-12 scaled_max_diff=7.45058069e-19 result=false
approxEql: x=0.0e+00 y=-7.45058059e-08 digits=13 abs_diff=7.45058059e-08 max_diff=9.99999996e-13 scaled_max_diff=7.45058056e-20 result=false
approxEql: x=0.0e+00 y=-7.45058059e-08 digits=14 abs_diff=7.45058059e-08 max_diff=1.00000005e-13 scaled_max_diff=7.45058056e-21 result=false
approxEql: x=0.0e+00 y=-7.45058059e-08 digits=15 abs_diff=7.45058059e-08 max_diff=9.99999982e-15 scaled_max_diff=7.45058046e-22 result=false
approxEql: x=0.0e+00 y=-7.45058059e-08 digits=16 abs_diff=7.45058059e-08 max_diff=1.00000000e-15 scaled_max_diff=7.45058046e-23 result=false
approxEql: x=0.0e+00 y=-7.45058059e-08 digits=17 abs_diff=7.45058059e-08 max_diff=9.99999950e-17 scaled_max_diff=7.45057983e-24 result=false
OK
Test 16/18 epsilon.f64...OK
Test 17/18 epsilon.f32...OK
Test 18/18 epsilon.f16...OK
All tests passed.
```
