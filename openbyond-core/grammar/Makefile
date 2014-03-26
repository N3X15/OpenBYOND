.PHONY : all clean lex test

all : test
lex : lexer

test: testapp
	./test < test.dm

testapp : lex.yy.c parser.tab.c
	gcc -o test parser.tab.c lex.yy.c
	
lexer : lex.yy.c parser.tab.h
	gcc -o dreamlex lex.yy.c

lex.yy.c : tokens.l
	flex -d tokens.l

parser.tab.c : parser.y
	bison -dv parser.y
	
parser.tab.h : parser.y
	bison -dv -r=solved parser.y

clean:
	rm test lex.yy.c parser.tab.c parser.tab.h parser.output
