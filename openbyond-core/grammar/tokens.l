%{
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <stdbool.h>

#include "parser.tab.h"

#define MAX_DEPTH 72

//#define YY_DECL extern "C" int yylex()

#define LEX_DEBUG(x) printf("%s",x)
#define DEBUG_TOKEN(x) printf("%s ",x)
#define DEBUG_EOL 	printf("\n");

#define DM_TAB_WIDTH 4

/* globals to track current indentation */
int current_line_indent = 0;   /* indentation of the current line */
int indent_stack[200];         /* Stack of indents. */
int current_indent_level = 0;  /* indentation of the current line */
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
%option yylineno

%%
<INDENT_PROCESSING>" "  { current_line_indent++; }
<INDENT_PROCESSING>"\t" { current_line_indent += (current_line_indent + 4) & ~3; }
<INDENT_PROCESSING>"\n" { current_line_indent = 0; DEBUG_EOL; linenum++; /*ignoring blank line */ }
<INDENT_PROCESSING>.    {
		//printf("INDENT_PROCESSING - CLI: %d, IL: %d",current_line_indent,indent_level);
		unput(*yytext);
		if (current_line_indent > indent_level) {
			indent_stack[current_indent_level++]=indent_level=current_line_indent;
			DEBUG_TOKEN("INDENT");
			return INDENT;
		} else if (current_line_indent < indent_level) {
			current_indent_level--;
			indent_level=indent_stack[current_indent_level--];
			DEBUG_TOKEN("DEDENT");
			DEBUG_EOL;
			return DEDENT;
		} else {
			//LEX_DEBUG("<INITIAL>");
			BEGIN INITIAL;
		}
	}
<<EOF>>                {
		//printf("INDENT_PROCESSING - CLI: %d, IL: %d",current_line_indent,indent_level);
		current_line_indent=0;
		if (current_indent_level>0) {
			unput(*yytext);
			current_indent_level--;
			DEBUG_TOKEN("DEDENT");
			DEBUG_EOL;
			return DEDENT;
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
		DEBUG_EOL;
	}

%{ /* Bracket "indents".  BYOND is stupid. */ %}
"{"                     { bracket_indent_level++; DEBUG_TOKEN("INDENT"); return INDENT; }
"}"                     { DEBUG_TOKEN("DEDENT");assert(bracket_indent_level>0); bracket_indent_level--; return DEDENT; }

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
		return STRING;
	}
<STRING_STATE>\\.       { ;}
<STRING_STATE>\\\n      { DEBUG_EOL; linenum++; }
<STRING_STATE>\"        { BEGIN INITIAL; DEBUG_TOKEN("STRING");return STRING; }
<STRING_STATE>.         { ; }

\{\"                    { BEGIN MULTISTRING; }
<MULTISTRING>\\.        { ; }
<MULTISTRING>\\\n       { DEBUG_EOL; linenum++; }
<MULTISTRING>\"\}       { BEGIN INITIAL; DEBUG_TOKEN("STRING");return STRING; }
<MULTISTRING>.          { ; }
<MULTISTRING>\n         { DEBUG_EOL; linenum++; }

%{/* Keywords */%}
"var"                   {DEBUG_TOKEN("VAR");    return VAR;}
"proc" |
"verb"                  {DEBUG_TOKEN("PROC");   return PROC;}
"return"                {DEBUG_TOKEN("RETURN"); return RETURN;}

%{/* Operators */%}
"=" |
"+" |
"-" |
"*" |
"/" |
"(" |
")"                     {DEBUG_TOKEN(yytext);return yytext[0];}

[a-zA-Z_][a-zA-Z0-9_]*	{DEBUG_TOKEN("IDENTIFIER");yylval.strval=strdup(yytext);return IDENTIFIER; }

[1-9][0-9]*             {DEBUG_TOKEN("NUMBER");return NUMBER;}
[1-9][0-9]*\.[0-9]+     {DEBUG_TOKEN("NUMBER");return NUMBER;}

%{/* Dump extraneous space */%}
[ \t]+                  {;}

<*>. { /*if(yytext!="") printf("Unidentified token \"%s\".\n",yytext); */}

%%


int yyerror (const char *s)
{
    printf("Parser error[%d]: %s \n",yylineno,s);
    return 0;
}