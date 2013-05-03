/* Andrew C. Bodine
 * Compilers - Dragon
 * module: lex
 */

%{

#ifndef DRAGON_L
#define DRAGON_L

/* includes */
#include <stdlib.h>
#include "syn_tree.h"
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
inumber		{digits}
rnumber		{digits}.{digits}
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

"program"		{ return _PROGRAM_; }
"begin"			{ return _BEGIN_; }
"end"			{ return _END_; }
"function"		{ return _FUNCTION_; }
"procedure"		{ return _PROCEDURE_; }
"while"			{ return _WHILE_; }
"do"			{ return _DO_; }
"if"			{ return _IF_; }
"then"			{ return _THEN_; }
"else"			{ return _ELSE_; }
"var"			{ return _VAR_; }
"array"			{ return _ARRAY_; }
{span}			{ return _SPAN_; }
"of"			{ return _OF_; }
"not"			{ return _NOT_; }
"integer"		{ return _INTEGER_; }
"real"			{ return _REAL_; }

{relop}			{ return _RELOP_; }
{addop}			{ return _ADDOP_; }
{mulop}			{ return _MULOP_; }
{assignop}		{ return _ASSIGNOP_; }

{terminal}		{ return yytext[ 0 ]; }
{ident}			{
				yylval.sval = strdup( yytext );
				return _IDENT_;
			}
{inumber}		{
				yylval.ival = atoi( yytext );
				return _INUMBER_;
			}
{rnumber}		{
				yylval.rval = atof( yytext );
				return _RNUMBER_;
			}

.			{ yyerror( "unrecognized character" ); }

%%

int yywrap( ) {
	return 1;
}
