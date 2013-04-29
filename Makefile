# Andrew C. Bodine
# Compilers - Dragon
# module: make

OBJS = y.tab.o lex.yy.o
CC = gcc
LEX = lex
YACC = yacc
YFLAGS = -v -d
CFLAGS = -c -d -g -Wall
LFLAGS = -Wall -lfl

all: $(OBJS)
	$(CC) -o dragon $(OBJS) $(LFLAGS)

y.tab.o: y.tab.c y.tab.h
	$(CC) $(CFLAGS) y.tab.c

y.tab.c y.tab.h: dragon.y
	$(YACC) $(YFLAGS) dragon.y

lex.yy.o: lex.yy.c y.tab.h
	$(CC) $(CFLAGS) lex.yy.c

lex.yy.c: dragon.l
	$(LEX) -d dragon.l

clean:
	rm -rf *.o lex.yy.c *.tab.* dragon *.output
