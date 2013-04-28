/* Andrew C. Bodine
 * Compilers - Dragon
 * module: yacc
 */

%{

#ifndef DRAGON_Y
#define DRAGON_Y

/* includes */
#include <stdio.h>
#include <stdlib.h>

/* pointers */

/* prototypes */
int yylex( void );
void yyerror( char *s );

#endif /* dragon.y */

%}

/* yylval union */

/* tokens */
%token IDENT
%token NUMBER		/* matches unsigned integers */
%token PROGRAM 		/* starts the main program */
%token BEGIN		/* starts a new block */
%token END		/* ends a block */
%token VAR		/* starts a list of identifier names */
%token ARRAY		/* signals an array type */
%token OF		/* used in array type declaration */
%token INTEGER		/* basic integer type */
%token REAL		/* basic real (float) type */
%token FUNCTION		/* starts a function (returns values, have no side-effects) declaration */
%token PROCEDURE	/* starts a procedure (returns no values, may have side-effects) declaration */
%token IF		/* starts an IF statement */
%token THEN		/* part of an IF statement */
%token ELSE		/* starts the ELSE part of an IF-THEN-ELSE statement */
%token WHILE		/* starts a WHILE statement */
%token DO		/* the DO part of a WHILE-DO statement */
%token NOT		/* logical NOT (negation) */
%token RELOP		/*
				=  : equal
				<> : not-equal
				<  : less-than
				<= : less-or-equal
				>  : greater-than
				>= : greater-or-equal
			*/
%token ADDOP		/* 
				+  : addition for both integer and real arguments
				-  : subtraction for both integer and real arguments
			 	or : logical OR
			*/
%token MULOP		/* 
				*   : multiplication for both integer and real arguments
				/   : division for both integer and real arguments
				div : quotient in integer division
				mod : remainder in integer division
				and : logical AND
			*/
%token ASSIGNOP		/* := */
