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
whitespace	[ \t\n]

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

relop		[=|<>|<|<=|>|>=]
addop		[+|or|-]
mulop		[*|/]|div|mod|and
assignop	:=

span		\.\.
terminal	[(|)|;|.|,|:|\[|\]|+|-]

 /* states */
%x bcomment pscomment

%%

{whitespace}			{ /* ignore */ }

{bcbegin}				{ /* comment: { */ BEGIN( bcomment ); }
<bcomment>{bcbody}		{ /* ... */ }
<bcomment>{bcend}		{ /* } */ BEGIN( INITIAL ); }

{pscbegin}				{ /* comment: (* */ BEGIN( pscomment ); }
<pscomment>{pscbody}	{ /* ... */ }
<pscomment>{pscfend}	{ /* * followed by not ) */ }
<pscomment>{pscend}		{ /* *) */ BEGIN( INITIAL ); }

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

{relop}			{ return _RELOP_; }
{addop}			{ return _ADDOP_; }
{mulop}			{ return _MULOP_; }
{assignop}		{ return _ASSIGNOP_; }

{span}			{ return _SPAN_; }
{terminal}		{ return yytext[ 0 ]; }
{ident}			{ return _IDENT_; }
{number}		{ return _NUMBER_; }

.				{ yyerror( "unrecognized character" ); }

%%

int yywrap( ) {
	return 1;
}
