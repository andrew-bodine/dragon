OBJS = test.o syn_tree.o
CC = gcc
CFLAGS = -c -Wall
LFLAGS = -Wall

all: $(OBJS)
	$(CC) $(LFLAGS) $(OBJS) -o syntree

test.o: test.c syn_tree.h syn_tree.c
	$(CC) $(CFLAGS) test.c

syn_tree.o: syn_tree.c syn_tree.h
	$(CC) $(CFLAGS) syn_tree.c

clean:
	rm -rf *.o syntree
