%{
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <stdbool.h>

#include "parser.tab.h"

#define MAX_DEPTH 72

//#define YY_DECL extern "C" int yylex()

#define LEX_DEBUG(x) printf("[%d] %s\n",linenum,x)

#define DM_TAB_WIDTH 4

/* globals to track current indentation */
int current_line_indent = 0;   /* indentation of the current line */
int bracket_indent_level = 0;  /* indentations given by brackets because BYOND is fucking dumb. */
int indent_level = 0;          /* indentation level passed to the parser */

/* Current position */
int linenum = 1;
%}

%x COMMENT
%x MULTICOMMENT
%x INDENT_PROCESSING
%x STRING_STATE
%x MULTISTRING
    
%option noyywrap

%%
<INDENT_PROCESSING>" "  { LEX_DEBUG("\\s");current_line_indent++; }
<INDENT_PROCESSING>"\t" { LEX_DEBUG("\\t");current_line_indent = (current_line_indent + DM_TAB_WIDTH) & ~(DM_TAB_WIDTH-1); }
<INDENT_PROCESSING>"\n" { LEX_DEBUG("\\n");current_line_indent = 0; linenum++; /*ignoring blank line */ }
<INDENT_PROCESSING>.    {
		unput(*yytext);
		if (current_line_indent > indent_level) {
			indent_level++;
			LEX_DEBUG("INDENT");
			return INDENT;
		} else if (current_line_indent < indent_level) {
			indent_level--;
			LEX_DEBUG("DEDENT");
			return DEDENT;
		} else {
			BEGIN INITIAL;
		}
	}

"\n" { 
		/* Only handle block indents if we're not in a bracket indent. */
		if(bracket_indent_level==0) {
			current_line_indent = 0;
			BEGIN INDENT_PROCESSING; 
		}
		linenum++;
		LEX_DEBUG("NEWLINE");
		return NEWLINE;
	}

"{"						{ bracket_indent_level++; LEX_DEBUG("INDENT"); return INDENT; }
"}"						{ assert(bracket_indent_level>0); bracket_indent_level--;LEX_DEBUG("DEDENT"); return DEDENT; }

%{ /* Beginning of nan0desu's lexer rules. */ %}
%{ /* ESCAPES */ %}
\\.  {;}
\\\n { linenum++;}

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
		return STRING;
	}
<STRING_STATE>\\.       { ;}
<STRING_STATE>\\\n      { linenum++; }
<STRING_STATE>\"        { BEGIN INITIAL; LEX_DEBUG("STRING");return STRING; }
<STRING_STATE>.         { ; }

\{\"                    { BEGIN MULTISTRING; }
<MULTISTRING>\\.        { ; }
<MULTISTRING>\\\n       { linenum++; }
<MULTISTRING>\"\}       { BEGIN INITIAL; LEX_DEBUG("STRING");return STRING; }
<MULTISTRING>.          { ; }
<MULTISTRING>\n         { linenum++; }

%{/* Keywords */%}
var                     {LEX_DEBUG("VAR");return VAR;}
proc|verb               {LEX_DEBUG("PROC");return PROC;}

[a-zA-Z_][a-zA-Z0-9_]*	{ yylval.strval=strdup(yytext);LEX_DEBUG("IDENTIFIER");return IDENTIFIER; }

%{/* Operators */%}
"=" |
"+" |
"-" |
"*" |
"/" |
"(" |
")"                     {LEX_DEBUG(yytext[0]);return yytext[0];}

[1-9][0-9]*             {LEX_DEBUG("NUMBER");return NUMBER;}
[1-9][0-9]*\.[0-9]+     {LEX_DEBUG("NUMBER");return NUMBER;}

%{/* Dump extraneous space */%}
[ \t]+                  {;}

%%

