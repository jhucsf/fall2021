---
layout: default
title: "Resources"
category: "resources"
---

This page has links to useful resources.

# Information

This section has links to some information resources you might find useful.

## Practice problems and exams

*Coming soon!*

<!--
* [Midterm, Spring 2020](resources/midterm-spring2020.pdf), [Solution](resources/midterm-spring2020-soln.pdf)
* [Exam 1 practice questions](resources/exam1review.html), [Answers](resources/exam1review-solutions.html)
* [Assembly language mini-exercises](resources/assemblyMini.html)
* [Assembly language exercise](resources/assembly.html), [solution](resources/asmExerciseSoln.zip)
* [Assembly language exercise 2 (more challenging)](resources/assembly2.html)
* [Zipfile for in-class assembly language exercise](resources/assembly_exercise.zip)
* [Exam 2 practice questions](resources/exam2review.html), [Answers](resources/exam2review-solutions.html)
* [Exam 3 practice questions](resources/exam3review.html), [Answers](resources/exam3review-solutions.html)
* [Final, Spring 2020](resources/final-spring2020.pdf), [Solution](resources/final-spring2020-soln.pdf)
* [Final, Fall 2019](resources/final-fall2019.pdf), [Solution](resources/final-fall2019-soln.pdf)
* [Exam 4 practice questions](resources/exam4review.html), [Answers](resources/exam4review-solutions.html)
* [Exam 4, Fall 2020](resources/exam04-fall2020.pdf), [Solution](resources/exam04-fall2020-solution.pdf)
-->

## x86-64 assembly programming resources

* [Brown x64 cheat sheet](https://cs.brown.edu/courses/cs033/docs/guides/x64_cheatsheet.pdf)
* [Brown gdb cheat sheet](https://cs.brown.edu/courses/cs033/docs/guides/gdb.pdf)
* [CMU summary of gdb commands for x86-64](http://csapp.cs.cmu.edu/3e/docs/gdbnotes-x86-64.pdf)

# Software

This section covers the software you'll be using in working on programming assignments.

## Linux

For the programming assignments, you will need to use a recent x86-64 (64 bit) version of Linux.

**Important**: the code you submit is required to run correctly on Ubuntu 18.04, since
that is the version of Linux that [Gradescope](https://www.gradescope.com/) uses.

Here are some options for getting your development environment set up.

You can install [Ubuntu 18.04](https://releases.ubuntu.com/18.04.5/) directly on your
computer.  This is a good option if you are comfortable installing operating systems
from installation media.  [Ubuntu 20.04](https://releases.ubuntu.com/20.04/) should
also be fine, although it's theoretically possible that your code might behave differently
in 20.04 vs.&nbsp;18.04.

On Windows 10, you can use the [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10)
(WSL).  Once WSL is enabled, you can install Ubuntu 18.04 from the Microsoft Store.  Make sure that
you install the [tools](#tools) listed below.  Using WSL is an excellent option if you are
comfortable doing your development work inside a terminal session.

On MacOS and Windows, you can use virtual machine software such as [VirtualBox](https://www.virtualbox.org/)
to run Ubuntu 18.04 as a guest OS.  If you do a web search for "ubuntu 18.04 image for virtualbox"
you will find pre-made OS images that you can download.  (I can't directly vouch for any of these,
so be careful.)  You will likely need to enable hardware virtualization support in your computer's
BIOS to allow VirtualBox to run correctly.  We recommend dedicating a significant amount of RAM
(at least 4GB) to the virtual machine (this should be fine as long as your computer has at least
8 GB of RAM.)

Note that if you are using an M1-based (ARM) Mac computer, there aren't any good
options for setting up a local development environment.  Virtualization won't work
in the case because the computer doesn't use an x86-64 CPU.

It is possible to use the CS ugrad machines to do your development work.  Note, however,
that this environment is not based on Ubuntu 18.04, and your programs may be behave
differently.  A correctly-written program that is free from memory errors (such
as using uses of uninitialized values) should, *in general*, behave identically on the
ugrad machines and Gradescope, but ultimately it is your responsibility to ensure that your
programs work under Ubuntu 18.04.

## Tools

Some of the tools you'll want to have are:

* gcc
* g++
* make
* ruby
* valgrind
* git

All of these are available by default on the Ugrad computers.

To install on an Ubuntu-based system:

```
sudo apt-get install gcc g++ make ruby valgrind git
```

You'll also want to install a text editor.  [Emacs](https://www.gnu.org/software/emacs/) and [Vim](https://www.vim.org/) are good options:

```
sudo apt-get install emacs vim
```

<!--
To install on a Fedora system:

> <code class="cmd">sudo yum install gcc g++ make ruby valgrind git</code>
-->
