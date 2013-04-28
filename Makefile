# Andrew C. Bodine
# Compilers - Dragon
# module: make

OBJS = lex.yy.o
CC = gcc
LEX = lex
YACC = yacc
YFLAGS = -v -d
CFLAGS = -c -g -Wall
LFLAGS = -Wall -lfl

all: $(OBJS)
	$(CC) -o dragon $(OBJS) $(LFLAGS)

lex.yy.o: lex.yy.c
	$(CC) $(CFLAGS) lex.yy.c

lex.yy.c: dragon.l
	$(LEX) dragon.l

clean:
	rm -rf *.o lex.yy.c *.tab.* dragon *.output
