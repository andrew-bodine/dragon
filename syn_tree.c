/* Andrew C. Bodine
 * Compilers - Dragon
 * module: syntax tree
 */

/* includes */
#include "syn_tree.h"

/* definitions */
program_n *make_program( ident_n *p_name, ident_n *i_list ) {
	program_n *ptr;

	/* allocate/assert memory */
	ptr = ( program_n * )malloc( sizeof( program_n ) );
	assert( ptr != NULL );

	/* set program info */
	ptr->p_name = p_name;
	ptr->p_ilist = i_list;
	//ptr->p_declarations = NULL;
	// TODO	

	return ptr;
}
ident_n *make_ident( t_entry *e_ptr, ident_n *n_ident ) {
	ident_n *ptr;
	
	/* allocate/assert memory */
	ptr = ( ident_n * )malloc( sizeof( ident_n ) );
	assert( ptr != NULL );
	
	/* set ident info */
	ptr->e_ptr = e_ptr;
	ptr->n_ident = n_ident;
	
	return ptr;
}
void free_program( program_n *ptr ) {
	free_ident( ptr->p_name );
	free_ident( ptr->p_ilist );
	free_ident( ptr->p_declarations );
	// TODO
	free( ptr );
}
void free_ident( ident_n *ptr ) {
	if( ptr == NULL )
		return;
	else {
		free_ident( ptr->n_ident );
	}
		free( ptr );	
}
void print_program( program_n *ptr ) {
	
	/* program: name */
	fprintf( stderr, "\n" );
	fprintf( stderr, "PROGRAM: \n" );
	fprintf( stderr, "\tNAME: " );
	print_ident( ptr->p_name );

	/* program: input args */
	fprintf( stderr, "\tARGS: " );
	print_ident( ptr->p_ilist );

	/* program: declarations */
	fprintf( stderr, "\tDECS: " );
	if( ptr->p_declarations == NULL )
		fprintf( stderr, "NONE\n" );
	else
		print_ident( ptr->p_declarations );

	fprintf( stderr, "\n" );
}
void print_ident( ident_n *ptr ) {
	while( ptr != NULL ) {
		fprintf( stderr, "[%s]->", ptr->e_ptr->e_symbol );
		ptr = ptr->n_ident;
	}
	fprintf( stderr, "\n" );
}
