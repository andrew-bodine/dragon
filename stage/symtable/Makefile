OBJS = test.o sym_table.o
CC = gcc
CFLAGS = -c -Wall
LFLAGS = -Wall

all: $(OBJS)
	$(CC) $(LFLAGS) $(OBJS) -o symtable

test.o: test.c sym_table.h sym_table.c
	$(CC) $(CFLAGS) test.c

sym_table.o: sym_table.c sym_table.h
	$(CC) $(CFLAGS) sym_table.c

clean:
	rm -rf *.o symtable
