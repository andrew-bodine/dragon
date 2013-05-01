/* Andrew C. Bodine
 * Compilers - Dragon
 * module: symbol table
 */

#ifndef SYM_TABLE_H
#define SYM_TABLE_H

/* includes */
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>

/* constants */
#define TABLE_SIZE 211

/* enums */
typedef enum {					/* symbol table entry record type */
	unknown,
	program, integer, real, 
	array, function, procedure
} r_type;					

/* structs */
typedef struct i_rinfo {			/* integer record info */
	int e_init;				// entry initialized state ( 0: false, 1: true )
	// TODO
} i_rinfo;
typedef struct r_rinfo {			/* real record info */
	int e_init;				// entry initialized state ( 0: false, 1: true )
	// TODO
} r_rinfo;
// TODO
typedef struct t_entry {			/* symbol table entry */
	char *e_symbol;				// entry name
	r_type e_rtype;				// entry info record type
	union {
		i_rinfo *i_info;
		r_rinfo *r_info;
		// TODO
	} e_record;				// entry specific information
	struct t_entry *n_entry;		// neighbor entry ( collisions )
} t_entry;
typedef struct s_table {			/* scope */
	t_entry *s_entries[ TABLE_SIZE ];	// symbol table
	struct s_table *e_scope;		// enclosing scope
} s_table;

/* prototypes */
int hash_pjw( const void *t_key, int t_size );
t_entry *insert_entry( s_table *s_stack, char *e_symbol, r_type e_rtype );
t_entry *find_entry( s_table *s_stack, char *e_symbol );
void free_entry( t_entry *ptr );
s_table *push_scope( s_table *s_stack );
s_table *pop_scope( s_table *s_stack );
char *type_to_str( t_entry *ptr );
void print_sstack( s_table *s_stack );

#endif /* sym_table.h */
