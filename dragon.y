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
%token _PROGRAM_ 	/* starts the main program */
%token _BEGIN_		/* starts a new block */
%token _END_		/* ends a block */
%token _FUNCTION_	/* starts a function (returns values, have no side-effects) declaration */
%token _PROCEDURE_	/* starts a procedure (returns no values, may have side-effects) declaration */
%token _IF_		/* starts an IF statement */
%token _THEN_		/* part of an IF statement */
%token _ELSE_		/* starts the ELSE part of an IF-THEN-ELSE statement */
%token _WHILE_		/* starts a WHILE statement */
%token _DO_		/* the DO part of a WHILE-DO statement */
%token _VAR_		/* starts a list of identifier names */
%token _ARRAY_		/* signals an array type */
%token _SPAN_		/* .. : used in array instantiation, means span set of numbers */
%token _OF_		/* used in array type declaration */
%token _NOT_		/* logical NOT (negation) */
%token _INTEGER_	/* basic integer type */
%token _REAL_		/* basic real (float) type */
%token _RELOP_		/*
				=  : equal
				<> : not-equal
				<  : less-than
				<= : less-or-equal
				>  : greater-than
				>= : greater-or-equal
			*/
%token _ADDOP_		/* 
				+  : addition for both integer and real arguments
				-  : subtraction for both integer and real arguments
				or : logical OR
			*/
%token _MULOP_		/* 
				*   : multiplication for both integer and real arguments
				/   : division for both integer and real arguments
				div : quotient in integer division
				mod : remainder in integer division
				and : logical AND
			*/
%token _ASSIGNOP_	/* := */
%token _IDENT_
%token _NUMBER_		/* matches unsigned integers */

/* precedence */
%nonassoc _IF_THEN_
%nonassoc _ELSE_

/* types */

/* start */
%start program

%%

program			: _PROGRAM_ _IDENT_ '(' identifier_list ')' ';'
	   		  declarations
			  subprogram_declarations
			  compound_statement
			  '.'									{;}
			| /* epsilon */								{;}
			;

identifier_list		: _IDENT_								{;}
		  	| identifier_list ',' _IDENT_						{;}
			;

declarations		: declarations _VAR_ identifier_list ':' type ';'			{;}
	       		| /* epsilon */								{;}
			;

type			: standard_type								{;}
	   		| _ARRAY_ '[' _NUMBER_ _SPAN_ _NUMBER_ ']' _OF_ standard_type		{;}
			;

standard_type		: _INTEGER_								{;}
			| _REAL_								{;}
			;

subprogram_declarations	: subprogram_declarations subprogram_declaration ';'			{;}
			| /* epsilon */								{;}
			;

subprogram_declaration	: subprogram_head
			  declarations
			  subprogram_declarations
			  compound_statement							{;}
			;

subprogram_head		: _FUNCTION_ _IDENT_ arguments ':' standard_type ';'			{;}
			| _PROCEDURE_ _IDENT_ arguments ';'					{;}
			;

arguments		: '(' parameter_list ')'						{;}
			| /* epsilon */								{;}
			;

parameter_list		: identifier_list ':' type						{;}
			| parameter_list ';' identifier_list ':' type				{;}
			;

compound_statement	: _BEGIN_ optional_statements _END_					{;}
			;

optional_statements	: statement_list							{;}
			| /* epsilon */								{;}
			;

statement_list		: statement								{;}
			| statement_list ';' statement						{;}
			;

statement		: variable _ASSIGNOP_ expression					{;}
			| procedure_statement							{;}
			| compound_statement							{;}
			| _IF_ expression _THEN_ statement %prec _IF_THEN_			{;}
			| _IF_ expression _THEN_ statement _ELSE_ statement			{;}
			| _WHILE_ expression _DO_ statement					{;}
			;

variable		: _IDENT_								{;}
			| _IDENT_ '[' expression ']'						{;}
			;

procedure_statement	: _IDENT_								{;}
			| _IDENT_ '(' expression_list ')'					{;}
			;

expression_list		: expression								{;}
			| expression_list ',' expression					{;}
			;

expression		: simple_expression							{;}
			| simple_expression _RELOP_ simple_expression				{;}
			;

simple_expression	: term									{;}
			| sign term								{;}
			| simple_expression _ADDOP_ term					{;}
			| simple_expression sign term						{;}
			;

term			: factor								{;}
		 	| term _MULOP_ factor							{;}
			;

factor			: variable								{;}
		   	| _IDENT_ '(' expression_list ')'					{;}
			| _NUMBER_								{;}
			| '(' expression ')'							{;}
			| _NOT_ factor								{;}
			;

sign			: '+'									{;}
		 	| '-'									{;}
			;

%%

void yyerror( char *s ) {
	fprintf( stderr, "%s\n", s );
}
int main( void ) {
	yyparse( );
	return 0;
}

