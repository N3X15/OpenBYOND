#pragma once
#include <string>
#include <map>
#include <vector>

#include "Value.h"

#define TURF_LAYER
#define AREA_LAYER
#define OBJ_LAYER
#define MOB_LAYER

class Atom
{
public:
	typedef std::map<std::string,Value> ValueMap;

    // Absolute path of this atom
    std::string path;

    // Vars of this atom, including inherited vars.
	ValueMap properties;
        
    // List of var names that were specified by the map, if atom was loaded from a :class:`byond.map.Map`.
    std::vector<std::string> mapSpecified;
        
    // Child atoms and procs.
    std::vector<Atom> children;
        
    // The parent of this atom.
    Atom *parent;
        
    // The file this atom originated from.
    std::string filename;
        
    // Line from the originating file.
    unsigned int line;
        
    // Instance ID (maps only).  Used internally, do NOT change.
    unsigned int id;
        
    // Instance ID that was read from the map.
    std::string old_id;
        
    // Used internally.
	std::string ob_forced_string;
        
    // Used internally.
	bool ob_inherited;

	Atom(std::string path, std::string filename = "", unsigned int line = 0);

	~Atom(void);
};

