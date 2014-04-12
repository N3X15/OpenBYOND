#ifndef _HAVE_SCRIPTING_NODES_H_
#define _HAVE_SCRIPTING_NODES_H_ 1
/*
OpenBYOND DMScript AST Nodes

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
#include <string>
#include <map>
#include <vector>

#include "Value.h"
class DMNode {
public:
	typedef std::vector<DMNode *> DMChildCollection;
	
	DMNode *parent;
	DMChildCollection children;
	
	DMNode* Evaluate();
};

class DMArguments : public DMNode {};

#define VAR_GLOBAL       0x01 // var/global/ shit.  Dunno why we need this, since BYOND doesn't really care 
	                      //  if you declare a var as global, as long as it's in global context.
#define VAR_CONST        0x02 // Constant, immutable
#define VAR_DECLARATIVE  0x04 // "var/butts = 1" is declarative, while "butts = 1" isn't.

/**
 * Used to add the variable to the Scope.
 */
class DMVariableDecl : public DMNode {
public:
	std::string name;
	std::string type;
	int flags;
	BaseValue *value;
};

#define PROC_DECLARATIVE  0x01 // "proc/butts()" is declarative, while "butts()" isn't.
/**
 * Represents a proc on the AST tree.
 */
class DMProc : public DMNode {
public:
	std::string name;
	std::vector<std::string> path;
	int flags;
};

// Variable referenced in 
class DMVariableRef : public DMNode {
	std::string name;
};

// honk = expr
class DMAssignment: public DMNode {
	DMVariableRef *left;
	DMNode *right;
};

// return butts is actually
// return(butts)
class DMReturn : public DMNode {};

class DMFunctionCall : public DMNode {
public:
	std::string name;
};
#endif