#ifndef _HAVE_SCRIPTING_NODES_H_
#define _HAVE_SCRIPTING_NODES_H_ 1

#include <string>
#include <map>

#include "Value.h"
class DMNode {
public:
	typedef std::map<std::string,DMNode *> DMChildCollection;
	
	DMNode *parent;
	DMChildCollection children;
};

class DMArguments : public DMNode {
	
};

class DMVariable : public DMNode {
public:
	std::string name;
	std::string type;
	int flags;
	BaseValue *value;
};

#endif