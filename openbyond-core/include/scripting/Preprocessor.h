#ifndef _HAVE_PREPROCESSOR_H
#define _HAVE_PREPROCESSOR_H 1
#include <vector>
#include <string>
#include <map>
#include <sstream>
#include <iostream>
#include <fstream>
/**
 * Entry on the ignore stack.
 */
class IgnoreState {
public:
	IgnoreState(){;};
	IgnoreState(std::string start,bool ignoring, ...);
	std::string starttoken;
	/**
	 * String symbols to look for to end this state.
	 */
	std::vector<std::string> endtokens;
	bool ignoring;
};

class Preprocessor {
public:
	Preprocessor();
	~Preprocessor();
	
	/**
	 * Parse a file.
	 * @param filename File to preprocess
	 * @returns Output filename.
	 */
	std::string ParseFile(std::string filename);
	void ParseStream(std::iostream &fin,std::iostream &fout,std::string streamname);
	
	bool IsIgnoring();
	
	std::string filename;
private:
	
	void consumePreprocessorToken(std::string token,std::vector<std::string> args);
	
	// #ifdef,else,endif
	void consumeIfdef(std::vector<std::string> args);
	void consumeIfndef(std::vector<std::string> args);
	void consumeElse(std::vector<std::string> args);
	void consumeEndif(std::vector<std::string> args);
	
	// #define
	void consumeDefine(std::vector<std::string> args);
	
	// #undef
	void consumeUndef(std::vector<std::string> args);
	
	std::map<std::string,std::string> defines;
	std::vector<IgnoreState> ignoreStack;
	
	void rewindBuffer(std::string &buf, int numchars);
	void consumeUntil(std::iostream &fin, std::iostream &fout, char endmarker);
	void consumeUntil(std::iostream &fin, std::iostream &fout, std::string endmarker);
	void consumePPToken(std::iostream &fin, std::iostream &fout);
};
#endif