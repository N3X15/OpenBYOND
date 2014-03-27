/*
Atom Definition

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
#ifndef HAVE_ATOM_H
#define HAVE_ATOM_H

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
	typedef std::map<std::string,BaseValue> ValueMap;

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

#endif