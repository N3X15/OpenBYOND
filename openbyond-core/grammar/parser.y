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
	std::vector<std::string>* path;
	Atom* atom;
}

%type <strval> IDENTIFIER;
%type <path> path abspath relpath pathslash;
%type <atom> atomdef;

%type <node> procdef procdefs procdef_no_path

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
	: path '/'                                 { Y_DEBUG("pathslash", 1);
		std::vector<std::string>* o = $1;
		o->push_back("");
		$$ = o;
	}
	;

abspath
	: '/' relpath {
		std::vector<std::string>* o = $2;
		o->insert(o->begin(),std::string(""));
		$$ = o;
	}
	| abspath '/' IDENTIFIER                   { Y_DEBUG("abspath",2);
		std::vector<std::string>* o = $1;
		std::string identifier = std::string($3);
		o->push_back(identifier);
		$$ = o;
	}
	;

relpath
	: IDENTIFIER                               { Y_DEBUG("relpath",1);
		std::vector<std::string>* o = new std::vector<std::string>();
		std::string identifier = std::string($1);
		o->push_back(identifier);
		$$ = o;
	}
	| relpath '/' IDENTIFIER                   { Y_DEBUG("relpath",2);
		std::vector<std::string>* o = $1;
		std::string identifier = std::string($3);
		o->push_back(identifier);
		$$ = o;
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
	: PROC INDENT procdefs DEDENT              { 
		/* Proc block
		```
		proc
			honk()
			...
		```
		All child procs are declarative.
		*/
		Y_DEBUG("procblock",1);
		DMNode *node = (DMNode*)($3);
		DMNode::DMChildCollection::iterator it;
		for(it=node->children.begin();it!=node->children.end();it++) {
			DMProc *proc = (DMProc*)(*it);
			proc->flags |= PROC_DECLARATIVE;
			driver.pushToContext(proc);
		}
	}
	;

atomdef
	: path INDENT atom_contents DEDENT         { 
		Y_DEBUG("atomdef",1); 
		//printf("atomdef: %s\n",$1);
		$$ = driver.pushContext((DM::Driver::TokenizedPath)(*$1));
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
	| VAR '/' IDENTIFIER                        { Y_DEBUG("inline_vardef_no_default",2); }
	;

inline_vardef
	: inline_vardef_no_default                      { Y_DEBUG("inline_vardef",1); }
	| inline_vardef_no_default '=' const_expression { Y_DEBUG("inline_vardef",2); }
	;
	
varblock
	: VAR INDENT vardefs DEDENT
	;
	
procdef
	: path argblock INDENT expressions DEDENT {
		Y_DEBUG("procdef",1);
		std::vector<std::string>* path = $1;
		std::string identifier = path->back();
		path->pop_back();
		DMProc *proc = new DMProc();
		proc->name = identifier;
		proc->path = *path;
		$$ = proc;
	}
	;
	
procdef_no_path
	: IDENTIFIER argblock INDENT expressions DEDENT {
		Y_DEBUG("procdef_no_path",1);
		std::vector<std::string> path;
		DMProc *proc = new DMProc();
		proc->name = $1;
		proc->path = path;
		$$ = proc;
	}
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
	: procdef_no_path procdefs {
		DMNode *node = $2;
		node->children.push_back($1);
		$$ = node;
	}
	| procdef_no_path {
		DMNode *collection = new DMNode();
		collection->children.push_back($1);
		$$ = collection;
	}
	;
	
const_expression
	: NUMBER
	| STRING  { $$ = new DMString($1); }
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