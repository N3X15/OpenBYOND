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

#include <string>

#include "Value.h"
#include "string_utils.h"

BaseValue::BaseValue(std::string filename, unsigned int line, std::string typepath):
	filename(filename),
	line(line),
	type(typepath)
{
}

BaseValue::~BaseValue(void)
{}

std::string BaseValue::ToString()
{
	return NULL;
}

std::string IntegerValue::ToString()
{ 
	return string_format("%d",(int)this->value); 
}
std::string FloatValue::ToString()
{ 
	return string_format("%f",(float)this->value); 
}

////////////////////////////////////
// STRING SHIT
////////////////////////////////////

StringValue::StringValue(std::string data, std::string filename, unsigned int line, std::string typepath) :
	Value<std::string>(filename,line,typepath)
{
	value = data;
}

std::string StringValue::ToString()
{
	return string_format("\"%s\"",value.c_str());
}

////////////////////////////////////
// FILE REF SHIT
////////////////////////////////////

std::string FileRefValue::ToString()
{
	return string_format("'%s'",value.c_str());
}
