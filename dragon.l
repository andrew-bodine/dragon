/* Andrew C. Bodine
 * Compilers - Dragon
 * module: lex
 */

%{

#ifndef DRAGON_L
#define DRAGON_L

/* includes */
#include <stdlib.h>
#include <stdio.h>
#include "y.tab.h"

/* prototypes */
void yyerror( char *s );

#endif /* dragon.l */

%}

%option nounput noinput

 /* regular definitions */
whitespace	[ \t\n]
bcomment	\{(.*\n)*.*\}
pscomment	\(\*(.*\n)*.*\*\)
letter		[a-zA-Z]
digit		[0-9]
digits		{digit}{digit}*
number		{digits}|({digits}.{digits})
ident		{letter}({letter}|{digit})*

%%

{whitespace}	{ /* ignore */ }

{bcomment}		{ /* comment: { ... } */ }
{pscomment}		{ /* comment: (* ... *) */ }

{ident}			{ /* more */ return _IDENT_; }
{number}		{ /* more */ return _NUMBER_; }
"program"		{ return _PROGRAM_; }
"begin"			{ return _BEGIN_; }
"end"			{ return _END_; }
"var"			{ return _VAR_; }
"array"			{ return _ARRAY_; }
"of"			{ return _OF_; }
"integer"		{ return _INTEGER_; }
"real"			{ return _REAL_; }
"function"		{ return _FUNCTION_; }
"procedure"		{ return _PROCEDURE_; }
"if"			{ return _IF_; }
"then"			{ return _THEN_; }
"else"			{ return _ELSE_; }
"while"			{ return _WHILE_; }
"do"			{ return _DO_; }
"not"			{ return _NOT_; }
"="				{ /* more */ return _RELOP_; }
"<>"			{ /* more */ return _RELOP_; }
"<"				{ /* more */ return _RELOP_; }
"<="			{ /* more */ return _RELOP_; }
">"				{ /* more */ return _RELOP_; }
">="			{ /* more */ return _RELOP_; }
"+"				{ /* more */ return _ADDOP_; }
"-"				{ /* more */ return _ADDOP_; }
"or"			{ /* more */ return _ADDOP_; }
"*"				{ /* more */ return _MULOP_; }
"/"				{ /* more */ return _MULOP_; }
"div"			{ /* more */ return _MULOP_; }
"mod"			{ /* more */ return _MULOP_; }
"and"			{ /* more */ return _MULOP_; }
":="			{ /* more? */ return _ASSIGNOP_; }
.				{ yyerror( "lex: unrecognized input" ); }

%%

int yywrap( ) {
	return 1;
}
