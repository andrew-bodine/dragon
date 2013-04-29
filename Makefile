# Andrew C. Bodine
# Compilers - Dragon
# module: make

OBJS = y.tab.o lex.yy.o
CC = gcc
LEX = lex
LEFLAGS = -d
YACC = yacc
YFLAGS = -d
CFLAGS = -c
LIFLAGS = -lfl

all: $(OBJS)
	$(CC) -o dragon $(OBJS) $(LIFLAGS)

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
