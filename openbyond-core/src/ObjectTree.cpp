/*
Object Tree

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

#include "ObjectTree.h"
#include "Atom.h"
#include "vector_utils.h"
#include "string_utils.h"

void ObjectTree::BuildTree() {
	// Initialize an empty tree.
	tree = new Atom("/");

	// Create our iterator.
	AtomMap::iterator iter;

	// Pre-init all variables we're going to use inside the loop.
	// Yes, there's a lot.
	Atom *atom;
	Atom *cNode;
	std::vector<std::string> cpath;
	std::vector<std::string> fullpath;
	std::vector<std::string> truncatedpath;
	std::string path_item;
	std::string cpath_str;
	std::string parent_type;
	std::vector<std::string>::size_type i;
	AtomMap::iterator foundChild;
	for (iter = atoms.begin(); iter != atoms.end(); ++iter) {
		atom = &iter->second;
		cpath.clear();
        cNode = this->tree;

		// Split path into chunks.
        fullpath = cNode->splitPath();

		// Ignore the first chunk (root of the tre)
        truncatedpath = VectorCopy<std::string>(fullpath,1);

		// Iterate through each path segment up the tree.
		for(i=0;i<truncatedpath.size();i++) {
			// Figure out where we are.
			path_item = truncatedpath[i];
			cpath.push_back(path_item);
			cpath_str = string_join("/",cpath);
			if(cNode->children.count(path_item)==1) {
				if(this->atoms.count(cpath_str)==1){
					cNode->children[path_item] = &this->atoms[cpath_str];
				} else {
					//if '(' in path_item:
					//    cNode.children[path_item] = Proc('/'.join([''] + cpath), [])
					//else:
					cNode->children[path_item] = new Atom("/"+string_join("/",cpath));
				}
				parent_type = cNode->children[path_item]->getProperty("parent_type",cNode->path);
				cNode->children[path_item]->parent = cNode;
				if(parent_type != cNode->path) {
					printf(" - Parent of %s forced to be %s",cNode->children[path_item]->path.c_str(), parent_type.c_str());
					cNode->children[path_item]->parent = &this->atoms[parent_type];
				}
			}
            cNode = cNode->children[path_item];
		}
	}
}