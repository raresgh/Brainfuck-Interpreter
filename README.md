# Brainfuck-Interpreter
This is a Brainfuck interpreter written in Assembly x86 AT&amp;T Syntax

There are a few files in here for you:

 - main.s:
    This file contains the main function.
    It reads a file from a command line argument and passes it to your brainfuck implementation.

 - read_file.s:
    Holds a subroutine for reading the contents of a file.
    This subroutine is used by the main function in main.s.

 - brainfuck.s:
    This is where you the implementation of brainfuck is.

 - Makefile:
    A file containing compilation information.  If you have a working make,
    you can compile the code in this directory by simply running the command `make`.

  In your terminal:
  1. Run `make`
  2. Run `./brainfuck`
