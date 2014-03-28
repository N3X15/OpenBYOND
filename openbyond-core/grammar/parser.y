/*
OpenBYOND DMScript Bison Syntax

Originally written for DreamCatcher by nan0desu, significantly updated and 
changed to support full DM parsing.

Copyright (c) 2014 Rob "N3X15" Nelson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
%skeleton "lalr1.cc"
%require "2.3"
%defines
%define "parser_class_name" "Parser"
%define "namespace"         "DM"

%token AS 
%token DECREMENT 
%token DEDENT
%token END
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
#include "string_utils.h"
#include "parser.hpp"
#include "scripting/Driver.h"
#include "scripting/DMLexer.h"

#undef yylex
#define yylex driver.lexer->lex
%}
/* keep track of the current position within the input */
%locations
%initial-action
{
    // initialize the initial location object
    @$.begin.filename = @$.end.filename = &driver.streamname;
};




/* The driver is passed by reference to the parser and to the scanner. This
 * provides a simple but effective pure interface, not relying on global
 * variables. */
%parse-param {class Driver& driver}
%debug

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
	: atomdecl definition_contents                  {;}
	| atompath definition_contents                  {;}
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
		} else {
			$$ = o;
		}
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
void DM::Parser::error(const Parser::location_type& l, const std::string& m)
{
    driver.error(l, m);
}