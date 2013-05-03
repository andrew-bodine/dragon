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
#include "syn_tree.h"
#include "sym_table.h"

/* pointers */
s_table *s_stack = NULL;
t_entry *e_ptr = NULL;
n_ptr t_ptr;

/* prototypes */
int yylex( void );
void yyerror( char *s );

#endif /* dragon.y */

%}

/* yylval union */
%union {
	int ival;	/* number */
	char *sval;	/* ident */
	n_ptr tval;	/* syntax tree node */
	r_ptr *record;	/* symbol table entry record */
};

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
%token <sval> _IDENT_
%token <ival> _NUMBER_	/* matches unsigned integers */

/* precedence */
%nonassoc _IF_THEN_
%nonassoc _ELSE_

/* types */
%type <tval> program identifier_list declarations compound_statement 
%type <tval> optional_statements statement_list statement variable expression simple_expression term factor
%type <record> type standard_type
%type <ival> sign

/* start */
%start program

%%

program			: _PROGRAM_ _IDENT_ '(' identifier_list ')' ';'				
			  declarations								
			  subprogram_declarations
			  compound_statement							{
			  										/* insert program symbol in symbol table */
			  										e_ptr = insert_entry( s_stack, $2 );
													install_program_record( e_ptr );
																										
													/* initiate program tree construction */
													t_ptr.program = make_program( make_ident( e_ptr, NULL ), $4.ident );
													
													/* add declarations */
													t_ptr.program->p_declarations = $7.ident;
													
													/* add sub programs */
													// TODO
													
													/* add statements */
													t_ptr.program->p_statements = $9.statement;
												}			  
			  '.'									{	
													print_program( t_ptr.program );
													print_sstack( s_stack );
													free_program( t_ptr.program );
												}
			| /* epsilon */								{}
			;

identifier_list		: _IDENT_								{
													e_ptr = find_entry( s_stack, $1 );
													if( e_ptr == NULL ) {
														e_ptr = insert_entry( s_stack, $1 );
														install_unknown_record( e_ptr );
													}
													$$.ident = make_ident( e_ptr, NULL );
												}
		  	| _IDENT_ ',' identifier_list						{
													e_ptr = find_entry( s_stack, $1 );
													if( e_ptr == NULL ) {
														e_ptr = insert_entry( s_stack, $1 );
														install_unknown_record( e_ptr );
													}
													$$.ident = make_ident( e_ptr, $3.ident );
												}
			;

declarations		: _VAR_ identifier_list ':' type ';' declarations			{
													$$.ident = $2.ident;
													t_ptr.ident = $$.ident;
													
													while( 1 ) {
														
														/* free temporary record installed previously */
														free_record( t_ptr.ident->e_ptr->e_record );
														
														install_entry_record( t_ptr.ident->e_ptr, $4 );
														if( t_ptr.ident->n_ident != NULL )
															t_ptr.ident = t_ptr.ident->n_ident;
														else
															break;
													}
													t_ptr.ident->n_ident = $6.ident;
												}
	       		| /* epsilon */								{	$$.ident = NULL; }
			;

type			: standard_type								{	$$ = $1; }
	   		| _ARRAY_ '[' _NUMBER_ _SPAN_ _NUMBER_ ']' _OF_ standard_type		{	$$ = make_array_record( $8, $3, $5 ); }
			;

standard_type		: _INTEGER_								{	$$ = make_integer_record( ); }
			| _REAL_								{	$$ = make_real_record( ); }
			;

subprogram_declarations	: subprogram_declarations subprogram_declaration ';'			{}
			| /* epsilon */								{}
			;

subprogram_declaration	: subprogram_head
			  declarations
			  subprogram_declarations
			  compound_statement							{}
			;

subprogram_head		: _FUNCTION_ _IDENT_ arguments ':' standard_type ';'			{}
			| _PROCEDURE_ _IDENT_ arguments ';'					{}
			;

arguments		: '(' parameter_list ')'						{}
			| /* epsilon */								{}
			;

parameter_list		: identifier_list ':' type						{}
			| parameter_list ';' identifier_list ':' type				{}
			;

compound_statement	: _BEGIN_ optional_statements _END_					{	$$ = $2; }
			;

optional_statements	: statement_list							{}
			| /* epsilon */								{	$$.statement = NULL; }
			;

statement_list		: statement								{	$$.statement = make_statement( $1.comp, NULL ); }
			| statement ';' statement_list						{	$$.statement = make_statement( $1.comp, $3.statement ); }
			;

statement		: variable _ASSIGNOP_ expression					{	$$.comp = make_comp( assignop, $1.comp, $3.comp ); }
			| procedure_statement							{}
			| compound_statement							{}
			| _IF_ expression _THEN_ statement %prec _IF_THEN_			{}
			| _IF_ expression _THEN_ statement _ELSE_ statement			{}
			| _WHILE_ expression _DO_ statement					{}
			;

variable		: _IDENT_								{	
													e_ptr = find_entry( s_stack, $1 );
													if( e_ptr == NULL ) {
														e_ptr = insert_entry( s_stack, $1 );
														install_unknown_record( e_ptr );
													}
													$$.comp = make_comp( ident, NULL, NULL );
													$$.comp->attr.ident = make_ident( e_ptr, NULL );
												}
			| _IDENT_ '[' expression ']'						{}
			;

procedure_statement	: _IDENT_								{}
			| _IDENT_ '(' expression_list ')'					{}
			;

expression_list		: expression								{}
			| expression_list ',' expression					{}
			;

expression		: simple_expression							{	$$.comp = $1.comp; }
			| simple_expression _RELOP_ simple_expression				{}
			;

simple_expression	: term									{	$$.comp = $1.comp; }
			| sign term								{}
			| simple_expression _ADDOP_ term					{}
			| simple_expression sign term						{}
			;

term			: factor								{	$$.comp = $1.comp; }
		 	| term _MULOP_ factor							{}
			;

factor			: variable								{}
		   	| _IDENT_ '(' expression_list ')'					{}
			| _NUMBER_								{
													$$.comp = make_comp( num, NULL, NULL );
													/* change to accomodate floats */
													$$.comp->attr.ival = $1;
												}
			| '(' expression ')'							{}
			| _NOT_ factor								{}
			;

sign			: '+'									{ 	$$ = '+'; }
		 	| '-'									{ 	$$ = '-'; }
			;

%%

void yyerror( char *s ) {
	fprintf( stderr, "%s\n", s );
}
int main( void ) {
	s_stack = push_scope( s_stack );
	yyparse( );
	s_stack = pop_scope( s_stack );
	return 0;
}

