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
	ptr->p_declarations = NULL;
	// TODO
	ptr->p_statements = NULL;

	return ptr;
}
statement_n *make_statement( comp_n *root, statement_n *n_statement ) {
	statement_n *ptr;
	
	/* allocate/assert memory */
	ptr = ( statement_n * )malloc( sizeof( statement_n ) );
	assert( ptr != NULL );
	
	/* set statement info */
	ptr->root = root;
	ptr->n_statement = n_statement;
	
	return ptr;
}
comp_n *make_comp( c_type type, comp_n *left, comp_n *right ) {
	comp_n *ptr;
	
	/* allocate/assert memory */
	ptr = ( comp_n * )malloc( sizeof( comp_n ) );
	assert( ptr != NULL );
	
	/* set composition info */
	ptr->type = type;
	ptr->left = left;
	ptr->right = right;
	
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
	if( ptr->p_declarations != NULL )
		free_ident( ptr->p_declarations );
	// TODO
	free( ptr );
}
void free_statement( statement_n *ptr ) {
	// TODO
	if( ptr->n_statement != NULL )
		free_statement( ptr->n_statement );
	if( ptr != NULL ) {
		free_comp( ptr->root );
		free( ptr );
	}
}
void free_comp( comp_n *ptr ) {
	// TODO: need more cases once we start supporting nested comps
	if( ptr->left != NULL )
		free_comp( ptr->left );
	if( ptr->right != NULL )
		free_comp( ptr->right );
	free( ptr );
}
void free_ident( ident_n *ptr ) {
	if( ptr->n_ident != NULL )
		free_ident( ptr->n_ident );
	if( ptr != NULL )
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

	/* program: statements */
	fprintf( stderr, "\tSTTS: \n" );
	if( ptr->p_statements == NULL )
		fprintf( stderr, "NONE\n" );
	else
		print_statement( ptr->p_statements );

	fprintf( stderr, "\n" );
}
void print_statement( statement_n *ptr ) {
	while( ptr != NULL ) {
		print_comp( ptr->root, 16 );
		ptr = ptr->n_statement;
	}
}
void print_comp( comp_n *ptr, int spaces ) {
	int i;
	
	if( ptr == NULL ) return;
	
	for( i = 0; i < spaces; i++ )
		fprintf( stderr, " " );
		
	switch( ptr->type ) {
		case assignop:
			fprintf( stderr, "[ASSIGNOP]" );
			break;
		case inum:
			fprintf( stderr, "[INUM:%d]", ptr->attr.ival );
			break;
		case rnum:
			fprintf( stderr, "[RNUM:%f]", ptr->attr.rval );
			break;
		case ident:
			fprintf( stderr, "[IDENT:%s]", ptr->attr.ident->e_ptr->e_symbol );
			break;
		default:
			fprintf( stderr, "[UNKNOWN]" );
			break;
	}
	fprintf( stderr, "\n" );
	
	print_comp( ptr->left, spaces + 4 );
	print_comp( ptr->right, spaces + 4 );
}
void print_ident( ident_n *ptr ) {
	while( ptr != NULL ) {
		fprintf( stderr, "[%s]->", ptr->e_ptr->e_symbol );
		ptr = ptr->n_ident;
	}
	fprintf( stderr, "\n" );
}
