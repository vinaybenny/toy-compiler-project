/*****************************************************************************************************
PURPOSE: This program creates an interpreter for a WHILE-IF based toy
language. The intent is to demonstrate how an interpreter might work.

An interpreter needs to break down the program into a tree construct;
the tree is then executed first from deep left all the way upwards and
rightwards.

AUTHOR: V Benny (based on R Voicu's course material for NUS CS4212-
Compiler Design)

DATE: 01-Sep-2017

NOTES:
1. Only integer datatypes are currently defined for the toy language.
2. Division operator should be "//" instead of "/" as clpfd library
   defines integer division using the "//"
3. Condition expressios for equality should use "=". This is not counted
   as assignment when within the condition statements for if and while.

*****************************************************************************************************/


/* Add the constraint logic programming library for declarative integer arithmetic as a fact.
This by default sets +, -, *,-, \=, etc as defined operators.
*/
:- [library(clpfd)].


/* Set up toy language keywords as operators in addition to the ones defined by clpfd.
Precedence values from 750 are chosen as the clpfd defined arithmetic
operators have precedence of 700 and below.
*/
:- op(750,fx,if).
:- op(749,xfx,then).
:- op(750,fx,while).
:- op(749,xfx,do).
:- op(748,xfx,else).
:- op(747,yf,;). /* Least precedence; statements in input program need to be first broken by semicolons */


/********************************************************************************************************
interpret/3 function: This function breaks the code that is to be
interpreted into a tree structure, with each operator in the code being
the current split node and the operands being the left and right
branches of the tree. The root idea is that the tree would be evaluated
from leftmost-deepest branch to the parent node, to the right branch all
the way until the tree is traversed fully.
********************************************************************************************************/

/* When encountering semicolon, break each statement on either side into two branches of the tree.*/
interpret( (St1;St2), Dictin, Dictout) :- interpret(St1, Dictin, Dicttemp), interpret(St2, Dicttemp, Dictout).
/* For statements with semicolon, strip the semicolon and interpret only the statement itself.*/
interpret( (St;), Dictin, Dictout)  :- interpret(St, Dictin, Dictout).
/* For statements of assignment type, strip out components of the statement, and create key-value pair
for the assigned variable and value. put_assoc/4 is an autoloaded library in Prolog that enables inserting
key value pairs into an association dictionary*/
interpret( (Var=Expr), Dictin, Dictout):- atom(Var), evaluate(Expr, Val, Dictin), put_assoc(Var, Dictin, Val, Dictout),!.
/* For if-else statements, evaluate condition first. Based on value of condition being 1 or 0 (True/False),
    evaluate statement 1 or statement 2 selectively.*/
interpret( (if Condexpr then { St1 } else { St2 } ), Dictin, Dictout ):- evaluate(Condexpr, Condval, Dictin),
    Check =.. [#=, Condval, 1],
    (   Check
    ->  interpret(St1, Dictin, Dictout)
    ;   interpret(St2, Dictin, Dictout)).
/* For if statements, evaluate condition first. Based on value of condition being 1 or 0 (True/False),
    evaluate statement 1 or not.*/
interpret( (if Condexpr then { St1 } ), Dictin, Dictout ):- evaluate(Condexpr, Condval, Dictin),
    Check =.. [#=, Condval, 1],
    (   Check
    ->  interpret(St1, Dictin, Dictout)
    ;   Dictout =  Dictin).
/* For While-Do statements, evaluate condition using an if-else statement, and based on outcome,
    execute body of while loop and recursively call while-do statement again. If the if-else condtion is
    false, execute the else statement, which is a dummy statement.*/
interpret(while Condexpr do {St}, Dictin, Dictout ):-
    interpret(if Condexpr then {
                              St;
                              while Condexpr do {St}
                          }, Dictin, Dictout).

/*******************************************************************************************************
Evaluate/3: These functions will evaluate the arithmetic expressions in
the interpreted code. The function breaks down each expression into
components like integer values, variables and operators. For variables,
the integer value of that variable is obtained from the dictionary, and
used to calculate the value represented by the variable.
*******************************************************************************************************/
/* If the expression is just an integer, the value is just that integer.*/
evaluate(Intval, Intval, _):- integer(Intval),!.
/* If the expression is a variable, obtain the value of that variable from the dictionary.
get_assoc/3 is an autoloaded function that takes in a key, and returns its value pair.*/
evaluate(Var, Val, Dictin):- atom(Var), get_assoc(Var, Dictin, Val),!.
/* If the expression is an arithmetic operation, break it into left and right operands and
the operator. Evaluate each operand, obtain its value and use the values to create the final
value of the expression.*/
evaluate(Expr, Val, Dictin):- Expr =.. [Op, Left, Right],
    member(Op, [+, -, *, //]),
    evaluate(Left, Partval1, Dictin), evaluate(Right, Partval2, Dictin),
    Result =.. [Op,Partval1, Partval2],
    Val #= Result,!.
/* Handle uni-operand arithmetic operations, like cases where a number is specified as a
a double negative or a negative-positive number is specified. eg: b = 1+-2*/
evaluate(Expr, Val, Dictin):- Expr =..[Op, Right],
    member(Op,[+, -]),
    evaluate(Right, Partval, Dictin),
    Result =.. [Op, Partval],
    Val #= Result,!.
/* Handle conditional operators where the Expr evaluates to True =1/False=0. */
evaluate(Expr, Val, Dictin):- Expr =.. [Op, Left, Right],
    member(Op,[<, =<, >, >=, =, \=]),
    evaluate(Left, Partval1, Dictin), evaluate(Right, Partval2, Dictin),
    atomic_concat('#',Op, Newop), /*  Concatenates # to operator to create a clpfd comparison operator*/
    Result =.. [Newop, Partval1, Partval2],( Result -> Val = 1; Val = 0 ),!.

/*Test Program*/
/*Program = ( a = 10 ; if a > 10 then {c = 5} else { c = 4} ; while c < 10 do { c = c+1} ; ),interpret(Program, XX, YY).*/
