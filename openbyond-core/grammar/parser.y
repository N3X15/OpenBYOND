/*
OpenBYOND DMScript Bison Syntax

Originally written for DreamCatcher by nan0desu.

Slowly being turned into a fully-fledged DM interpreter.
*/

%token AS 
%token DECREMENT 
%token DEDENT
%token EQUAL 
%token EXPONENT 
%token GEQUAL 
%token IDENTIFIER
%token IN 
%token INCREMENT 
%token INDENT
%token LAND 
%token LEQUAL 
%token LOR 
%token LSHIFT 
%token NEQUAL 
%token NEWLINE 
%token NUMBER
%token OPERATOR 
%token PROC
%token RSHIFT 
%token STRING 
%token VAR

%left '+' '-'
%left '*' '/'
%nonassoc UMINUS
%nonassoc '(' ')'

%union {
	char* strval;
}

%type <strval> IDENTIFIER;

%{

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "parser.tab.h"

/* Here be dragons, and the type tree that'll eventually be replaced. */

struct Typelist {
	void* contents;
	void* next;
} typedef Typelist;

struct Type {
	char* name;
	Typelist* children;
	void* parent;
} typedef Type;

Type root;
Type* current;

Type* addType(char *name) {
	Type* ret = (Type*)malloc(sizeof(Type));
	ret->name = name;
	ret->children = NULL;
	ret->parent = current;
	
	if(current->children == NULL) {
		current->children = (Typelist*)malloc(sizeof(Typelist));
		current->children->next = NULL;
		current->children->contents = ret;
	} else {
	
		Typelist* it = current->children;
		while(it->next != NULL)
		{
			it = (Typelist*) it->next;
		}
	
		it->next = malloc(sizeof(Typelist));
		it = (Typelist*) it->next;
		it->next = NULL;
		it->contents = ret;
	}
	
	return ret;
};

void printTypes(Type* base, int depth) {
	int i = 0;
	for(i = 0; i < depth; i++) {printf("\t");}
	printf("%s\n", base->name);
	
	Typelist* it = base->children;
	while(it != NULL) {
		printTypes((Type*) it->contents, depth + 1);
		it = (Typelist*) it->next;
	}
}

//extern "C" int yylex();

%}

%error-verbose

%%

definitions: definition definitions 
	| vardef definitions 
	| atomdef definitions
	| procdef definitions
	|

vardef:   var_start INDENT variables DEDENT             {current = (Type*) current->parent;}
	| var_start '/' variable                        {current = (Type*) current->parent;}
	
procdef:  atomdecl '(' arguments ')' INDENT	
	
atomdef:  atomdecl INDENT                               {current = (Type*) current->parent;}
	| defname INDENT                                {current = (Type*) current->parent;}
	| DEDENT defname                                {current = (Type*) current->parent;}
	| INDENT defname                                {current = (Type*) current->parent;}
	
atomdecl: '/' defname                                   {current = (Type*) current->parent;}

defname: IDENTIFIER                                     {current = addType($1);}

definition: defname newlines definition_contents        {current = (Type*) current->parent;}
	| defname '/' definition                        {current = (Type*) current->parent;}
	| defname '/' vardef                            {current = (Type*) current->parent;}
		
definition_contents: INDENT definitions DEDENT opt_newlines
	|
		
var_start: VAR                                          {current = addType("var");}

arguments: variable                                     {current = (Type*) current->parent;}
	| variable ',' arguments                        {current = (Type*) current->parent;}
	|

variables: variable variables |

varname: IDENTIFIER                                     {current = addType($1);}
variable: varname newlines variable_contents            {current = (Type*) current->parent;}
		| varname '/' variable                  {current = (Type*) current->parent;}
		| varname '=' const_expression newlines {current = (Type*) current->parent;}
		
variable_contents: INDENT variables DEDENT |

const_expression: NUMBER | STRING | '(' const_expression ')' |
		const_expression '+' const_expression |
		const_expression '-' const_expression |
		const_expression '*' const_expression |
		const_expression '/' const_expression |
		'-' const_expression %prec UMINUS
		
opt_newlines : newlines |		
newlines: NEWLINE newlines | NEWLINE
%%

#include <stdio.h>

int main() {
	current = &root;
	current->name = "root";
	current->children = NULL;
	current->parent = current;
	yyparse();
	printf("\nOpenBYOND DM Test Parser\n");
	printTypes(&root, 0);
}
