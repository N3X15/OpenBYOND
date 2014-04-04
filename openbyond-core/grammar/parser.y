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

%{
class DMNode;
class Atom;

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "string_utils.h"
#include "parser.hpp"
#include "Atom.h"
#include "scripting/Driver.h"
#include "scripting/DMLexer.h"
#include "scripting/Nodes.h"

#undef yylex
#define yylex driver.lexer->lex

#define Y_DEBUG(rule,num) if(driver.trace_parsing) {printf("(%s[%d]) ",rule,num);}

%}

%union {
	char* strval;
	DMNode* node;
	Atom* atom;
}

%type <strval> IDENTIFIER path abspath relpath;
%type <atom> atomdef;

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
	: atomdef script                           { Y_DEBUG("script",1); }
	| procdecl script                          { Y_DEBUG("script",2); }
	| procdef script                           { Y_DEBUG("script",3); }
	| vardef script                            { Y_DEBUG("script",4); }
	| /* empty */
	;

path
	: abspath                                  { Y_DEBUG("path",1); $$ = $1;}
	| relpath                                  { Y_DEBUG("path",2); $$ = $1;}
	;
	
pathslash
	: path '/'                                 { Y_DEBUG("pathslash", 1); }
	;

abspath
	: '/' relpath                              { 
		Y_DEBUG("abspath",1);
		char *o;
		int size = asprintf(&o, "/%s",$2);
		if(size<0) {
			o = NULL;
		}
		$$ = o;
	}
	| abspath '/' IDENTIFIER                   { Y_DEBUG("abspath",2);
		char *o;
		int size = asprintf(&o, "%s/%s",$1,$3);
		if(size<0) {
			$$ = NULL;
		} else {
			$$ = o;
		}
	}
	;

relpath
	: IDENTIFIER                               { Y_DEBUG("relpath",1); $$ = $1; }
	| relpath '/' IDENTIFIER                   { Y_DEBUG("relpath",2);
		char *o;
		int size = asprintf(&o, "%s/%s",$1,$3);
		if(size<0) {
			$$ = NULL;
		} else {
			$$ = o;
		}
	}
	;
	
procdecl
	: pathslash procslash procdef_no_path      { Y_DEBUG("procdecl",1); }
	| pathslash procblock                      { Y_DEBUG("procdecl",2); }
	| procblock                                { Y_DEBUG("procdecl",3); }
	;
	
procslash 
	: PROC '/' ;
	
procblock
	: PROC INDENT procdefs DEDENT              { Y_DEBUG("procblock",1); }
	;

atomdef
	: path INDENT atom_contents DEDENT         { 
		Y_DEBUG("atomdef",1); 
		printf("atomdef: %s\n",$1);
		std::string fragment = std::string($1);
		$$ = driver.pushContext(fragment);
	}
	;
	
atom_contents
	: vardef atom_contents
	| atomdef atom_contents
	| procdef_no_path atom_contents
	| procblock atom_contents
	| varblock atom_contents
	| /* empty */
	;

vardefs
	: vardef vardefs
	| vardef
	;
vardef
	: path varblock
	| varblock
	| inline_vardef
	;

inline_vardef_no_default
	// var/honk is basically 
	// VAR path(/) identifier(honk)
	: VAR abspath '/' IDENTIFIER                { Y_DEBUG("inline_vardef_no_default",1); }
	;

inline_vardef
	: inline_vardef_no_default                      { Y_DEBUG("inline_vardef",1); }
	| inline_vardef_no_default '=' const_expression { Y_DEBUG("inline_vardef",2); }
	;
	
varblock
	: VAR INDENT vardefs DEDENT
	;
	
procdef
	: path argblock INDENT expressions DEDENT
	;
	
procdef_no_path
	: IDENTIFIER argblock INDENT expressions DEDENT
	;
	
argblock
	: '(' arguments ')'
	;

arguments
	: inline_vardef
	| inline_vardef ',' arguments
	| /* empty */
	;
	
procdefs
	: procdef_no_path procdefs
	| procdef_no_path
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
	: expression
	| expression expressions
	| /* empty */
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