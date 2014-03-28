/*
Value and Value Subtypes

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

#ifndef HAVE_VALUE_H
#define HAVE_VALUE_H

#include <string>

#define SPECIAL_GLOBAL (1 << 1)
#define SPECIAL_CONST  (1 << 2)

// Use this in type
class BaseValue
{
public: 
	// oh god what am I doing
	// T value;

    // Filename this was found in
    std::string filename;
        
    // Line of the originating file.
    unsigned int line;
        
    // Typepath of the value.
    std::string type;
        
    // Has this value been inherited?
    bool inherited;
        
    // Is this a declaration? (/var)
    bool declaration;
        
    // Anything special? (global, const, etc.)
    int special;
        
    // If a list, what's the size?
    unsigned int size;

	BaseValue(std::string filename = "", unsigned int line=0, std::string typepath="/");
	~BaseValue(void);

	virtual BaseValue *copy();
	virtual std::string ToString();
};

// Since this only accepts a few select types...
template <typename T> 
class Value : public BaseValue
{
public:
	Value(std::string filename = "", unsigned int line=0, std::string typepath="/"):
		BaseValue(filename,line,typepath)
	{};
	//~Value();

	T value;
};

class IntegerValue: public Value<int> 
{
	std::string ToString();
};

class FloatValue: public Value<float> 
{
	std::string ToString();
};

// Strings can be multiline and require additional formatting.
class StringValue: public Value<std::string>
{
public:
	StringValue(std::string data, std::string filename = "", unsigned int line=0, std::string typepath="/");
	//~StringValue(void);

	std::string ToString();
};

// FileRefs are like strings, except refer to a file and require special formatting.
class FileRefValue: public StringValue
{
public:
	FileRefValue(std::string filepath, std::string filename = "", unsigned int line=0, std::string typepath="/");
	//~FileRefValue(void);

	std::string ToString();
};
#endif