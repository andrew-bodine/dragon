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

 /* options */
%option nounput noinput

 /* regular definitions */
ws		[ \t\n]

bcbegin		[{]
bcbody		([^}]*\n*)*
bcend		[}]

pscbegin	\(\*
pscbody		([^*]*\n*)*
pscfend		\*[^*\)\n]*
pscend		\*\)

letter		[a-zA-Z]
digit		[0-9]
digits		{digit}{digit}*
number		{digits}|({digits}.{digits})
ident		{letter}({letter}|{digit})*

span		\.\.
terminal	[(|)|;|.|,|:|\[|\]|+|-]

relop		[=|<>|<|<=|>|>=]
addop		or
mulop		[*|/]|div|mod|and
assignop	:=

 /* states */
%x bcomment pscomment

%%

{ws}			{ /* ignore */ }

{bcbegin}		{ /* comment: { */ BEGIN( bcomment ); }
<bcomment>{bcbody}	{ /* ... */ }
<bcomment>{bcend}	{ /* } */ BEGIN( INITIAL ); }

{pscbegin}		{ /* comment: (* */ BEGIN( pscomment ); }
<pscomment>{pscbody}	{ /* ... */ }
<pscomment>{pscfend}	{ /* * followed by not ) */ }
<pscomment>{pscend}	{ /* *) */ BEGIN( INITIAL ); }

"program"{ws}		{ return _PROGRAM_; }
"begin"{ws}		{ return _BEGIN_; }
{ws}"end"		{ return _END_; }
"function"{ws}		{ return _FUNCTION_; }
"procedure"{ws}		{ return _PROCEDURE_; }
"while"{ws}		{ return _WHILE_; }
{ws}"do"		{ return _DO_; }
"if"{ws}		{ return _IF_; }
{ws}"then"		{ return _THEN_; }
"else"{ws}		{ return _ELSE_; }
"var"{ws}		{ return _VAR_; }
{ws}"array"		{ return _ARRAY_; }
{span}			{ return _SPAN_; }
{ws}"of"		{ return _OF_; }
{ws}"not"		{ return _NOT_; }
{ws}"integer"{ws}*	{ return _INTEGER_; }
{ws}"real"{ws}*		{ return _REAL_; }

{relop}			{ return _RELOP_; }
{addop}			{ return _ADDOP_; }
{mulop}			{ return _MULOP_; }
{assignop}		{ return _ASSIGNOP_; }

{terminal}		{ return yytext[ 0 ]; }
{ident}			{ return _IDENT_; }
{number}		{ return _NUMBER_; }

.			{ yyerror( "unrecognized character" ); }

%%

int yywrap( ) {
	return 1;
}
