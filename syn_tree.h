/* Andrew C. Bodine
 * Compilers - Dragon
 * module: syntax tree
 */
 
#ifndef SYN_TREE_H
#define SYN_TREE_H


/* includes */
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include "sym_table.h"


/* enums */
typedef enum {
	inum, rnum, assignop, ident, addop, waddop, mulop, wmulop, relop
} c_type;


/* structs */
typedef struct ident_n {			/* tree node: ident */
	t_entry *e_ptr;				// symbol table entry
	struct ident_n *n_ident;		// next ident node
} ident_n;

typedef struct comp_n {				/* tree node: statement composition */
	c_type type;				// type of composition node, indicates what union ptr to use
	int index;				// used for arrays ( INIT: -1 )
	int l_not;				// logical not ( INIT 0: false, 1: true )
	int u_minus;				// unary minus ( INIT 0: false, 1: true )
	union {
		int ival;			// INUM
		float rval;			// RNUM
		int oval;			// OP
		char *woval;			// WORD OP
		ident_n *ident;			// IDENT
	} attr;
	struct comp_n *left, *right;		// left and right children
} comp_n;

typedef struct statement_n {			/* tree node: statement */
	comp_n *root;				// root ptr to compositions
	// TODO
	struct statement_n *n_statement;	// mext statement node
} statement_n;

typedef struct program_n {			/* tree node: program */
	ident_n *p_name;			// program name
	ident_n *p_ilist;			// input arguments
	ident_n *p_declarations;		// declarations
	// TODO: sub_programs
	statement_n *p_statements;		// statements
} program_n;


/* unions */
typedef union {					/* plugs into yylval union for tree construction in yacc file */
	program_n *program;
	statement_n *statement;
	comp_n *comp;
	ident_n *ident;
} n_ptr;


/* prototypes */
program_n *make_program( ident_n *p_name, ident_n *i_list );		/* constructor: program */

statement_n *make_statement( comp_n *root, statement_n *n_statement );	/* constructor: statement */

comp_n *make_comp( c_type type, comp_n *left, comp_n *right );		/* constructor: composition */

ident_n *make_ident( t_entry *e_ptr, ident_n *n_ident );		/* constructor: ident */

void free_program( program_n *ptr );					/* destructor: program */

void free_statement( statement_n *ptr );				/* destructor: statement */

void free_comp( comp_n *ptr );						/* destructor: composition */

void free_ident( ident_n *ptr );					/* destructor: ident(s) */

void print_program( program_n *ptr );					/* print helper: program */

void print_statement( statement_n *ptr );				/* print helper: statmenet */

void print_comp( comp_n *ptr, int spaces );				/* print helper: composition */

void print_ident( ident_n *ptr );					/* print helper: ident(s) */


#endif /* syn_tree.h */
