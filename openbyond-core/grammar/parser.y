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
%token RETURN
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
%type <strval> defname atompath

%{

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "parser.tab.h"

%}

%error-verbose

%%

definitions
	: /* empty */
	| definition definitions 
	| vardef definitions 
	| atomdef definitions
	| procdecl definitions
	;

vardef
	: var_start INDENT variable_blocks DEDENT       {;}
	| var_start '/' variable                        {;}
	;
	
procdecl
	: atomdecl '/' PROC '/' procdef                 { /* Set child proc to use atomdecl and be declarative */ }
	| PROC '/' procdef                              { /* Proc *whatever = $2; whatever->setDeclarative(true); return whatever */ }
	| PROC INDENT procdefs DEDENT                   { /* Set procs created "below" to declarative. */ }
	;

procdefs
	: procdef 
	| procdefs procdef
	;
procdef
	: defname '(' arguments ')' INDENT procbody DEDENT { /* return current->addProc($1,$3) */ }
	;
	
atomdef
	: atomdecl INDENT                               {;}
	| defname INDENT                                {;}
	;
	
atomdecl
	: '/' atompath                                  { /*return new Atom($2);*/ }
	;
	
atompath
	: defname                                       { $$ = $1; }
	| defname '/' atompath                          { 
		char *o; 
		int size = asprintf(&o, "%s/%s",$1,$3);
		if(size<0) {
			$$ = NULL;
			return;
		} 
		$$ = o;
	}
	;
defname
	: IDENTIFIER                                    { $$ = $1;}
	;

definition
	: defname '/' definition                        {;}
	| defname '/' vardef                            {;}
	;
		
definition_contents
	: /* empty */
	| INDENT definitions DEDENT
	;
		
var_start
	: VAR                                           {;}
	;
	
arguments
	: variable                                      {;}
	| variable ',' arguments                        {;}
	|
	;

variabledefs
	: variable_blocks
	| variables
	;

variables
	: /* empty */
	| variable variables
	;

variable_blocks
	: variable_block variable_blocks
	;

varname 
	: IDENTIFIER                                    {;}
	;
	
variable_block
	: varname INDENT variable_contents DEDENT       {;}
	;
	
variable
	: atompath                                      {;}
	| atompath '=' const_expression                 {;}
	| var_start '/' variable                        {;}
	;
	
variable_contents
	: INDENT variables DEDENT
	|
	;

const_expression
	: NUMBER
	| STRING
	| '(' const_expression ')'
	| const_expression '+' const_expression
	| const_expression '-' const_expression
	| const_expression '*' const_expression
	| const_expression '/' const_expression
	| '-' const_expression %prec UMINUS
	;
	
procbody // And here's where it gets hairy.
	: /* empty */
	| expressions
	;
	
expressions
	: expression
	| expression expressions
	;

expression
	: RETURN expression {;}
	| const_expression
	;
%%

#include <stdio.h>

int main() {
	printf("OpenBYOND DM Test Parser\n");
	yyparse();
}
