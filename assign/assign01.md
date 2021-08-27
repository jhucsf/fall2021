---
layout: default
title: "Assignment 1: Fixed-point arithmetic"
---

Milestone 1: due *TBD*

Milestone 2: due *TBD*

Assignment type: **Pair**, you may work with one partner

# Overview

In this assignment, you will implement a simple C library for fixed-point arithmetic.

## Milestones, grading criteria

The grading breakdown is as follows:

For Milestone 1 (20% of assignment grade):

* Details coming soon

For Milestone 2 (80% of assignment grade):

* Details coming soon

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

For example, consider a base-10 fixed-point data type where *j = 5* and *k = 3*.  The numeric value 79.25 would be represented as `00079.250`.  From an implementation standpoint, the position of the decimal point does not need to be explicitly represented, since it is the same for all values that are part of the data type.  (Hence the term "fixed point".)  So, we can really think of the string of digits for this value being `00079250`, which the knowledge that the last three digits belong to the fractional part of the value.

The key advantage of fixed-point representations is that numeric operations can be done using purely integer arithmetic.
