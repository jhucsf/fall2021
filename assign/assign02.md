---
layout: default
title: "Assignment 2: Text Search"
---

Milestone 1: due **Tuesday, Sept 21st** by 11pm

Milestone 2: due **Friday, Sept 25th** by 11pm

Milestone 3: due **Tuesday, Oct 5th** by 11pm

Assignment type: **Pair**, you may work with one partner

*Note: this is a preliminary assignment description, and will be updated
with additional information in the near future.*

# Overview

In this assignment, you will implement a program to search for occurrences
of a string in a text file, similar to the Unix `grep` program.
You will implement two versions of this program: one in C and one in
x86-64 assembly language.

## Milestones, grading criteria

Grading criteria for Milestone 1:

* Fully implement `c_textsearch.c` and `c_textsearch_fns.c` (i.e., the `c_textsearch`
  works correctly) (10%)
* `textsearch_fns_tests.c` program has comprehensive unit tests for all functions
  declared in `textsearch_fns.h` and implemented in `c_textsearch_fns.c` (10%)

Grading criteria for Milestone 2:

* `asm_textsearch_fns.S` implements at least one function declared in `textsearch_fns.h`, and
  it passes the unit tests in `textsearch_fns_tests.c` (10%)

Note that you should comment out all of the test functions in `textsearch_fns_tests.c`
which test functions in `asm_textsearch_fns.S` that aren't implemented.
I.e., `make asm_textsearch_fns_tests` should succeed, and when the `asm_textsearch_fns_tests`
program is run, at least one test function should complete successfully.

Grading criteria for Milestone 3:

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

## Use of C library functions

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

Note that this means that you will need to implement your own string functions.
(Use of C library C functions such as `strlen` is not allowed.)

## Input line length

The `c_textsearch` and `asm_textsearch` programs are only required to fully handle lines
with 511 or fewer characters.  If an input file has a line which exceeds 511 characters,
it should search only the first 511 characters on that line.  (In other words,
only the first 511 characters of the line need to be read into memory.)

The `MAXLINE` constant defined in `textsearch_fns.h` can be used to specify this limit.

# Tasks/milestones

This section has more details on the expectations for each of the three milestones.

Briefly, here is how you will make progress on completing the milestones:

* In Milestone 1, you will complete a full implementation of `c_textsearch`,
  declaring and implementing a collection of helper functions to do most
  of the work of implementing the text search functionality.  You will
  also write unit tests for your helper functions.
* In Milestone 2, you will begin to implement the same helper functions
  you defined in Milestone 1, but this time, you will implement them in
  x86-64 assembly language.  You will be able to use the same unit tests
  from Milestone 1 to test your assembly language functions, because the
  assembly language functions should be completely equivalent to their C
  counterparts.
* In Milestone 3, you will complete the full `asm_textsearch` program, in
  which the `main` function and all of the helper functions are implemented
  in assembly language.

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

In Milestone 2, you must implement at least one of the functions declared in
`textsearch_fns.h` in x86-64 assembly language, and use unit tests to demonstrate
that it works correctly.

Note that you may need to comment out the unit tests in `textsearch_fns_tests.c`
which test functions that you haven't yet implemented in x86-64 assembly language.

To build the `asm_textsearch_fns_tests` unit test program (in which your assembly
language functions are tested by the unit tests you wrote in C), run the command

```
make asm_textsearch_fns_tests
```

**Extremely important**: Make sure that **all** of your assembly language code
adheres to the x86-64 Linux register use and procedure calling conventions.
For example, callee-saved registers must be saved and restored if your function
modifies them, and you must assume that the values of caller-saved registers
could by changed by a function call.  Also, make sure that the stack pointer
is properly aligned in any function that will call other functions.

## Milestone 3

TODO: describe expectations for Milestone 3

# Recommendations and tips

## General recommendations for writing assembly language code

*Use registers for local variables.*  For most local variables in your
code, you can use a register as the storage location.  The callee-saved
registers (`%rbx`, `%rbp`, `%r12`–`%r15`) are the most straightforward
to use, but you will need to save their previous contents and then
restore them before returning from the function.  (The `pushq` and
`popq` instructions make saving and restoring register contents easy.)
The caller-saved registers (`%r10` and `%r11`) don't need to be saved
and restored, but their values aren't preserved across function calls,
so they're tricker to use correctly.

*Use the frame pointer to keep track of local variables in memory.*
Some variables will need to be allocated in memory.  You can allocate
such variables in the stack frame of the called function.  The frame
pointer register (`%rbp`) can help you easily access these variables.
A typical setup for a function which allocates variables in the stack
frame would be something like

```
myFunc:
    pushq %rbp                      /* save previous frame pointer */
    subq $N, %rsp                   /* reserve space for local variable(s) */
    movq %rsp, %rbp                 /* set up frame pointer */

    /*
     * implementation of function: local variables can be accessed
     * relative to %rbp, e.g. 0(%rbp), 8(%rbp), etc.
     */

    addq $N, %rsp                   /* deallocate space for local variable(s) */
    popq %rbp                       /* restore previous frame pointer */
    ret
```

The code above allocates *N* bytes of memory in the stack frame for
local variables. Note that *N* needs to be a multiple of 16 to ensure
correct stack pointer alignment.  (Think about it!)

*Use `leaq` to compute addresses of local variables.* It is likely
that one or more of your functions takes a pointer to a variable as
a parameter.  When calling such a function, the `leaq` instruction
provides a very convenient way to compute the address of a variable.
For example, let's say we want to pass the address of a local variable
8 bytes offset from the frame pointer (`%rbp`) as the first argument to
a function.  We could load the address of this variable into the `%rdi`
register (used for the first function argument) using the instruction

```
leaq 8(%rbp), %rdi
```

*Use local labels starting with `.L` for flow control.*  As you implement
flow control (such as loops and decisions) in your program, you will
need to define labels for branch targets.  You should use names starting
with `.L` (period followed by capital L) for these labels.  This will
ensure that the assembler does not enter them into the symbol table as
function entry points, which will make debugging with `gdb` difficult.
Here is an example assembly language function with local labels:

```
/*
 * Find the first occurrence of a specified character value
 * in a NUL-terminated character string.
 *
 * Parameters:
 *   s - pointer to a NUL-terminated character string
 *   c - character to search for
 *
 * Returns:
 *    pointer to first occurrence of the search character,
 *    or NULL if the character does not occur in the string
 */
	.globl first_occur
first_occur:
	subq $8, %rsp

	mov %rdi, %rax             /* set %rax to start of string */

.Lfirst_occur_loop:
	cmpb $0, (%rax)            /* NUL terminator reached? */
	je .Lfirst_occur_not_found /* if so, search failed */
	cmpb %sil, (%rax)          /* found occurrence of character? */
	je .Lfirst_occur_done      /* if so, success */
	inc %rax                   /* advance to next character */
	jmp .Lfirst_occur_loop     /* continue loop */

.Lfirst_occur_not_found:
	movq $0, %rax              /* return NULL pointer */

.Lfirst_occur_done:
	addq $8, %rsp
	ret
```

Note that the function above also illustrates what we consider to be an
appropriate amount of detail for code comments.


## Suggestions for writing unit tests

Your approach to writing unit tests should be similar to the one you used
in [Assignment 1](assign01.html).  Make sure each function (in `textsearch_fns.h`)
is tested, and test the full range of functionality for each function,
including important corner cases.

Note that you might be wondering whether it is possible to implement
unit tests for functions which do I/O (i.e., reading from or writing
to a `FILE *` file handle.)  The good news is that it is fairly
straightforward to do so by using the
[`fmemopen`](https://man7.org/linux/man-pages/man3/fmemopen.3.html) function.

For example, here is a test function which tests the `read_line` function,
which is intended to read a single line of text from an input file:

```c
void test_read_line(TestObjs *objs) {
  // the fmemopen function allows us to treat a character string
  // as an input file
  FILE *in = fmemopen((char *) objs->pandp, strlen(objs->pandp), "r");
  char buf[MAXLINE + 1];

  ASSERT(read_line(in, buf));
  ASSERT(0 == strcmp(buf,
   "It is a truth universally acknowledged, that a single man in"));

  ASSERT(read_line(in, buf));
  ASSERT(0 == strcmp(buf,
    "possession of a good fortune, must be in want of a wife."));

  ASSERT(read_line(in, buf));
  ASSERT(0 == strcmp(buf, ""));

  ASSERT(read_line(in, buf));
  ASSERT(0 == strcmp(buf,
    "However little known the feelings or views of such a man may be"));

  ASSERT(read_line(in, buf));
  ASSERT(0 ==strcmp(buf,
    "on his first entering a neighbourhood, this truth is so well"));

  ASSERT(read_line(in, buf));
  ASSERT(0 == strcmp(buf,
    "fixed in the minds of the surrounding families, that he is"));

  ASSERT(read_line(in, buf));
  ASSERT(0 == strcmp(buf,
    "considered as the rightful property of some one or other of their"));

  ASSERT(read_line(in, buf));
  ASSERT(0 == strcmp(buf, "daughters."));

  // at this point we have read the last line
  ASSERT(!read_line(in, buf));

  fclose(in);
}
```

The idea here is that `fmemopen` opens a memory buffer as though it were a file.
In the test above, `objs->pandp` is a literal string containing the text of the
first two paragraphs of Pride and Prejudice.

## Suggestions for testing and debugging

# Submitting

Before you submit, prepare a `README.txt` file so that it contains your
names, and briefly summarizes each of your contributions to the submission
(i.e., who worked on what functionality.) This may be very brief if you
did not work with a partner.

To submit your work:

Run the following commands to create a `solution.zip` file:

```
rm -f solution.zip
zip -9r solution.zip Makefile *.h *.c README.txt
```

Upload `solution.zip` to [Gradescope](https://www.gradescope.com/)
as **Assignment 2 MS1**, **Assignment 2 MS2**, or **Assignment 2 MS3**,
depending on which milestone you are submitting.

Please check the files you uploaded to make sure they are the ones you intended to submit.

## Autograder

When you upload your submission to Gradescope, it will be tested by
the autograder.  Please note the following:

* If your code does not compile successfully, all of the tests will fail
* The autograder runs `valgrind` on your code, but it does *not* report
  any information about the result of running `valgrind`: points will be
  deducted if your code has memory errors or memory leaks!
