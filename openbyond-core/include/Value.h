#pragma once

#include <string>

#define SPECIAL_GLOBAL (1 << 1)
#define SPECIAL_CONST  (1 << 2)

class Value
{
public:
    // The actual value.
    void* value;
        
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

	Value(std::string filename = "", unsigned int line=0, std::string typepath="/");
	~Value(void);

	virtual Value *copy();
	virtual std::string ToString();
};

class FileRefValue: Value
{
public:
    // The actual value.
    std::string *value;

	FileRefValue(std::string filepath, std::string filename = "", unsigned int line=0, std::string typepath="/");
	~FileRefValue(void);
};

class StringValue: Value
{
public:
    // The actual value.
    std::string *value;

	StringValue(std::string data, std::string filename = "", unsigned int line=0, std::string typepath="/");
	~StringValue(void);
};

