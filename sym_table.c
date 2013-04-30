/* Andrew C. Bodine
 * Compilers - Dragon
 * module: symbol table
 */

/* includes */
#include "sym_table.h"

/* definitions */
int hash_pjw( const void *t_key, int t_size ) {
	const char *ptr = t_key;
	int val = 0;

	while( *ptr != '\0' ) {
		int tmp;
		val = ( ( val << 4 ) + ( *ptr ) );
		if( ( tmp = ( val & 0xf0000000 ) ) ) {
			val = val ^ ( tmp >> 24 );
			val = val ^ tmp;
		}
		ptr++;
	}
	return val % t_size;
}
t_entry *insert_entry( s_table *s_stack, char *e_symbol, r_type e_rtype ) {
	t_entry *ptr;
	int index;

	/* assert s_stack */
	assert( s_stack != NULL );

	/* allocate/assert memory */
	ptr = ( t_entry * )malloc( sizeof( t_entry ) );
	assert( ptr != NULL );

	/* set entry info */
	ptr->e_symbol = strdup( e_symbol );
	ptr->e_rtype = e_rtype;
	ptr->n_entry = NULL;

	/* allocate/assert/set entry record info */
	switch( e_rtype ) {
		case integer:
			ptr->e_record.i_info = ( i_rinfo * )malloc( sizeof( i_rinfo ) );
			assert( ptr->e_record.i_info != NULL );
			ptr->e_record.i_info->e_init = 0;
			break;
		case real:
			ptr->e_record.r_info = ( r_rinfo * )malloc( sizeof( r_rinfo ) );
			assert( ptr->e_record.r_info != NULL );
			ptr->e_record.r_info->e_init = 0;
			break;
		case array:
			break;
		case function:
			break;
		case procedure:
			break;
		default:
			break;
	}

	/* insert */
	index = hash_pjw( e_symbol, TABLE_SIZE );
	if( s_stack->s_entries[ index ] == NULL )
		s_stack->s_entries[ index ] = ptr;
	else {
		ptr->n_entry = s_stack->s_entries[ index ];
		s_stack->s_entries[ index ] = ptr;
	}

	return ptr;
}
t_entry *find_entry( s_table *s_stack, char *e_symbol ) {
	t_entry *ptr;
	int index;

	/* compute index for lookup */
	index = hash_pjw( e_symbol, TABLE_SIZE );

	while( s_stack != NULL ) {
		if( s_stack->s_entries[ index ] != NULL ) {
			ptr = s_stack->s_entries[ index ];
			while( ptr != NULL ) {
				if( strncmp( e_symbol, ptr->e_symbol, strlen( e_symbol ) ) == 0 )
					return ptr;
				ptr = ptr->n_entry;
			}
		}
		s_stack = s_stack->e_scope;
	}
	return NULL;
}
void free_entry( t_entry *ptr ) {
	if( ptr == NULL )
		return;
	else {
		free_entry( ptr->n_entry );
		free( ptr->e_symbol );
		switch( ptr->e_rtype ) {
			case integer:
				free( ptr->e_record.i_info );
				break;
			case real:
				free( ptr->e_record.r_info );
				break;
			case array:
				break;
			case function:
				break;
			case procedure:
				break;
			default:
				break;
		}
		free( ptr );
	}
}
s_table *push_scope( s_table *s_stack ) {
	s_table *ptr;
	int i;

	/* allocate/assert memory */
	ptr = ( s_table * )malloc( sizeof( s_table ) );
	assert( ptr != NULL );

	/* null out table ( safety ) */
	for( i = 0; i < TABLE_SIZE; i++ )
		ptr->s_entries[ i ] = NULL;

	/* set info */
	ptr->e_scope = ( s_stack == NULL ) ? NULL: s_stack;

	return ptr;
}
s_table *pop_scope( s_table *s_stack ) {
	s_table *ptr;
	int i;

	if( s_stack == NULL )
		return NULL;
	else {
		ptr = s_stack->e_scope;

		/* free memory */
		for( i = 0; i < TABLE_SIZE; i++ ) {
			if( s_stack->s_entries[ i ] != NULL )
				free_entry( s_stack->s_entries[ i ] );
		}
		free( s_stack );

		return ptr;
	}
}