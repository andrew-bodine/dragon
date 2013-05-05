/* Andrew C. Bodine
 * Compilers - Dragon
 * module: symbol table
 */

#ifndef SYM_TABLE_H
#define SYM_TABLE_H


/* struct declarations */
typedef struct i_rinfo i_rinfo;
typedef struct r_rinfo r_rinfo;
typedef struct a_rinfo a_rinfo;
typedef struct f_rinfo f_rinfo;
typedef struct p_rinfo p_rinfo;
typedef struct r_ptr r_ptr;
typedef struct t_entry t_entry;
typedef struct s_table s_table;


/* includes */
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "y.tab.h"
#include "syn_tree.h"


/* constants */
#define TABLE_SIZE 211


/* struct declarations */
typedef struct i_rinfo {				/* type integer: record info */
	int e_init;				// entry initialized state ( 0: false, 1: true )
	int e_value;				// TODO: pointer to activation record
} i_rinfo;

typedef struct r_rinfo {				/* type real: record info */
	int e_init;				// entry initialized state ( 0: false, 1: true )
	float e_value;				// TODO: pointer to activation record
} r_rinfo;

typedef struct a_rinfo {				/* type array: record info */
	int a_type;				// type of array members ( integer | real )
	int a_size;				// number of elements in array
	union {
		int *i_ptr;
		float *r_ptr;
	} e_value;				// TODO: pointer to activation record
} a_rinfo;

typedef struct f_rinfo {				/* type function: record info */
	int r_type;				// function return type
	union {
		int ival;
		float fval;
	} rec;					// recursion value container
	ident_n *a_ptr;				// function arguments
} f_rinfo;

typedef struct p_rinfo {				/* type procedure: record info */
	ident_n *a_ptr;				// function arguments
} p_rinfo;

typedef struct r_ptr {					// generic record accessor for symbol table entry
	int e_rtype;				/* entry info record type */
	union {
		i_rinfo *i_info;
		r_rinfo *r_info;
		a_rinfo *a_info;
		f_rinfo *f_info;
		p_rinfo *p_info;
	} record;
} r_ptr;

typedef struct t_entry {				/* symbol table entry */
	char *e_symbol;				// entry name
	r_ptr *e_record;			// entry record structure
	struct t_entry *n_entry;		// neighbor entry ( collisions )
} t_entry;

typedef struct s_table {				/* scope */
	t_entry *s_entries[ TABLE_SIZE ];	// symbol table
	struct s_table *e_scope;		// enclosing scope
} s_table;


/* function prototypes */
r_ptr *make_integer_record( );						/* allocates record struct for type : integer */

r_ptr *make_real_record( );						/* allocates record struct for type : real */

r_ptr *make_array_record( r_ptr *temp, int a_start, int a_stop );	/* allocates record struct for type : array */

r_ptr *make_function_record( int r_type, ident_n *a_ptr );		/* allocates record struct for type : function */

r_ptr *make_procedure_record( ident_n *a_ptr );				/* allocates record struct for type : procedure */

void free_record( r_ptr *ptr );						/* destructor for records of all types */

void install_program_record( t_entry *ptr );				/* installs a program record in given table entry */

void install_unknown_record( t_entry *ptr );				/* installs a record for input args to the program */

void install_entry_record( t_entry *ptr, r_ptr *record );		/* install record in given symbol table entry */

void free_entry( t_entry *ptr );					/* destructor for symbol table entries */
	
t_entry *insert_entry( s_table *s_stack, char *e_symbol );		/* inserts new symbol in symbol table, record pointer is set to NULL */

t_entry *find_entry( s_table *s_stack, char *e_symbol );		/* searches for symbol in all levels of symbol table stack, returns NULL if not found */

s_table *push_scope( s_table *s_stack );				/* pushes a new symbol table on the stack for a new scope */

s_table *pop_scope( s_table *s_stack );					/* pops the top symbol table off of the stack and frees the popped scope & entries */

int hash_pjw( const void *t_key, int t_size );				/* the infamous Peter J. Weinburg hashing function, cheers to you my friend */

char *type_to_str( t_entry *ptr );					/* converts enum record type values to comparable string values for printing */

void print_sstack( s_table *s_stack );					/* prints all contents of symbol table stack */


#endif /* sym_table.h */
