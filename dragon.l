/* Andrew C. Bodine
 * Compilers - Dragon
 * module: lex
 */

%{

#ifndef DRAGON_L
#define DRAGON_L

/* includes */
#include <stdlib.h>
//#include "y.tab.h"
#include "stdio.h" // remove

/* prototypes */
void yyerror( char *s );

#endif /* dragon.l */

%}

%option nounput noinput

 /* regular definitions */
whitespace	[ \t\n]
bcomment	\{(.*\n)*.*\}
pscomment	\(\*(.*\n)*.*\*\)
digit		[0-9]
letter		[a-zA-Z]
ident		{letter}({letter}|{digit})*

%%

{whitespace}	{ /* ignore */ }
{bcomment}	{ /* comment: { ... } */ }
{pscomment}	{ /* comment: (* ... *)*/ }
{digit}		{ fprintf( stderr, "[DIGIT]" ); }
{letter}	{ fprintf( stderr, "[LETTER]" ); }
{ident}		{ fprintf( stderr, "[IDENT]" ); }

%%

int yywrap( ) {
	return 1;
}
