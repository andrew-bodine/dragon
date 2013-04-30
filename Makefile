# Andrew C. Bodine
# Compilers - Dragon
# module: make

OBJS = syn_tree.o sym_table.o y.tab.o lex.yy.o
CC = gcc
LEX = lex
LEFLAGS = #-d
YACC = yacc
YFLAGS = -v -d
CFLAGS = -c
LIFLAGS = -lfl

all: $(OBJS)
	$(CC) -o dragon $(OBJS) $(LIFLAGS)

syn_tree.o: syn_tree.c syn_tree.h sym_table.h
	$(CC) $(CFLAGS) syn_tree.c

sym_table.o: sym_table.c sym_table.h
	$(CC) $(CFLAGS) sym_table.c

y.tab.o: y.tab.c y.tab.h
	$(CC) $(CFLAGS) y.tab.c

y.tab.c y.tab.h: dragon.y
	$(YACC) $(YFLAGS) dragon.y

lex.yy.o: lex.yy.c y.tab.h
	$(CC) $(CFLAGS) lex.yy.c

lex.yy.c: dragon.l
	$(LEX) $(LEFLAGS) dragon.l

clean:
	rm -rf *.o lex.yy.c *.tab.* dragon *.output
