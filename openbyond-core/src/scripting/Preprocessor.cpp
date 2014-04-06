#include "scripting/Preprocessor.h"
#include "string_utils.h"
#include "vector_utils.h"
#include <vector>
#include <string>
#include <cstdarg>
#include <sstream>
#include <fstream>
#include <iostream>
#include <stack>

IgnoreState::IgnoreState(std::string start, bool ignoring, ...):
	starttoken(start),
	ignoring(ignoring),
	endtokens()
{
	int n;
	std::string endToken;
	va_list vl;
	va_start(vl,n);
	for (int i=0;i<n;i++)
	{
		endToken=std::string(va_arg(vl,const char*));
		endtokens.push_back(endToken);
	}
	va_end(vl);
};

Preprocessor::Preprocessor():
	defines()
{
	//
}

Preprocessor::~Preprocessor() {;}

void Preprocessor::rewindBuffer(std::string &buf, int numchars) {
	buf=buf.substr(0,buf.length()-(numchars+1));
}
	
std::string Preprocessor::ParseFile(std::string filename) {
	std::fstream fin(filename, std::fstream::in);
	if (fin==NULL)
	{
		return "";
	}
	std::fstream fout(filename+".tmp", std::fstream::out);
	if (fout==NULL)
	{
		fin.close();
		return "";
	}
	fout << "/// OpenBYOND Preprocessed Code\r\n";
	fout << "/// File: " << filename << "\r\n";
	fout << "///\r\n\r\n";
	
	ParseStream(fin,fout,filename);
	
	fin.close();
	fout.close();
	return filename+".tmp";
}

void Preprocessor::ParseStream(std::iostream &fin, std::iostream &fout, std::string streamname) {
	// Parse char by char
	char c;
	char lastchar;
	std::string buf;
	bool escape=false;
	bool encounteredOtherCharacters = false;
	int ignorelevel = 0;
	int line=1;
	std::string token("");
	std::stack<std::string> endtokens;
	bool skipNextChar=false;
	while (fin >> std::noskipws >> c) {
		// Skip windows return characters.
		token="";
		if(lastchar)
			token += lastchar;
		token += c;
		if(c == '\r') continue;
		if(c == '\n' && !escape) {
			line++;
			while(hasEnding(buf,"\n")||hasEnding(buf,"\r")) {
				buf = trim(buf," \t\r\n");
			}
			fout << buf;// << "\r\n";
			buf = "";
			encounteredOtherCharacters=false;
		} else if(c == '\\') {
			escape=true;
			continue;
		} else if(c == '#') {
			if(encounteredOtherCharacters && ignorelevel == 0){
				printf("%s:%d [PP] ERROR:  Encountered non-whitespace characters before preprocessor token!",streamname.c_str(),line);
				return;
			}
			consumePPToken(fin,fout);
			continue;
		} else if(c == '"' || c == '\'') {
			if(c=='"' && lastchar == '{')
				consumeUntil(fin,fout,"\"}");
			else
				consumeUntil(fin,fout,c);
			continue;
		} else if(lastchar == '/' && c == '/') {
			consumeUntil(fin,fout,'\n');
			continue;
		} else {
			encounteredOtherCharacters=true;
		}
		
		if(token=="/*") {
			endtokens.push("*/");
			rewindBuffer(buf,1);
			continue;
		}
		buf += c; // Or whatever
	}
}
	
void Preprocessor::consumePreprocessorToken(std::string token,std::vector<std::string> args)
{
	if(token == "ifdef")  consumeIfdef(args);
	if(token == "else")   consumeElse(args);
	if(token == "endif")  consumeEndif(args);
	if(token == "define") consumeDefine(args);
	if(token == "undef")  consumeUndef(args);
}

bool Preprocessor::IsIgnoring() {
	std::vector<IgnoreState>::iterator it;
	IgnoreState st8;
	for(it=ignoreStack.begin();it!=ignoreStack.end();it++) {
		st8 = *it;
		if(st8.ignoring) return true;
	}
	return false;
}
void Preprocessor::consumeIfdef(std::vector<std::string> args){
	std::map<std::string,std::string>::iterator it;
	std::string defname = args[0];
	it = defines.find(defname);
	ignoreStack.push_back(IgnoreState("ifdef",it != defines.end(),"else","endif"));
}

void Preprocessor::consumeIfndef(std::vector<std::string> args){
	std::map<std::string,std::string>::iterator it;
	it = defines.find(args[0]);
	ignoreStack.push_back(IgnoreState("ifndef",it == defines.end(),"else","endif"));
}

void Preprocessor::consumeElse(std::vector<std::string> args) {
	IgnoreState st8 = ignoreStack.back();
	ignoreStack.pop_back();
	ignoreStack.push_back(IgnoreState("else",!st8.ignoring,"endif"));
}
void Preprocessor::consumeEndif(std::vector<std::string> args){
	ignoreStack.pop_back();
}

// #define
void Preprocessor::consumeDefine(std::vector<std::string> args){
	if(args[0].find("(")){
		std::cerr << "[PP] ERROR: OpenBYOND does not currently support preprocessor macros." << std::endl; 
		return;
	}
	std::string imploded;
	implode(VectorCopy<std::string>(args,1), ' ', imploded);
	defines[args[0]]=imploded;
}

// #undef
void Preprocessor::consumeUndef(std::vector<std::string> args){
	std::map<std::string,std::string>::iterator it;
	it = defines.find(args[0]);
	if (it == defines.end()) return;
	defines.erase(it);
}

void Preprocessor::consumeUntil(std::iostream &fin, std::iostream &fout, char endmarker) {
	char c;
	while (fin >> std::noskipws >> c) {
		if(c==endmarker) return;
		if(fout!=NULL) {
			fout << c;
		}
	}
}
void Preprocessor::consumeUntil(std::iostream &fin, std::iostream &fout, std::string endtoken) {
	char c;
	char lastchar='\0';
	std::string token;
	while (fin >> std::noskipws >> c) {
		token="";
		if(lastchar)
			token += lastchar;
		token += c;
		lastchar=c;
		if(token==endtoken) return;
		if(fout!=NULL) {
			fout << c;
		}
	}
}

void Preprocessor::consumePPToken(std::iostream &fin, std::iostream &fout) {
	std::stringstream buf;
	consumeUntil(fin,buf,'\n');
	std::string line = buf.str();
	line=trim(line," \t\r\n");
	printf("consumeUntil(\\n): %s\n",line.c_str());
	std::vector<std::string> args = split(line,' ');
	printf("split(' '): %d items\n",args.size());
	std::string token = args[0];
	args=VectorCopy<std::string>(args,1);
	
	fout << "/* Found #" << token << line << ". */";
	
	consumePreprocessorToken(token,args);
}