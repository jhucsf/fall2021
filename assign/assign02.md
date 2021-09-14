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

## `c_textsearch` and `asm_textsearch`

In this assignment, you will implement two functionally-equivalent programs,
`c_textsearch` and `asm_textsearch`.  The first will be implemented entirely
in C, and the second will be implemented entirely in x86-64 assembly language.

The programs are invoked as follows:

<div class="highlighter-rouge"><pre>
./c&#95;textsearch <i>string</i> <i>filename</i>
./c&#95;textsearch -c <i>string</i> <i>filename</i>
./asm&#95;textsearch <i>string</i> <i>filename</i>
./asm&#95;textsearch -c <i>string</i> <i>filename</i>
</pre></div>

When invoked without the `-c` command line option, the programs behave much
like the `grep` program, printing out each line of text containing at least
one occurrence of the search string.  (As mentioned previously, your program
should only search for literal occurrences, and should not implement regular
expression pattern matching.)

When invoked with the `-c` option, the programs should print a single line of
output of the form

<div class="highlighter-rouge"><pre>
<i>N</i> occurrence(s)
</pre></div>

where *N* is the number of times the search string occurs in the overall input
file.

Example run using the `pandp.txt` file shown above (user input in **bold**):

<div class="highlighter-rouge"><pre>
$ <b>./c&#95;textsearch truth pandp.txt</b>
It is a truth universally acknowledged, that a single man in
on his first entering a neighbourhood, this truth is so well
$ <b>./c&#95;textsearch -c truth pandp.txt</b>
2 occurrence(s)
$ <b>echo $?</b>
0
</pre></div>

Any time the program (`c_textsearch` or `asm_textsearch`) finishes normally
(by reading the input text file and successfully executing the search), it
should exit with an exit code of 0.

If invalid command-line arguments are given, or if the input file can't
be opened, then the program should print an error message to `stderr`
and exit with an exit code of 1.  For example:

<div class="highlighter-rouge"><pre>
$ <b>./c&#95;textsearch truth nonexistent.txt</b>
Could not open file
$ <b>echo $?</b>
1
</pre></div>

# Important requirements

In the implementation of both programs (`c_textsearch` and `asm_textsearch`), you
many *only* use the following C library functions:

* `fopen`
* `fclose`
* `printf`
* `fprintf`
* `fgetc`
* `fputc`
* `exit`

**As an exception to this requirement**, your unit tests in `textsearch_fns_tests.c`
may use any C library function.

Submissions which improperly use any C library functions other than the ones listed
above will not receive credit.

# Tasks/milestones

This section has more details on the expectations for each of the three milestones.

## Milestone 1

For Milestone 1, you will implement just the C version of the text search
program (`c_textsearch`).

You will need to make changes to four files:

* `textsearch_fns.h`: This header file declares functions used by the `main` function
* `c_textsearch_fns.c`: This will contain implementation of the functions declared in `textsearch_fns.h`
* `c_textsearch.c`: This file defines the `main` function for the `c_textsearch` program
* `textsearch_fns_tests.c`: This file implements unit tests for the functions declared in
  `textsearch_fns.h` and defined in `c_textsearch_fns.c`

You should strive to delegate as much of the required program functionality to functions
declared in `textsearch_fns.h`.  Which functions you define is up to you.  Here is
a suggested list of function declarations, which were used in the reference solution:

```c
int read_line(FILE *in, char *buf);
void print_line(FILE *out, const char *buf);
unsigned count_occurrences(const char *line, const char *str);
unsigned find_string_length(const char *s);
int starts_with(const char *s, const char *pfx);
int strings_equal(const char *s1, const char *s2);
```

You are welcome to use these functions as the basis for your implementation, but you are
not required to.

Note one very important point: you should design your functions so that it will be
straightforward to:

* Write unit tests to test their functionality
* Implement them in x86-64 assembly language

We believe the functions shown above have these properties. You are welcome to
use or adapt them, but this is not a requirement of the assignment.

To build the `c_textsearch` program, run the command

```
make c_textsearch
```

To build the `c_textsearch_fns_tests` program:

```
make c_textsearch_fns_tests
```

## Milestone 2

In Milestone 2, you must implement at least one of the functions
