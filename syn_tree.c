/* Andrew C. Bodine
 * Compilers - Dragon
 * module: syntax tree
 */

/* includes */
#include "syn_tree.h"

/* definitions */
program_n *make_program( int type, ident_n *p_name, ident_n *i_list ) {
	program_n *ptr;

	/* allocate/assert memory */
	ptr = ( program_n * )malloc( sizeof( program_n ) );
	assert( ptr != NULL );

	/* set program info */
	ptr->type = type;
	ptr->p_name = p_name;
	ptr->p_ilist = i_list;
	ptr->p_declarations = NULL;
	ptr->p_sprograms = NULL;
	ptr->p_statements = NULL;
	ptr->p_nprogram = NULL;

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
comp_n *make_comp( int type, comp_n *left, comp_n *right ) {
	comp_n *ptr;
	
	/* allocate/assert memory */
	ptr = ( comp_n * )malloc( sizeof( comp_n ) );
	assert( ptr != NULL );
	
	/* set composition info */
	ptr->type = type;
	ptr->index = -1;
	ptr->l_not = 0;
	ptr->u_minus = 0;
	ptr->call = 0;
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
	// TODO: need to rework this function for freeing { programs, functions, & procedures }
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
void print_program( program_n *ptr, int spaces ) {
	
	/* program: name */
	fprintf( stderr, "\n" );
	print_spaces( spaces );
	if( ptr->type == _PROGRAM_ ) fprintf( stderr, "PROGRAM: \n" );
	else if( ptr->type == _FUNCTION_ ) fprintf( stderr, "FUNCTION: \n" );
	else if( ptr->type == _PROCEDURE_ ) fprintf( stderr, "PROCEDURE:\n" );
	print_spaces( spaces );
	fprintf( stderr, "\tNAME: " );
	print_ident( ptr->p_name );

	/* program: input args */
	print_spaces( spaces );
	fprintf( stderr, "\tARGS: " );
	if( ptr->p_ilist == NULL )
		fprintf( stderr, "NONE\n" );
	else
		print_ident( ptr->p_ilist );

	/* program: declarations */
	print_spaces( spaces );
	fprintf( stderr, "\tDECS: " );
	if( ptr->p_declarations == NULL )
		fprintf( stderr, "NONE\n" );
	else
		print_ident( ptr->p_declarations );

	/* program: sub programs */
	print_spaces( spaces );
	fprintf( stderr, "\tSPGS: " );
	if( ptr->p_sprograms == NULL )
		fprintf( stderr, "NONE\n" );
	else {
		fprintf( stderr, "\n" );
		print_program( ptr->p_sprograms, spaces+16 );
	}

	/* program: statements */
	print_spaces( spaces );
	fprintf( stderr, "\tSTTS: " );
	if( ptr->p_statements == NULL )
		fprintf( stderr, "NONE\n" );
	else {
		fprintf( stderr, "\n" );
		print_spaces( spaces );
		print_statement( ptr->p_statements, spaces+16 );
	}

	fprintf( stderr, "\n" );
}
void print_statement( statement_n *ptr, int spaces ) {
	while( ptr != NULL ) {
		print_comp( ptr->root, spaces );
		ptr = ptr->n_statement;
	}
}
void print_comp( comp_n *ptr, int spaces ) {
	int i;
	
	if( ptr == NULL ) return;
	
	for( i = 0; i < spaces; i++ )
		fprintf( stderr, " " );
		
	switch( ptr->type ) {
		case _STATEMENT_:
			fprintf( stderr, "\n" );
			print_statement( ptr->attr.statement, spaces+16 );
			break;
		case _ASSIGNOP_:
			fprintf( stderr, "[ASSIGNOP]" );
			break;
		case _RELOP_:
			fprintf( stderr, "[RELOP:%s]", ptr->attr.woval );
			break;
		case _WADDOP_:
			fprintf( stderr, "[ADDOP:%s]", ptr->attr.woval );
			break;
		case _ADDOP_:
			fprintf( stderr, "[ADDOP:%c]", ( char )ptr->attr.ival );
			break;
		case _WMULOP_:
			fprintf( stderr, "[MULOP:%s]", ptr->attr.woval );
			break;
		case _MULOP_:
			fprintf( stderr, "[MULOP:%c]", ( char )ptr->attr.ival );
			break;
		case _INTEGER_:
			fprintf( stderr, "[INUM:%d|%d|%d|%d]", ptr->attr.ival, ptr->index, ptr->l_not, ptr->u_minus );
			break;
		case _REAL_:
			fprintf( stderr, "[RNUM:%f|%d|%d|%d]", ptr->attr.rval, ptr->index, ptr->l_not, ptr->u_minus );
			break;
		case _IDENT_:
			fprintf( stderr, "[IDENT:%s|%d|%d|%d]", ptr->attr.ident->e_ptr->e_symbol, ptr->index, ptr->l_not, ptr->u_minus );
			break;
		case _IF_:
			fprintf( stderr, "[IF]" );
			break;
		case _THEN_:
			fprintf( stderr, "[THEN]" );
			break;
		case _ELSE_:
			fprintf( stderr, "[ELSE]" );
			break;
		case _WHILE_:
			fprintf( stderr, "[WHILE]" );
			break;
		case _DO_:
			fprintf( stderr, "[DO]" );
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
void print_spaces( int spaces ) {
	int i;
	
	for( i = 0; i < spaces; i++ )
		fprintf( stderr, " " );
}
