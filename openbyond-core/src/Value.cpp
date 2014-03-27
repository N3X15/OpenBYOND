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

#include "Value.h"

Value::Value(std::string filename = "", unsigned int line=0, std::string typepath="/"):
	filename(filename),
	line(line),
	type(typepath)
{
}

Value::~Value(void)
{}

std::string Value::ToString()
{
	return std::to_string(this->value);
}

////////////////////////////////////
// FILE REF SHIT
////////////////////////////////////

FileRefValue::FileRefValue(std::string filepath, std::string filename = "", unsigned int line=0, std::string typepath="/") :
	Value(filename,line,typepath)
{
	*value = filepath;
}

FileRefValue::~FileRefValue(void)
{}
