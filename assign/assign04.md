---
layout: default
title: "Assignment 4: Analyzing ELF files"
---

**Due**: Thursday, Nov 11th by 11:00 pm

Assignment type: **Pair**, you may work with one partner

*Update 11/11*: corrected an error in the description of how to detect an
error return value from `mmap`

# Analyzing ELF files

In this assignment you will use memory-mapped file I/O to open and read
ELF files.

You can get started by downloading [csf\_assign04\_c.zip](csf_assign04_c.zip)
or [csf\_assign04\_cplusplus.zip](csf_assign04_cplusplus.zip)
and unzipping it.  (Two skeleton projects are provided so that you
can choose whether you want to write the program in C or C++.)

The code for the program is in a source file called `magic.c` or
`magic.cpp`. The provided `Makefile` will build an executable called `magic`.

## Grading criteria

Your grade will be determined as follows:

* Your program compiles: 4%
* `README.txt` is submitted: 1%
* Correct output for x86-64 relocatable object files: 36%
* Correct output for x86-64 executables: 30%
* Correct output for x86-64 shared libraries: 18%
* Correct output for 32-bit and/or big-endian ELF files: 1%
* Design and coding style: 10%

As usual, we expect your program not to have any memory errors or memory
leaks. Be sure to use valgrind to tests for these.

## A word of caution

You can no doubt find many example programs on the web that extract
information from ELF files. For this assignment (and all CSF assignments),
do *not* copy any code from any external sources. You should be able
to implement this program entirely on your own, using the information in
the Wikipedia article.  Ask questions on Campuswire or in office hours
if you need help.

## ELF file format

The [Wikipedia article on the ELF format](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format)
 describes the format of an ELF file.  (For posterity, here is an
[archival link](https://web.archive.org/web/20211018192457/https://en.wikipedia.org/wiki/Executable_and_Linkable_Format)
to this article, in case in the future it changes in a way that is inconsistent with this assignment
description.)

## Requirements

These are the main requirements for your program:

1. It must open the file specified as the command-line argument and
   use [mmap](https://man7.org/linux/man-pages/man2/mmap.2.html) to
   map its data into memory.
2. It should determine whether the opened file is an ELF file, and
   if not, print `Not an ELF file` to standard output and exit
   normally
3. If it is an ELF file, it summarize the ELF header, sections, and symbols
  (as described below), and then exit normally

Note that ELF files for 32 bit systems are slightly different than ELF
files for 64 bit systems. Also, ELF files can use little-endian
or big-endian byte ordering depending on the machine type.
Since handling these variations can be tricky, you can earn up to
99% of full credit by *only* supporting 64 bit little-endian ELF files,
such as the ones produced on x86-64 Linux systems.

## Memory-mapped file I/O

As we've discussed in lecture, the OS kernel uses pages of physical memory as
a cache for data on mass storage devices (hard disks and SSDs).  The
[mmap](https://man7.org/linux/man-pages/man2/mmap.2.html) system call
allows programs to map pages containing disk or SSD data into their own
address space.

Let's say that you want to map the contents of an ELF file into memory
using `mmap`.  First, you'll need to use the
[open](https://man7.org/linux/man-pages/man2/open.2.html) system call
to open the file:

```c
int fd = open(filename, O_RDONLY);
```

This call willl return a *file descriptor* for the opened file, or will
return a negative value if the file can't be opened.

Next, the program will need to know how many bytes of data the file has.
This can be accomplished by calling the
[fstat](https://man7.org/linux/man-pages/man3/fstat.3p.html)
system call:

```c
struct stat statbuf;
int rc = fstat(fd, &statbuf);
if (rc != 0) {
  // error
} else {
  size_t file_size = statbuf.st_size;
  // ...
}
```

Once the program knows the size of the file, creating a private read-only
mapping using `mmap` will allow the program to access the file contents
in memory:

```c
void *data = mmap(NULL, file_size, PROT_READ, MAP_PRIVATE, fd, 0);
```

If `mmap` returns a pointer value other than `((void *)-1)`,
the pointer value points to a region of memory in which the program
can access the file contents.

## Decoding ELF files

All of the information you will need to allow your program to make sense of
the contents of an ELF file is in
[the Wikipedia article](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format).

Here is a high-level summary:

* The ELF header at the beginning of the ELF file data contains general
  information about the ELF file, and indicates the locations of the
  program headers and section headers
* The section headers describe the layout of the sections within the
  ELF file

In the ELF header, the `e_shstrndx` field indicates which section is
the `.shstrtab` section.  This section is a string table that contains
the section names.  This is very important information, since the section
names stored in the `.shstrtab` header will allow you to determine
the identities of the other sections.  It is especially important
for your program to locate the `.symtab` and `.strtab` sections, since you
will need to access data in these sections to find information about symbols.

## `<elf.h>`

On Linux systems, the `<elf.h>` header defines data types and constants
that will be useful for parsing ELF files.  This header file is located
in `/usr/include/elf.h`.  You should open this file using a text editor
so that you can see the definitions it contains.

As an example, the `Elf64_Ehdr` data type defines the layout of the ELF
header for 64-bit ELF files.  Here is an example of how your program
could use this header. Let's say that `data` is a pointer to the beginning
of the ELF file data in memory.  The ELF header is always at the beginning
of an ELF file.  So, casting `data` to be a pointer to `Elf64_Ehdr`
would allow your program to inspect the fields of the ELF header:

```c
Elf64_Ehdr *elf_header = (Elf64_Ehdr *) data;
printf(".shstrtab section index is %u\n", elf_header->e_shstrndx);
```

\[One important detail to note here is that directly accessing fields of structs
in a memory-mapped file will only yield the correct value if the byte ordering
used in the file is the same as the byte ordering used by the system
on which the program is running. As mentioned earlier, you may assume this
as a simplifying assumption in your code.\]

Other important data types in `<elf.h>` include `Elf64_Shdr`, which describes
the layout of a section header, and `Elf64_Sym`, which describes the layout
of a symbol.

Note that there are 32-bit variants of each data type (e.g., `Elf32_Ehdr`),
but you are not really required to handle 32-bit ELF files.

In general, much of your program logic will be concerned with computing the
address of a structure in the ELF data, and casting that address value
to be a pointer to one of the data types in `<elf.h>`.

We highly recommend using the `unsigned char *` type as the data type for
doing address computations.  Pointer arithmetic using this type will be in
units of bytes, and if you access an `unsigned char` value using such a
pointer, you are guaranteed to see an unsigned value.

## Suggested approach

Here is a suggested approach to finding the section and symbol table information:

1. Find the section headers using the `e_shoff` value in the ELF header.
   The number of section headers is indicated by the `e_shnum` value
   in the ELF header.
2. Use the `e_shstrndx` value in the ELF header to indicate which
   section contains the string table with the names of the sections.
   (This is the `.shstrtab` section.)
3. Scan through the section headers, which will be objects of type
   `Elf64_Shdr`.  In each section header, the `sh_offset` value indicates
   the location of that section's data, the `sh_size` indicates the
   size of the section's data, and the `sh_name` field is the offset of the
   section's name string in the `.shstrtab` header.  Make a note of the name
   of each section, and other required information. Based on your scan of
   the section headers, you should be able to print the required output for
   each section.  See [Required output](#required-output) below.
4. The `.symtab` section is a sequence of `Elf64_Sym` objects.
   Each one has an `st_name` field. The value of `st_name`, if it is not
   0, is the offset of the symbol's name string in the `.strtab`
   section data.  By scanning the symbols in the `.symtab` section data,
   you should be able to print the required information for each
   symbol.  (Again, see [Required output](#required-output).)

## Required output

Your program will be invoked as

<div class="highlighter-rouge"><pre>
./magic <i>filename</i>
</pre></div>

where *filename* is the file to analyze.  As a special case, if the file can't
be opened or can't be mapped into memory, your program should print an
error message to standard error and exit with a non-zero exit code.

If the file being analyzed is not an ELF file, your program should simply
print

```
Not an ELF file
```

to standard output and exit with an exit code of 0.

Otherwise, the program should summarize the ELF header, summarize the section
headers, and summarize the symbols, and then exit with an exit code of 0.

To summarize the information in the ELF header, your program should
print three lines of the form

<div class="highlighter-rouge"><pre>
Object file type: <i>objtype</i>
Instruction set: <i>machtype</i>
Endianness: <i>endianness</i>
</pre></div>

For *objtype* and *machtype*, translate the values of the `e_type` and
`e_machine` fields of the ELF header to strings using the
`get_type_name` and `get_machine_name` functions defined in
`elf_names.h` and `elf_names.c`/`elf_names.cpp`.

For *endianness*, print either `Little endian` or `Big endian`.
(Endianness is found in the `EI_DATA` element of the `e_ident`
array in the ELF header.)

After the ELF header summary, the program should print one line of output
for each section, in the following format:

<div class="highlighter-rouge"><pre>
Section header <i>N</i>: name=<i>name</i>, type=<i>X</i>, offset=<i>Y</i>, size=<i>Z</i>
</pre></div>

*N* is a section index in the range 0 to `e_shnum`-1.  *name* is the section
name, which will be a NUL-terminated string value in the `.shstrtab` section
data.  *X*, *Y*, *Z* are the values of the section header's `sh_type`,
`sh_offset`, and `sh_size` values, respectively. Each of these values should
be printed using the `%lx` conversion using `printf`.  Note that the name
may be an empty string.

After the summary of section headers, the program should print one line of
output for each symbol, in the following format:

<div class="highlighter-rouge"><pre>
Symbol <i>N</i>: name=<i>name</i>, size=<i>X</i>, info=<i>Y</i>, other=<i>Z</i>
</pre></div>

*N* is the index of the symbol (0 for first symbol), *name* is the name of the
symbol based on the value of the symbol's `st_name` value (if non-zero, it specifies
an offset in the `.strtab` section.) *X*, *Y*, *Z* are the values of the
symbol's `st_size`, `st_info`, and `st_other` fields, respectively,
printed using `printf` with the `%lx` conversion.

## Example input and output files

The following files are provided for you to use in testing:

Input file | ELF file type | Machine | Endianness | Expected output
---------- | ------------- | ------- | ---------- | ---------------
[sumarr\_x86\_64.o](assign04/sumarr_x86_64.o) | Relocatable object | x86-64 | Little endian | [sumarr\_x86\_64.o.out](assign04/sumarr_x86_64.o.out) 
[sumarr\_x86\_64](assign04/sumarr_x86_64) | Executable | x86-64 | Little endian | [sumarr\_x86\_64.out](assign04/sumarr_x86_64.out) 
[sumarr\_powerpc.o](assign04/sumarr_powerpc.o) | Relocatable object | PowerPC (32 bit) | Big endian | [sumarr\_powerpc.o.out](assign04/sumarr_powerpc.o.out) 
[sumarr\_powerpc](assign04/sumarr_powerpc) | Executable | PowerPC (32 bit) | Big endian | [sumarr\_powerpc.out](assign04/sumarr_powerpc.out) 
[sumarr\_sparc64.o](assign04/sumarr_sparc64.o) | Relocatable object | SPARC (64 bit) | Big endian | [sumarr\_sparc64.o.out](assign04/sumarr_sparc64.o.out) 
[sumarr\_sparc64](assign04/sumarr_sparc64) | Executable | SPARC (64 bit) | Big endian | [sumarr\_sparc64.out](assign04/sumarr_sparc64.out) 


All of these are compiled from a simple test program,
[sumarr.c](assign04/sumarr.c).

Your program should produce output identical to the expected output. For example:

```
curl -O https://jhucsf.github.io/fall2021/assign/assign04/sumarr_x86_64.o
curl -O https://jhucsf.github.io/fall2021/assign/assign04/sumarr_x86_64.o.out
./magic sumarr_x86_64.o > actual_sumarr_x86_64.o.out
diff sumarr_x86_64.o.out actual_sumarr_x86_64.o.out
echo $?
```

If the `diff` command does not produce any output, and exits with an exit code
of 0 (success), then your `magic` program produced the expected output
for `sumarr_x86_64.o`.

## Handling 32 bit and big-endian ELF files

If you choose to attemmpt handling 32 bit or big-endian ELF files, here
are some tips. (Please note that this is a significant amount of work for
almost no benefit!)

The `e_ident[EI_CLASS]` array element in the ELF header indicates whether
the ELF file is 32 bit or 64 bit.

As noted in the [&lt;elf.h&gt;](#elfh) section, there are a separate set
of data types for headers and symbol table entries in 32-bit ELF files.
You will need to use these if the ELF file being analyzed is a 32-bit file.

If the ELF file is big-endian, you will need to "byte swap" each multi-byte data value
that the program accessed, by reversing the bytes in its representation.
This is based on the assumption that your program will be running on
x86-64 Linux, which is a little-endian system.

# Submitting

Edit the `README.txt` file to summarize each team member's contributions.

You can create a zipfile of your solution using the command `make solution.zip`.

Submit your zipfile to Gradescope as **Assignment 4**.
