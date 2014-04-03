/**
* DMScript Driver
*/

#include <fstream>
#include <sstream>

#include "string_utils.h"

#include "scripting/Driver.h"
#include "scripting/DMLexer.h"

namespace DM {

Driver::Driver()
    : trace_scanning(false),
      trace_parsing(false)
{
}

bool Driver::parse_stream(std::istream& in, const std::string& sname)
{
    streamname = sname;

    Lexer scanner(&in);
    scanner.set_debug_level(trace_scanning);
    this->lexer = &scanner;

    Parser parser(*this);
    parser.set_debug_level(trace_parsing);
    return (parser.parse() == 0);
}

bool Driver::parse_file(const std::string &filename)
{
    std::ifstream in(filename.c_str());
    if (!in.good()) return false;
    return parse_stream(in, filename);
}

bool Driver::parse_string(const std::string &input, const std::string& sname)
{
    std::istringstream iss(input);
    return parse_stream(iss, sname);
}

void Driver::error(const class location& l,
		   const std::string& m)
{
    std::cerr << l << ": " << m << std::endl;
}

void Driver::error(const std::string& m)
{
    std::cerr << m << std::endl;
}

Atom* Driver::pushContext(int indentlevel, std::string& atomfragment, DMArguments arguments, int flags) 
{
	std::vector<std::string> atom_path = split(atomfragment,'/');
	int poplevel;
	if(indentlevel == 0) {
		this->context = atom_path;
		if(this->context.size() == 0) {
			this->context.push_back("");
		} else if(this->context[0] != "") {
			this->context.insert(this->context.begin(), "");
		}
		poplevel = this->context.size();
		popLevels.clear();
		popLevels.push_back(poplevel);
	} else if(indentlevel > this->pindent) {
		this->context.insert(this->context.end(),atom_path.begin(),atom_path.end());
		this->popLevels.push_back(atom_path.size());
	} else if(indentlevel < this->pindent) {
		int popsToDo;
		for(int i=0;i<(this->pindent - indentlevel + 1);i++) {
			popsToDo = popLevels[0];
			popLevels.erase(popLevels.begin());
			for(int j=0;j<popsToDo;j++) {
				this->context.erase(this->context.begin());
			}
		}
		this->context.insert(this->context.end(),atom_path.begin(),atom_path.end());
		this->popLevels.push_back(atom_path.size());
	} else if(indentlevel == this->pindent) {
		int levelsToPop = this->popLevels[0];
		this->popLevels.erase(this->popLevels.begin());
		for(int i =0;i<levelsToPop;i++)
			this->context.erase(this->context.begin());
		this->context.insert(this->context.end(),atom_path.begin(),atom_path.end());
		this->popLevels.push_back(atom_path.size());
	}
	
	std::string npath;
	implode(this->context,',',npath);
	
	printf("[Driver::pushContext] PLs = %3d, Context = %s\n",popLevels.size(),npath.c_str());
	
	std::map<std::string,Atom*>::iterator it;
	it = this->atoms.find(npath);
	if(it != this->atoms.end()) {
		/*if procArgs is not None:
			assert npath.endswith(')')
			proc = Proc(npath, procArgs, filename, ln)
			proc.origpath = origpath
			proc.definition = 'proc' in defs
			this->Atoms[npath] = proc
		else*/
		this->atoms[npath] = new Atom(npath, "", 0);
	}
	this->pindent = indentlevel;
	return this->atoms[npath];
}

} // End DM Namespace.