---
layout: default
title: "Assignment 1: Fixed-point arithmetic"
---

Milestone 1: due Tuesday Sep 7th by 11pm

Milestone 2: due Tuesday Sep 14th by 11pm

Assignment type: **Pair**, you may work with one partner

# Overview

In this assignment, you will implement a simple C library for fixed-point arithmetic.

## Milestones, grading criteria

The grading breakdown is as follows:

For Milestone 1 (20% of assignment grade):

- Implementation of functions (20%)
  - `fixedpoint_create`
  - `fixedpoint_create2`
  - `fixedpoint_whole_part`
  - `fixedpoint_frac_part`
  - `fixedpoint_is_zero`

For Milestone 2 (80% of assignment grade):

* Implementation of functions (70%)
  - `fixedpoint_create_from_hex`
  - `fixedpoint_negate`
  - `fixedpoint_add`
  - `fixedpoint_sub`
  - `fixedpoint_negate`
  - `fixedpoint_halve`
  - `fixedpoint_double`
  - `fixedpoint_compare`
  - `fixedpoint_is_err`
  - `fixedpoint_is_neg`
  - `fixedpoint_is_overflow_neg`
  - `fixedpoint_is_overflow_pos`
  - `fixedpoint_is_underflow_neg`
  - `fixedpoint_is_underflow_pos`
  - `fixedpoint_is_valid`
  - `fixedpoint_format_as_hex`
* Design and coding style (10%)

Note that the functions can't be tested completely independently of each other, and
in some cases to earn credit for one function, another will need to work correctly.
For example, some of the tests will depend on `fixedpoint_format_as_hex` working
correctly.

## Getting started

Download [csf\_assign01.zip](csf_assign01.zip), which contains the skeleton code for the assignment.

You can download this file from a Linux command prompt using the `curl` command:

```bash
curl -O https://jhucsf.github.io/fall2021/assign/csf_assign01.zip
```

Note that in the `-O` option, it is the letter "O", not the numeral "0".

# Fixed-point arithmetic

You are probably at least somewhat familiar with *integer* and *floating-point* numeric data types.  Integer types are exact, but cannot represent fractions.  Floating-point types can represent fractions, but are inexact, since numeric operations can introduce rounding errors.  Machine-level integer and floating point numeric types are *finite*, since they have a fixed number of bits of data in their representations, and so only allow a finite set of possible values.

A *fixed-point* numeric data type is a way of representing values with a fractional part using a purely integer representation.  The idea is that a fixed-point value is a fixed-length string of *n* digits, with the first *j* digits being the whole part of the representation, and the last *k* digits being the fractional part of the representation, with *n = j + k*.

For example, consider a base-10 fixed-point data type where *j = 5* and *k = 3*.  The numeric value 79.25 would be represented as 00079.250.  From an implementation standpoint, the position of the decimal point does not need to be explicitly represented, since it is the same for all values that are part of the data type.  (Hence the term "fixed point".)  So, we can really think of the string of digits for this value being 00079250, with the knowledge that the last three digits belong to the fractional part of the value.

The key advantage of fixed-point representations is that numeric operations can be done using purely integer arithmetic.  For example, using the base-10 fixed-point type described above, the sum

> 79.25 + 1014.999

Could be computed by the integer operation

> 79250 + 1014999 = 1094249

which yields the fixed point value

> 1094.249

## Binary fixed point representations

Any base can be used in a fixed-point representation, and it is natural to use a binary (base-2) representation when implementing a fixed-point data type in a computer program.  Let's say that a binary fixed-point representation uses 8 bits (base-2 "digits") for the whole part and 8 bits for the fractional part.  The base-10 value 79.25 would be represented as 

> 1001111.01000000

Note that in the fractional part ".01000000", the "1" digit is in the fourth's place.  More generally, in a base-2 "decimal-like" fraction, the first bit after the decimal point is the half's place (2<sup>-1</sup>), the second bit is the fourth's place (2<sup>-2</sup>), the third bit is the eighth's place (2<sup>-3</sup>), etc.

## The `Fixedpoint` data type

In the header file `fixedpoint.h` you will see the following definition:

```c
typedef struct {
  // TODO: add fields
} Fixedpoint;
```

An instance of `Fixedpoint` is a base-2 fixed point value, in which both the whole part and fractional part of the representaion are 64 bits in size.  `Fixedpoint` values can be negative or non-negative.

Note that the `Fixedpoint` type has *by-value* semantics. It can be copied by value, passed by value, and returned by value.  The only function requiring dynamic memory allocation is `fixedpoint_format_as_hex`, which returns a dynamically allocated character string.

Your main task for this assignment is to implement the following functions:

```c
Fixedpoint fixedpoint_create(uint64_t whole);
Fixedpoint fixedpoint_create2(uint64_t whole, uint64_t frac);
Fixedpoint fixedpoint_create_from_hex(const char *hex);
uint64_t fixedpoint_whole_part(Fixedpoint val);
uint64_t fixedpoint_frac_part(Fixedpoint val);
Fixedpoint fixedpoint_add(Fixedpoint left, Fixedpoint right);
Fixedpoint fixedpoint_sub(Fixedpoint left, Fixedpoint right);
Fixedpoint fixedpoint_negate(Fixedpoint val);
Fixedpoint fixedpoint_halve(Fixedpoint val);
Fixedpoint fixedpoint_double(Fixedpoint val);
int fixedpoint_compare(Fixedpoint left, Fixedpoint right);
int fixedpoint_is_zero(Fixedpoint val);
int fixedpoint_is_err(Fixedpoint val);
int fixedpoint_is_neg(Fixedpoint val);
int fixedpoint_is_overflow_neg(Fixedpoint val);
int fixedpoint_is_overflow_pos(Fixedpoint val);
int fixedpoint_is_underflow_neg(Fixedpoint val);
int fixedpoint_is_underflow_pos(Fixedpoint val);
int fixedpoint_is_valid(Fixedpoint val);
char *fixedpoint_format_as_hex(Fixedpoint val);
```

In the `fixedpoint.h` header file you will see a detailed comment describing the
required behavior for each function.  You should implement the functions in
`fixedpoint.c` to implement the required behavior.

## Extremely important requirement

In your implementation of the `Fixedpoint` data type and its functions,
you may not use any primitive data type with more than 64 bits in its representation.
For example, the `gcc` compiler has an `__int128` data type with a 128 bit representation.
Using this type, or any other primitive type with more than 128 bits in its representation,
is not allowed.

We recommend that you use two `uint64_t` values in the representation of `Fixedpoint`,
one to represent the whole part, and one to represent the fractional part.
Note that you will also need to store a "tag" that keeps track of whether the
`Fixedpoint` value is valid/non-negative, valid/negative, an error value, an positive or
negative overflow value, or a positive or negative underflow value.

## Hex string representation

You will note that the `fixedpoint_create_from_hex` and `fixedpoint_format_as_hex` functions
work with "hex string" representations of `Fixedpoint` values.

Hex means "hexadecimal", or base-16.  In addition to the numerals 0-9, hexadecimal
uses the letters a-f (or A-F) to represent values 10 through 15.

Hexadecimal notation is convenient for representing binary values because
each hexadecimal "digit" represents exactly 4 bits.

## Testing, writing tests

The skeleton project comes with a source file named `fixedpoint_tests.c`.  This
program has some unit tests for the `Fixedpoint` type and its functions.
You can build the program using the command

```
make
```

and run it using the command

```
./fixedpoint_tests
```

The unit tests use the [tctest](https://github.com/daveho/tctest) unit test framework.  You can read the [README](https://github.com/daveho/tctest/blob/master/README.md) and [demo program](https://github.com/daveho/tctest/blob/master/demo.c) for specific information about how it works, but if you've used unit testing frameworks such as [JUnit](https://junit.org), it should be fairly straightforward.

The basic idea is to create instances of `Fixedpoint` that can be used to test the various functions: these objects form the *test fixture*.  Then, test functions carry out function calls on the test fixture objects (potentially creating new instances of `Fixedpoint` as intermediate results), and use assertions to check that the observed behavior matches the expected behavior.

The provided `fixedpoint_tests.c` program has some basic tests to get you started;
note that these tests are not comprehensive.

You should add additional tests of your own.  Part of your grade for Milestone 2 will be based
on how thorough your unit tests are.  A minimum expectation of unit tests is that all public functions
are tested.  So, make sure that all of the functions declared in `fixedpoint.h` are testd.
More generally, unit tests should test the complete range of functionality specified for each
function.  For example, you should make sure that the `fixedpoint_add` function is tested with
combinations of negative a non-negative values, and that there are tests producing both valid
result values as well as positive and negative overflow values.

One useful approach to coming up with good unit tests is to write a program that can
*generate* unit tests.  For example, here are some tests for `fixedpoint_add` that
were generated by a Ruby script:

```c
lhs = fixedprec_create_from_hex("934.ade8d38a");
rhs = fixedprec_create_from_hex("-edef814.21f023189");
sum = fixedprec_add(lhs, rhs);
ASSERT(fixedprec_is_neg(sum));
ASSERT(0xedeeedfUL == fixedprec_whole_part(sum));
ASSERT(0x74074f8e90000000UL == fixedprec_frac_part(sum));

lhs = fixedprec_create_from_hex("8bd.0e34492025065");
rhs = fixedprec_create_from_hex("5d7b061d6.034f5d");
sum = fixedprec_add(lhs, rhs);
ASSERT(!fixedprec_is_neg(sum));
ASSERT(0x5d7b06a93UL == fixedprec_whole_part(sum));
ASSERT(0x1183a62025065000UL == fixedprec_frac_part(sum));

lhs = fixedprec_create_from_hex("-8a6a9f92d72.82a9b99ad4e76");
rhs = fixedprec_create_from_hex("-8a93a62c25996.e09875");
sum = fixedprec_add(lhs, rhs);
ASSERT(fixedprec_is_neg(sum));
ASSERT(0x8b1e10cbb8709UL == fixedprec_whole_part(sum));
ASSERT(0x63422e9ad4e76000UL == fixedprec_frac_part(sum));
```

Note that Python and Ruby both support arbitrary-precision integer values and
arithmetic, which makes them very suitable for working with the large values
supported by the `Fixedpoint` data type.

## Running a specific test function

If you just want to execute one test function in the unit test program,
you can specify its name on the command line.  For example:

```
./fixedpoint_tests test_add
```

The command above would run only the `test_add` test function.

## Using `valgrind` to check for memory errors

Make sure that you use `valgrind` to check your code for memory errors:

```
valgrind --leak-check=full ./fixedpoint_tests
```

You should expect a significant deduction if your code exhibits any memory errors,
such as memory leaks, uses of uninitialized values, out of bounds array accesses,
etc.

## Debugging

You can use `gdb` to debug the test program:

```
gdb ./fixedpoint_tests
```

If you are debugging the failure of a specific assertion in the test program, a good
approach is to set a breakpoint on the line of code which calls the function
the assertion is testing, then run the test program.  When the breakpoint is
reached, use the `step` command to debug into the function that is misbehaving.

# Submitting

Before you submit, prepare a `README.txt` file so that it contains your names, and briefly summarizes each of your contributions to the submission (i.e., who worked on what functionality.) This may be very brief if you did not work with a partner.

To submit your work:

Run the following commands to create a `solution.zip` file:

```
rm -f solution.zip
zip -9r solution.zip Makefile *.h *.c README.txt
```

Upload `solution.zip` to [Gradescope](https://www.gradescope.com/) as **Assignment 1 MS1** or **Assignment 1 MS2**, depending on which milestone you are submitting.

Please check the files you uploaded to make sure they are the ones you intended to submit.

## Autograder

When you upload your submission to Gradescope, it will be tested by the autograder, which executes unit tests for each required function.  Please note the following:

* If your code does not compile successfully, all of the tests will fail
* The autograder runs `valgrind` on your code, but it does *not* report any information about the result of running `valgrind`: points will be deducted if your code has memory errors or memory leaks!
