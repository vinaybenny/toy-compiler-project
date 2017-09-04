# toy-compiler-project
Intended as a codebase for creating a toy compiler for a C-like language using Logic programming paradigms. The language used for logic programming is SWI-Prolog. 

The intent is to create a new toy programming language, which our toy compiler reads and compiles into assembly-level code that corresponds to IA-32 (x86 32 bit) instruction set. Please note that this new language and its compiler are not intended to be used anywhere; it is merely a proof-of-concept of how to design a programming language, for educational purposes only.

Currently this codebase includes an toy interpreter for a hypothetical programming language that has WHILE looping and IF-ELSE conditional branching constructs. The interpreter directly reads a program written using that hypothetical programming language; parses the various commands in the program by constructing a parse-tree; performs the operations that the program specifies based on the constructs in the hypothetical language. The output from the interpretation will show the list of values assigned to each variable in our new programming language.

## Updates- 
04-Sep-2017
- A simple interpreter has been completed for a toy language which can perform simple arithmetic operations, conditional branching using if-else, and elementary looping using while-do constructs.
