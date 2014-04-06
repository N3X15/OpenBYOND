#ifndef _HAVE_PREPROCESSOR_H
#define _HAVE_PREPROCESSOR_H 1
/*
OpenBYOND DMScript Preprocessor

Originally written for DreamCatcher by nan0desu, significantly updated and 
changed to support full DM parsing.

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
	void rewindStream(std::iostream &stream, int numchars);
	
	void consumeUntil(std::iostream &fin, std::iostream &fout, char endmarker);
	void consumeUntil(std::iostream &fin, std::iostream &fout, std::string endmarker);
	void consumePPToken(std::iostream &fin, std::iostream &fout);
};
#endif