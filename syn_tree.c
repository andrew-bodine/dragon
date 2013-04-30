/* Andrew C. Bodine
 * Compilers - Dragon
 * module: syntax tree
 */

/* includes */
#include "syn_tree.h"

/* definitions */
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
void free_ident( ident_n *ptr ) {
	if( ptr == NULL )
		return;
	else {
		free_ident( ptr->n_ident );
	}
		free( ptr );	
}
void print_ident( ident_n *ptr ) {
	while( ptr != NULL ) {
		fprintf( stderr, "[%s]->", ptr->e_ptr->e_symbol );
		ptr = ptr->n_ident;
	}
	fprintf( stderr, "\n" );
}
