#include "sym_table.h"
#include <stdio.h>

int main( void ) {
	s_table *stack = NULL;

	stack = push_scope( stack );
	insert_entry( stack, "foobar", integer );
	insert_entry( stack, "raboof", integer );
	if( find_entry( stack, "asd" ) != NULL )
		fprintf( stderr, "found: %s\n", "asd" );
	else
		fprintf( stderr, "didn't find: %s\n", "asd" );
	stack = pop_scope( stack );

	return 0;
}
