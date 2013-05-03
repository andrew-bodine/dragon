/* Andrew C. Bodine
 * Compilers - Dragon
 * module: symbol table
 */


/* includes */
#include "sym_table.h"


/* definitions */
r_ptr *make_integer_record( ) {
	r_ptr *ptr;
	
	ptr = ( r_ptr * )malloc( sizeof( r_ptr ) );
	assert( ptr != NULL );
	ptr->e_rtype = _INTEGER_;
	
	ptr->record.i_info = ( i_rinfo * )malloc( sizeof( i_rinfo ) );
	assert( ptr->record.i_info != NULL );
	ptr->record.i_info->e_init = 0;
	ptr->record.i_info->e_value = 0;
	
	return ptr;
}
r_ptr *make_real_record( ) {
	r_ptr *ptr;
	
	ptr = ( r_ptr * )malloc( sizeof( r_ptr ) );
	assert( ptr != NULL );
	ptr->e_rtype = _REAL_;
	
	ptr->record.r_info = ( r_rinfo * )malloc( sizeof( r_rinfo ) );
	assert( ptr->record.r_info != NULL );
	ptr->record.r_info->e_init = 0;
	ptr->record.r_info->e_value = ( float )0;
	
	return ptr;
}
r_ptr *make_array_record( r_ptr *temp, int a_start, int a_stop ) {
	r_ptr *ptr;
	int i;

	ptr = ( r_ptr * )malloc( sizeof( r_ptr ) );
	assert( ptr != NULL );
	ptr->e_rtype = _ARRAY_;
	
	ptr->record.a_info = ( a_rinfo * )malloc( sizeof( a_rinfo ) );
	assert( ptr->record.a_info != NULL );
	ptr->record.a_info->a_type = temp->e_rtype;
	free_record( temp );
	ptr->record.a_info->a_size = ( a_stop - a_start + 1 );
	
	switch( ptr->record.a_info->a_type ) {
		case _INTEGER_:
			ptr->record.a_info->e_value.i_ptr = ( int * )malloc( sizeof( int ) * ptr->record.a_info->a_size );
			for( i = 0; i < ptr->record.a_info->a_size; i++ ) {
				ptr->record.a_info->e_value.i_ptr[ i ] = a_start;
				a_start++;
			}
			break;
		case _REAL_:
			ptr->record.a_info->e_value.r_ptr = ( float * )malloc( sizeof( float ) * ptr->record.a_info->a_size );
			for( i = 0; i < ptr->record.a_info->a_size; i++ ) {
				ptr->record.a_info->e_value.r_ptr[ i ] = ( float )a_start;
				a_start++;
			}
			break;	
		default:
			fprintf( stderr, "unsupported array type\n" );
			break;
	}
	
	return ptr;
}
void free_record( r_ptr *ptr ) {
	if( ptr == NULL ) return;
	switch( ptr->e_rtype ) {
			case _INTEGER_:
				free( ptr->record.i_info );
				break;
			case _REAL_:
				free( ptr->record.r_info );
				break;
			//TODO
			case _ARRAY_:
				if( ptr->record.a_info->a_type == _INTEGER_ )
					free( ptr->record.a_info->e_value.i_ptr );
				else
					free( ptr->record.a_info->e_value.r_ptr );
				free( ptr->record.a_info );
				break;
			case _FUNCTION_:
				break;
			case _PROCEDURE_:
				break;
			default:
				break;
		}
	free( ptr );
}
void install_program_record( t_entry *ptr ) {
	r_ptr *rptr;
	
	rptr = ( r_ptr * )malloc( sizeof( r_ptr ) );
	assert( rptr != NULL );
	rptr->e_rtype = _PROGRAM_;
	ptr->e_record = rptr;
}
void install_unknown_record( t_entry *ptr ) {
	r_ptr *rptr;
	
	rptr = ( r_ptr * )malloc( sizeof( r_ptr ) );
	assert( rptr != NULL );
	rptr->e_rtype = _IDENT_;
	ptr->e_record = rptr;
}
void install_entry_record( t_entry *ptr, r_ptr *record ) {
	ptr->e_record = record;
}
void free_entry( t_entry *ptr ) {
	if( ptr == NULL )
		return;
	else {
		free_entry( ptr->n_entry );
		free( ptr->e_symbol );
		free_record( ptr->e_record );
		free( ptr );
	}
}
t_entry *insert_entry( s_table *s_stack, char *e_symbol ) {
	t_entry *ptr;
	int index;

	/* assert s_stack */
	assert( s_stack != NULL );

	/* allocate/assert memory */
	ptr = ( t_entry * )malloc( sizeof( t_entry ) );
	assert( ptr != NULL );

	/* set/initialize entry info */
	ptr->e_symbol = strdup( e_symbol );
	free( e_symbol );
	ptr->e_record = NULL;
	ptr->n_entry = NULL;

	/* insert */
	index = hash_pjw( ptr->e_symbol, TABLE_SIZE );
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
char *type_to_str( t_entry *ptr ) {
	if( ptr->e_record == NULL ) return "NULL";
	switch( ptr->e_record->e_rtype ) {
		case _IDENT_:
			return "UNKN";
		case _PROGRAM_:
			return "PROG";
		case _INTEGER_:
			return "INT";
		case _REAL_:
			return "REAL";
		case _ARRAY_:
			return "ARRAY";
		case _FUNCTION_:
			return "FUNC";
		case _PROCEDURE_:
			return "PROC";
		default:
			return "";
	}
}
void print_sstack( s_table *s_stack ) {
	t_entry *ptr;
	int i;

	fprintf( stderr, "SYMBOL TABLE(S)\n---------------------------------------\n" );
	if( s_stack == NULL ) return;
	else {
		while( s_stack != NULL ) {
			for( i = 0; i < TABLE_SIZE; i++ ) {
				if( s_stack->s_entries[ i ] != NULL ) {
					ptr = s_stack->s_entries[ i ];
					while( ptr != NULL ) {
						fprintf( stderr, "[%s|%s", ptr->e_symbol, type_to_str( ptr ) );
						switch( ptr->e_record->e_rtype ) {
							case _INTEGER_:
								fprintf( stderr, "|%d]->", ptr->e_record->record.i_info->e_init );
								break;
							case _REAL_:
								fprintf( stderr, "|%d]->", ptr->e_record->record.r_info->e_init );
								break;
							case _ARRAY_:
								if( ptr->e_record->record.a_info->a_type == _INTEGER_ ) {
									fprintf( stderr, "|%d|%d|%d]->", ptr->e_record->record.a_info->a_size,
										ptr->e_record->record.a_info->e_value.i_ptr[ 0 ],
										ptr->e_record->record.a_info->e_value.i_ptr[ ptr->e_record->record.a_info->a_size - 1 ] );
								}
								else if( ptr->e_record->record.a_info->a_type == _REAL_ ) {
									fprintf( stderr, "|%d|%d|%d]->", ptr->e_record->record.a_info->a_size,
										ptr->e_record->record.a_info->e_value.r_ptr[ 0 ],
										ptr->e_record->record.a_info->e_value.r_ptr[ ptr->e_record->record.a_info->a_size - 1 ] );
								}
								else {
									fprintf( stderr, "unrecognized array type in symbol table\n" );
								}
								break;
							// TODO
							default:
								fprintf( stderr, "]->" );
						}
						ptr = ptr->n_entry;
					}
					fprintf( stderr, "\n" );
				}
			}
			s_stack = s_stack->e_scope;
		}
		fprintf( stderr, "---------------------------------------\n" );
	}
}
