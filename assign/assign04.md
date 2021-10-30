---
layout: default
title: "Assignment 4: Analyzing ELF files"
---

**Due**: Thursday, Nov 11th by 11:00 pm

Assignment type: **Pair**, you may work with one partner

# Analyzing ELF files

In this assignment you will use memory-mapped file I/O to open and read
ELF files.

You can get started by downloading [csf\_assign04.zip](csf_assign04.zip)
and unzipping it.

The code for the program is in a source file called `magic.c`. The
provided `Makefile` will build an executable called `magic`.

## ELF file format

The [Wikipedia article on the ELF format](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format)
 describes the format of an ELF file.  (For posterity, here is an
[archival link](https://web.archive.org/web/20211018192457/https://en.wikipedia.org/wiki/Executable_and_Linkable_Format)
to this article, in case it changes in a way that is inconsistent with this assignment
description.)

## Requirements

These are the main requirements for your program:

1. It must open the file specified as the command-line argument and
   use [mmap](https://man7.org/linux/man-pages/man2/mmap.2.html) to
   map its data into memory.
2. It should determine whether the opened file is an ELF file, and
   if not, print `Not an ELF file` to standard output and exit
   normally
3. If it is an ELF file, it summarize the ELF header, sections, and
   symbols (as described below)
