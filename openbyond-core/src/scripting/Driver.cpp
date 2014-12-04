/**
* DMScript Driver
*/

#include <cassert>
#include <fstream>
#include <sstream>

#include "string_utils.h"
#include "ObjectTree.h"
#include "Proc.h"

#include "scripting/Driver.h"
#include "scripting/DMLexer.h"
#include "scripting/Preprocessor.h"

namespace DM {

Driver::Driver()
    : trace_scanning(false),
      trace_parsing(false),
      trace_preprocessing(false)
{
	preprocessor = new Preprocessor();
}

bool Driver::parse_stream(std::iostream& in, const std::string& sname)
{
	atomContext = NULL; // Reset context.
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
	std::fstream in(filename.c_str());
	if (!in.good()) return false;
	/*
	std::string outfile=filename+".dmpp";
	std::fstream out(outfile.c_str(),std::fstream::out);
	if (!out.good()) return false;
	preprocessor->ParseStream(in,out,filename);
	std::cout << ">>> " << outfile << " written!" << std::endl;
	out.close();
	*/
	assert(preprocessor != 0);
	std::string pp_internal("");
	std::stringstream preprocessed(pp_internal);
	preprocessor->ParseStream(in,preprocessed,filename);
	preprocessed.seekg(0);
	return parse_stream(preprocessed, filename);
}

bool Driver::parse_string(const std::string &input, const std::string& sname)
{
	std::stringstream iss(input);
	std::string pp_internal("");
	std::stringstream preprocessed(pp_internal);

	preprocessor->ParseStream(iss,preprocessed,streamname);
	return parse_stream(preprocessed, sname);
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

void pushToContext(DMProc *proc)
{
	
}

Atom* Driver::pushContext(TokenizedPath atom_path) 
{
	//std::vector<std::string> atom_path = ;
	int poplevel;
	int indentlevel = lexer->get_indent_level();
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
	implode(this->context,'/',npath);
	
	printf("[Driver::pushContext] PLs = %3d, Context = %s\n",popLevels.size(),npath.c_str());
	
	
	Atom* found = ObjectTree::getInstance().GetAtom(npath);
	if(found==NULL) {
		/*if procArgs is not None:
			assert npath.endswith(')')
			proc = Proc(npath, procArgs, filename, ln)
			proc.origpath = origpath
			proc.definition = 'proc' in defs
			this->Atoms[npath] = proc
		else*/
		found = ObjectTree::getInstance().AddAtom(new Atom(npath, "", 0));
	}
	this->atomContext = found;
	this->pindent = indentlevel;
	return found;
}
Proc* Driver::pushToContext(DMProc *parsed) {
	Proc *proc = new Proc(parsed->name);
}
} // End DM Namespace.