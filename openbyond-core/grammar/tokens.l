%top {
/*
DM Lexer

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

// No unistd.h pls
#define YY_NO_UNISTD_H
}
%{
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include "scripting/DMLexer.h"

typedef DM::Parser::token      token;
typedef DM::Parser::token_type token_type;

/* By default yylex returns int, we use token_type. Unfortunately yyterminate
 * by default returns 0, which is not of token_type. */
#define yyterminate() return token::END

#define MAX_DEPTH 72

// Enable this to relentlessly spam your console with lexer tokens.
//#define LEX_TRACE 1

#ifdef LEX_TRACE
#define LEX_DEBUG(x)   printf("%s", x)
#define DEBUG_TOKEN(x) printf("%s ",x)
#define DEBUG_EOL      printf("\n");
#else
#define LEX_DEBUG(x)
#define DEBUG_TOKEN(x)
#define DEBUG_EOL
#endif

#define DM_TAB_WIDTH 4

/* globals to track current indentation */
int current_line_indent = 0;   /* indentation of the current line */
int indent_stack[200];         /* Stack of indents. */
int current_indent_level = 0;  /* indentation of the current line */
int bracket_indent_level = 0;  /* indentations given by brackets because BYOND is fucking dumb. */
int indent_level = 0;          /* indentation level passed to the parser */

/* Current position */
int linenum = 1;
/* %option yyclass="BaseLexer" */
%}

%x COMMENT
%x MULTICOMMENT
%x INDENT_PROCESSING
%x STRING_STATE
%x MULTISTRING

%option noyywrap
%option c++
%option yylineno

%%
<INDENT_PROCESSING>" "  { current_line_indent++; }
<INDENT_PROCESSING>"\t" { current_line_indent += DM_TAB_WIDTH; }
<INDENT_PROCESSING>"\n" { current_line_indent = 0; DEBUG_EOL; linenum++; /*ignoring blank line */ }
<INDENT_PROCESSING>.    {
#ifdef LEX_TRACE
		printf("\n[INDENT_PROCESSING - CLI: %3d, CIL: %d] ",current_line_indent,current_indent_level);
		for(int i = 0;i<current_indent_level;i++)
			printf("  "); // 2 spaces
#endif
		unput(*yytext);
		if (current_line_indent > indent_level) {
			indent_stack[++current_indent_level]=indent_level=current_line_indent;
			DEBUG_TOKEN("INDENT");
			return token::INDENT;
		} else if (current_line_indent < indent_level) {
			current_indent_level--;
			indent_level=indent_stack[current_indent_level];
			//printf(" [nIL=%d]",indent_level);
			DEBUG_TOKEN("DEDENT");
			//DEBUG_EOL;
			return token::DEDENT;
		} else {
			//LEX_DEBUG("<INITIAL>");
			BEGIN INITIAL;
		}
	}
<<EOF>> {
#ifdef LEX_TRACE
		printf("\n--- [EOF] [INDENT_PROCESSING - CLI: %3d, CIL: %d] ",current_line_indent,current_indent_level);
#endif
		current_line_indent=0;
		if (current_indent_level>0) {
			unput(*yytext);
			current_indent_level--;
			DEBUG_TOKEN("DEDENT");
			//DEBUG_EOL;
			return token::DEDENT;
		} else {
			yyterminate();
		}
	}
"\n" { 
		/* Only handle block indents if we're not in a bracket indent. */
		if(bracket_indent_level==0) {
			current_line_indent = 0;
			BEGIN INDENT_PROCESSING; 
		}
		linenum++;
		//DEBUG_EOL;
	}

%{ /* Bracket "indents".  BYOND is stupid. */ %}
"{"                     { bracket_indent_level++; DEBUG_TOKEN("INDENT"); return token::INDENT; }
"}"                     { DEBUG_TOKEN("DEDENT");assert(bracket_indent_level>0); bracket_indent_level--; return token::DEDENT; }

%{ 
/* Beginning of nan0desu's lexer rules. */ 

/* ESCAPES */ 
%}
\\.                     {;}
\\\n                    {linenum++;}

%{/* Comments */%}
\/\/                    {BEGIN COMMENT;}
<COMMENT>\n             {BEGIN INITIAL; yyless(0);}
<COMMENT>.              {;}

\/\*                    { BEGIN MULTICOMMENT; }
<MULTICOMMENT>\\.       { ; }
<MULTICOMMENT>\\\n      { linenum++; }
<MULTICOMMENT>\*\/      { BEGIN INITIAL; }
<MULTICOMMENT>.         { ; }
<MULTICOMMENT>\n        { linenum++; }

%{/* Strings */%}
\"                      {BEGIN STRING_STATE;}
<STRING_STATE>\n        { 
		linenum++; 
		BEGIN INITIAL; 
		yyless(0); 
		return token::STRING;
	}
<STRING_STATE>\\.       { ;}
<STRING_STATE>\\\n      { DEBUG_EOL; linenum++; }
<STRING_STATE>\"        { BEGIN INITIAL; DEBUG_TOKEN("STRING");return token::STRING; }
<STRING_STATE>.         { ; }

\{\"                    { BEGIN MULTISTRING; }
<MULTISTRING>\\.        { ; }
<MULTISTRING>\\\n       { DEBUG_EOL; linenum++; }
<MULTISTRING>\"\}       { BEGIN INITIAL; DEBUG_TOKEN("STRING");return token::STRING; }
<MULTISTRING>.          { ; }
<MULTISTRING>\n         { DEBUG_EOL; linenum++; }

%{/* Keywords */%}
"var"                   {DEBUG_TOKEN("VAR");    return token::VAR;}
"proc" |
"verb"                  {DEBUG_TOKEN("PROC");   return token::PROC;}
"return"                {DEBUG_TOKEN("RETURN"); return token::RETURN;}

%{/* Operators */%}
"=" |
"+" |
"-" |
"*" |
"/" |
"(" |
")"                     {DEBUG_TOKEN(yytext);return static_cast<token_type>(*yytext);}

[a-zA-Z_][a-zA-Z0-9_]*	{DEBUG_TOKEN("IDENTIFIER");yylval->strval=strdup(yytext);return token::IDENTIFIER; }

[1-9][0-9]*             {DEBUG_TOKEN("NUMBER");return token::NUMBER;}
[1-9][0-9]*\.[0-9]+     {DEBUG_TOKEN("NUMBER");return token::NUMBER;}

%{/* Dump extraneous space */%}
[ \t]+                  {;}

<*>. { /*if(yytext!="") printf("Unidentified token \"%s\".\n",yytext); */}

%%

namespace DM {
Lexer::Lexer(std::istream* in, std::ostream* out)
    : yyFlexLexer(in, out)
{
}

Lexer::~Lexer()
{
}

int Lexer::yylex()
{
	return 0;
}
/*
void Lexer::set_debug(bool b)
{
    yy_flex_debug = b;
}
*/
}

/* This implementation of ExampleFlexLexer::yylex() is required to fill the
 * vtable of the class ExampleFlexLexer. We define the scanner's main yylex
 * function via YY_DECL to reside in the Scanner class instead. */

#ifdef yylex
#undef yylex
#endif

int yyFlexLexer::yylex()
{
    std::cerr << "in Lexer::yylex() !" << std::endl;
    return 0;
}

/* When the scanner receives an end-of-file indication from YY_INPUT, it then
 * checks the yywrap() function. If yywrap() returns false (zero), then it is
 * assumed that the function has gone ahead and set up `yyin' to point to
 * another input file, and scanning continues. If it returns true (non-zero),
 * then the scanner terminates, returning 0 to its caller. */
/*
int yyFlexLexer::yywrap()
{
    return 1;
}
*/
int yyerror (const char *s)
{
    printf("Parser error[%d]: %s \n",linenum,s);
    return 0;
}