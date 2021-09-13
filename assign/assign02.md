---
layout: default
title: "Assignment 2: Text Search"
---

Milestone 1: due **Tuesday, Sept 21st** by 11pm

Milestone 2: due **Friday, Sept 25th** by 11pm

Milestone 3: due **Tuesday, Oct 5th** by 11pm

Assignment type: **Pair**, you may work with one partner

# Overview

In this assignment, you will implement a program to search for occurrences
of a string in a text file, similar to the Unix `grep` program.
You will implement two versions of this program: one in C and one in
x86-64 assembly language.

## Milestones, grading criteria

Grading criteria for milestone 1:

* Fully implement `c_textsearch.c` and `c_textsearch_fns.c` (i.e., the `c_textsearch`
  works correctly) (10%)
* `textsearch_fns_tests.c` program has unit tests for all functions declared in `textsearch_fns.h`
  and implemented in `c_textsearch_fns.c` (10%)

Grading criteria for milestone 2:

* `asm_textsearch_fns.S` implements at least one function declared in `textsearch_fns.h`, and
  it passes the unit tests in `textsearch_fns_tests.c` (10%)

Note that you should comment out all of the test functions in `textsearch_fns_tests.c`
which test functions in `asm_textsearch_fns.S` that aren't implemented.
I.e., `make asm_textsearch_fns_tests` should succeed, and when the `asm_textsearch_fns_tests`
program is run, at least one test function should complete successfully.

Grading criteria for milestone 3:

* All functions in `asm_textsearch_fns.S` are fully implemented, and
  pass the unit tests in `textsearch_fns_tests.c` (30%)
* `make asm_textsearch` succeeds, and the `asm_textsearch` program works
  completely (and is functionally equivalent to `c_textsearch`) (30%)
* Design and coding style (10%)

## Getting started

Download [csf\_assign02.zip](csf_assign02.zip), which contains the skeleton code for the assignment.

You can download this file from a Linux command prompt using the `curl` command:

```bash
curl -O https://jhucsf.github.io/fall2021/assign/csf_assign02.zip
```

Note that in the `-O` option, it is the letter "O", not the numeral "0".

# Text search

The Unix `grep` program searches for lines in a text file containing one or more
occurrences of a particular string. Here is an example using the text of the
first two paragraphs of [Pride and Prejudice](https://www.gutenberg.org/files/1342/1342-0.txt)
(user input in <b>bold</b>):

<div class="highlighter-rouge"><pre>
$ <b>cat pandp.txt</b>
It is a truth universally acknowledged, that a single man in
possession of a good fortune, must be in want of a wife.

However little known the feelings or views of such a man may be
on his first entering a neighbourhood, this truth is so well
fixed in the minds of the surrounding families, that he is
considered as the rightful property of some one or other of their
daughters.
$ <b>grep truth pandp.txt</b>
It is a truth universally acknowledged, that a single man in
on his first entering a neighbourhood, this truth is so well
</pre></div>

The `grep` program actually does more than just search for literal strings.
It can search for occurrences of text matching a regular expression pattern.
However, your text search program will not need to implement regular expression
matching, and instead, will only need to search for occurrences of literal text.
