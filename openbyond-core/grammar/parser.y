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
%token END        0 "end of file"
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
%nonassoc "abspath"

%union {
	char* strval;
}

%type <strval> IDENTIFIER;

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

#define Y_DEBUG(rule,num) printf("%s[%d] ",rule,num);
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
script
	: /* empty */
	| atomdef script                           { Y_DEBUG("script",1); }
	| procdecl script                          { Y_DEBUG("script",2); }
	| vardef script                            { Y_DEBUG("script",3); }
	;

path
	: /* empty */                              { Y_DEBUG("path",0); }
	| IDENTIFIER                               { Y_DEBUG("path",1); }
	| '/' path                                 { Y_DEBUG("path",2); }
	| path '/' IDENTIFIER                      { Y_DEBUG("path",3); }
	;
	
procdecl
	: path '/' PROC '/' procdef                { Y_DEBUG("procdecl",1); }
	| path '/' procblock                       { Y_DEBUG("procdecl",2); }
	| procblock                                { Y_DEBUG("procdecl",3); }
	;
	
procblock
	: PROC INDENT procdefs DEDENT              { Y_DEBUG("procblock",1); }
	;

atomdef
	: path INDENT atom_contents DEDENT         { Y_DEBUG("atomdef",1); }
	;
	
atom_contents
	: vardef atom_contents
	| atomdef atom_contents
	| procdef atom_contents
	;

vardefs
	: vardef vardefs
	| vardef
	;
vardef
	: path '/' varblock
	| varblock
	| inline_vardef
	;

inline_vardef_no_default
	: VAR '/' IDENTIFIER
	| VAR '/' path '/' IDENTIFIER
	;

inline_vardef
	: inline_vardef
	| inline_vardef '=' const_expression
	;
	
varblock
	: VAR INDENT vardefs DEDENT
	;
	
procdef
	: IDENTIFIER argblock INDENT expressions DEDENT
	;
	
argblock
	: '(' arguments ')'
	;

arguments
	: /* empty */
	| inline_vardef ',' arguments
	| inline_vardef
	;
	
procdefs
	: procdef procdefs
	| procdef
	;
	
const_expression
	: NUMBER
	| '(' const_expression ')'
	| const_expression '*' const_expression
	| const_expression '/' const_expression
	| const_expression '%' const_expression
	| const_expression '+' const_expression
	| const_expression '-' const_expression
	;

expression
	: assignment
	| inline_vardef
	| return
	;
	
expressions
	: /* empty */
	| expression expressions
	| expression
	;
	
assignable_expression
	: const_expression
	| IDENTIFIER 
	/* | string_expression */
	;
	
assignment
	: IDENTIFIER '=' assignable_expression
	;
return
	: RETURN const_expression
	;
%%
void DM::Parser::error(const Parser::location_type& l, const std::string& m)
{
    driver.error(l, m);
}