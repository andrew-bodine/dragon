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

/* structs */
typedef struct ident_n {		/* tree node: ident */
	t_entry *e_ptr;			// symbol table entry
	struct ident_n *n_ident;	// next ident node
} ident_n;

typedef struct program_n {		/* tree node: program */
	ident_n *p_name;		// program name
	ident_n *p_ilist;		// input arguments
	//ident_n *p_declarations;	// declarations
	// TODO
} program_n;

/* unions */
typedef union {				/* plugs into yylval union for tree construction in yacc file */
	program_n *program;
	ident_n *ident;
} n_ptr;

/* prototypes */
program_n *make_program( ident_n *p_name, ident_n *i_list );	/* constructor: program */
ident_n *make_ident( t_entry *e_ptr, ident_n *n_ident );	/* constructor: ident */
void free_program( program_n *ptr );				/* destructor: program */
void free_ident( ident_n *ptr );				/* destructor: ident(s) */
void print_program( program_n *ptr );				/* print helper: program */
void print_ident( ident_n *ptr );				/* print helper: ident(s) */

#endif /* syn_tree.h */
