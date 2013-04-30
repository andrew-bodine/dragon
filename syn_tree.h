/* Andrew C. Bodine
 * Compilers - Dragon
 * module: syntax tree
 */
#ifndef SYN_TREE_H
#define SYN_TREE_H

/* includes */
#include <stdlib.h>
#include <assert.h>
#include "sym_table.h"
#include <stdio.h>	// remove

/* enums */

/* structs */
typedef struct ident_n {		/* tree node: ident */
	t_entry *e_ptr;			// symbol table entry
	struct ident_n *n_ident;	// next ident node
} ident_n;
typedef struct program_n {		/* tree node: program */
	ident_n *p_symbol;		// program symbol
	ident_n *p_ilist;		// input arguments
	ident_n *p_declarations;	// declarations
	//
} program_n;

/* unions */
typedef union {
	ident_n *ident;
} n_ptr;

/* prototypes */
ident_n *make_ident( t_entry *e_ptr, ident_n *n_ident );	/* constructor: ident */
void free_ident( ident_n *ptr );				/* destructor: ident(s) */
void print_ident( ident_n *ptr );				/* print helper: ident(s) */

#endif /* syn_tree.h */
