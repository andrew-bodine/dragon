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


%code requires {
	#include "syn_tree.h"
	#include "sym_table.h"
}


/* yylval union */
%union {
	int ival;	/* integer number */
	float rval;	/* real number */
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
%token _STATEMENT_	/* starts a statement */
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
%token <sval> _RELOP_	/*
				=  : equal
				<> : not-equal
				<  : less-than
				<= : less-or-equal
				>  : greater-than
				>= : greater-or-equal
			*/
%token <ival> _ADDOP_	/* 
				+  : addition for both integer and real arguments
				-  : subtraction for both integer and real arguments	
			*/
%token <sval> _WADDOP_	/* or : logical OR */
%token <ival> _MULOP_	/* 
				*   : multiplication for both integer and real arguments
				/   : division for both integer and real arguments
			*/
%token <sval> _WMULOP_ 	/*
				div : quotient in integer division
				mod : remainder in integer division
				and : logical AND
			*/
%token _ASSIGNOP_	/* := */
%token <sval> _IDENT_
%token <ival> _INUMBER_	/* matches unsigned integers */
%token <rval> _RNUMBER_ /* matches floats */


/* precedence */
%nonassoc _IF_THEN_
%nonassoc _ELSE_


/* types */
%type <tval> program identifier_list declarations compound_statement subprogram_declarations subprogram_declaration subprogram_head
%type <tval> optional_statements statement_list statement variable expression simple_expression term factor parameter_list arguments
%type <record> type standard_type


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
													t_ptr.program = make_program( _PROGRAM_, make_ident( e_ptr, NULL ), $4.ident );
													
													/* add declarations */
													t_ptr.program->p_declarations = $7.ident;
													
													/* add sub programs */
													t_ptr.program->p_sprograms = $8.program;
													
													/* add statements */
													t_ptr.program->p_statements = $9.statement;
												}			  
			  '.'									{	
													print_program( t_ptr.program, 0 );
													print_sstack( s_stack );
													free_program( t_ptr.program );
												}
			| /* epsilon */								{	/* empty file .: nothing to do */ }
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

	   		| _ARRAY_ '[' _INUMBER_ _SPAN_ _INUMBER_ ']' _OF_ standard_type		{	$$ = make_array_record( $8, $3, $5 ); }
			;

standard_type		: _INTEGER_								{	$$ = make_integer_record( ); }

			| _REAL_								{	$$ = make_real_record( ); }
			;

subprogram_declarations	: subprogram_declaration ';' subprogram_declarations			{	
													$$.program = $1.program;
													$$.program->p_nprogram = $3.program;
												}

			| /* epsilon */								{	$$.program = NULL; }
			;

subprogram_declaration	: subprogram_head
			  declarations
			  subprogram_declarations
			  compound_statement							{	
			  										$$.program = $1.program;
			  										if( $$.program != NULL ) {
			  											$$.program->p_declarations = $2.ident;
			  											$$.program->p_sprograms = $3.program;
			  											$$.program->p_statements = $4.statement;
			  										}
			  									}
			;

subprogram_head		: _FUNCTION_ _IDENT_ arguments ':' standard_type ';'			{
													e_ptr = find_entry( s_stack, $2 );
													if( e_ptr != NULL ) {
														fprintf( stderr, "ERROR: declaring a function with previously declared symbol\n" );
														exit( -1 );
													}
													e_ptr = insert_entry( s_stack, $2 );
													install_entry_record( e_ptr, make_function_record( $5->e_rtype, $3.ident ) );
													$$.program = make_program( _FUNCTION_, make_ident( e_ptr, NULL ), $3.ident );
												}

			| _PROCEDURE_ _IDENT_ arguments ';'					{
													$$.program = NULL;
/*													e_ptr = find_entry( s_stack, $2 );*/
/*													if( e_ptr != NULL ) {*/
/*														fprintf( stderr, "ERROR: declaring a procedure with previously declared symbol\n" );*/
/*													}*/
/*													e_ptr = insert_entry( s_stack, $2 );*/
/*													install_entry_record( e_ptr, make_procedure_record( $3.ident ) );*/
/*													$$.program = make_program( _PROCEDURE_, make_ident( e_ptr, NULL ), $3.ident );*/
												}
			;

arguments		: '(' parameter_list ')'						{	$$.ident = $2.ident; }

			| /* epsilon */								{	$$.ident = NULL; }
			;

parameter_list		: identifier_list ':' type						{
													$$.ident = $1.ident;
													t_ptr.ident = $$.ident;
													while( 1 ) {
														
														/* free temporary record installed previously */
														//free_record( t_ptr.ident->e_ptr->e_record );
														
														install_entry_record( t_ptr.ident->e_ptr, $3 );
														if( t_ptr.ident->n_ident != NULL )
															t_ptr.ident = t_ptr.ident->n_ident;
														else
															break;
													}
												}

			| identifier_list ':' type ';' parameter_list				{
													$$.ident = $1.ident;
													t_ptr.ident = $$.ident;
													while( 1 ) {
														
														/* free temporary record installed previously */
														free_record( t_ptr.ident->e_ptr->e_record );
														
														install_entry_record( t_ptr.ident->e_ptr, $3 );
														if( t_ptr.ident->n_ident != NULL )
															t_ptr.ident = t_ptr.ident->n_ident;
														else
															break;
													}
													t_ptr.ident->n_ident = $5.ident;
												}
			;

compound_statement	: _BEGIN_ optional_statements _END_					{	$$.statement = $2.statement; }
			;

optional_statements	: statement_list							{	$$.statement = $1.statement; }

			| /* epsilon */								{	$$.statement = NULL; }
			;

statement_list		: statement								{	$$.statement = make_statement( $1.comp, NULL ); }

			| statement ';' statement_list						{	$$.statement = make_statement( $1.comp, $3.statement ); }
			;

statement		: variable _ASSIGNOP_ expression					{	$$.comp = make_comp( _ASSIGNOP_, $1.comp, $3.comp ); }

			| procedure_statement							{}

			| compound_statement							{
													$$.comp = make_comp( _STATEMENT_, NULL, NULL );
													$$.comp->attr.statement = $1.statement;
												}

			| _IF_ expression _THEN_ statement %prec _IF_THEN_			{
													$$.comp = make_comp( _IF_, $2.comp,
														make_comp( _THEN_, $4.comp , NULL ) );
												}

			| _IF_ expression _THEN_ statement _ELSE_ statement			{	$$.comp = make_comp( _IF_, $2.comp,
														make_comp( _THEN_, $4.comp,
														make_comp( _ELSE_, $6.comp, NULL ) ) );
												}

			| _WHILE_ expression _DO_ statement					{	$$.comp = make_comp( _WHILE_, $2.comp,
														make_comp( _DO_, $4.comp, NULL ) ); }
			;

variable		: _IDENT_								{	
													e_ptr = find_entry( s_stack, $1 );
													if( e_ptr == NULL ) {
														e_ptr = insert_entry( s_stack, $1 );
														install_unknown_record( e_ptr );
													}
													$$.comp = make_comp( _IDENT_, NULL, NULL );
													$$.comp->attr.ident = make_ident( e_ptr, NULL );
												}

			| _IDENT_ '[' expression ']'						{
													/* need to find symbol in the symbol table */
													e_ptr = find_entry( s_stack, $1 );
													if( e_ptr == NULL ) {
														fprintf( stderr, "ERROR: trying to access an undefined array\n" );
														exit( -1 );
													}
													/* check that symbol is an array */
													else if( e_ptr->e_record->e_rtype != _ARRAY_ ) {
														fprintf( stderr, "ERROR: accessing an element as an array that isn't an array\n" );
														exit( -1 );
													}
													/* check index type against type of array */
													else if( ( e_ptr->e_record->record.a_info->a_type == _INTEGER_ &&
														   $3.comp->type != _INTEGER_ ) || ( $3.comp->type != _REAL_ &&
														   e_ptr->e_record->record.a_info->a_type == _REAL_ ) ) {
														fprintf( stderr, "ERROR: accessing an array with invalid index type\n" );
														exit( -1 );
													}
													/* check index against bounds of array */
													if( $3.comp->type == _INTEGER_ && ( $3.comp->attr.ival < 0 || 
														$3.comp->attr.ival >= e_ptr->e_record->record.a_info->a_size ) ) {
														fprintf( stderr, "ERROR: index out of array bounds\n" );
														exit( -1 );
													}
													else if( $3.comp->type == _REAL_ && ( $3.comp->attr.rval < 0 || 
														$3.comp->attr.rval >= e_ptr->e_record->record.a_info->a_size ) ) {
														fprintf( stderr, "ERROR: index out of array bounds\n" );
														exit( -1 );
													}
													$$.comp = make_comp( _IDENT_, NULL, NULL );
													$$.comp->attr.ident = make_ident( e_ptr, NULL );
													$$.comp->index = $3.comp->attr.ival;
												}
			;

procedure_statement	: _IDENT_								{}

			| _IDENT_ '(' expression_list ')'					{}
			;

expression_list		: expression								{}

			| expression ',' expression_list					{}
			;

expression		: simple_expression							{	$$.comp = $1.comp; }

			| simple_expression _RELOP_ simple_expression				{
													$$.comp = make_comp( _RELOP_, $1.comp, $3.comp );
													$$.comp->attr.woval = $2;
												}
			;

simple_expression	: term									{	$$.comp = $1.comp; }

			| _ADDOP_ term								{	
													$$.comp = $2.comp;
													if( $1 == '-')
														$$.comp->u_minus = 1;
												}

			| simple_expression _WADDOP_ term					{
													$$.comp = make_comp( _WADDOP_, $1.comp, $3.comp );
													$$.comp->attr.woval = $2;
												}

			| simple_expression _ADDOP_ term					{	
													$$.comp = make_comp( _ADDOP_, $1.comp, $3.comp );
													$$.comp->attr.oval = $2;
												}
			;

term			: factor								{	$$.comp = $1.comp; }

		 	| term _MULOP_ factor							{
		 											$$.comp = make_comp( _MULOP_, $1.comp, $3.comp );
		 											$$.comp->attr.oval = $2;
		 										}
		 	| term _WMULOP_ factor							{
		 											$$.comp = make_comp( _WMULOP_, $1.comp, $3.comp );
		 											$$.comp->attr.woval = $2;
		 										}
			;

factor			: variable								{	$$.comp = $1.comp; }

		   	| _IDENT_ '(' expression_list ')'					{}

			| _INUMBER_								{
													$$.comp = make_comp( _INTEGER_, NULL, NULL );
													$$.comp->attr.ival = $1;
												}

			| _RNUMBER_								{
													$$.comp = make_comp( _REAL_, NULL, NULL );
													$$.comp->attr.rval = $1;
												}

			| '(' expression ')'							{	$$.comp = $2.comp; }

			| _NOT_ factor								{	
													$$.comp = $2.comp;
													$$.comp->l_not = 1;
												}
			;
			
%%


void yyerror( char *s ) {
	fprintf( stderr, "%s\n", s );
}

int main( void ) {
	//system( "cat docs/haiku | cowsay -f dragon" );
	s_stack = push_scope( s_stack );
	yyparse( );
	s_stack = pop_scope( s_stack );
	return 0;
}

