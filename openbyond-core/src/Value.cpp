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
