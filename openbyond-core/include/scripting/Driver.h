#ifndef DRIVER_H
#define DRIVER_H

#include <string>
#include <vector>
#include <map>

#include "Atom.h"
#include "scripting/Nodes.h"
#include "scripting/Preprocessor.h"


namespace DM {

/** The Driver class brings together all components. It creates an instance of
 * the Parser and Scanner classes and connects them. Then the input stream is
 * fed into the scanner object and the parser gets it's token
 * sequence. Furthermore the driver object is available in the grammar rules as
 * a parameter. Therefore the driver class contains a reference to the
 * structure into which the parsed data is saved. */
class Driver
{
public:
	// Typedef
	typedef std::vector<std::string> TokenizedPath;
	
	/// construct a new parser driver context
	Driver();

	/// enable debug output in the flex scanner
	bool trace_scanning;

	/// enable debug output in the bison parser
	bool trace_parsing;

	/// enable debug output in the shitty preprocessor
	bool trace_preprocessing;

	/// stream name (file or input stream) used for error messages.
	std::string streamname;

	/** Invoke the scanner and parser for a stream.
	* @param in	input stream
	* @param sname	stream name for error messages
	* @return		true if successfully parsed
	*/
	bool parse_stream(std::iostream& in, const std::string& sname = "stream input");

	/** Invoke the scanner and parser on an input string.
	* @param input	input string
	* @param sname	stream name for error messages
	* @return		true if successfully parsed
	*/
	bool parse_string(const std::string& input, const std::string& sname = "string stream");

	/** Invoke the scanner and parser on a file. Use parse_stream with a
	* std::ifstream if detection of file reading errors is required.
	* @param filename	input file name
	* @return		true if successfully parsed
	*/
	bool parse_file(const std::string& filename);

	// To demonstrate pure handling of parse errors, instead of
	// simply dumping them on the standard error output, we will pass
	// them to the driver using the following two member functions.

	/** Error handling with associated line number. This can be modified to
	* output the error e.g. to a dialog box. */
	void error(const class location& l, const std::string& m);

	/** General error handling. This can be modified to output the error
	* e.g. to a dialog box. */
	void error(const std::string& m);

	/** Pointer to the current lexer instance, this is used to connect the
	* parser to the scanner. It is used in the yylex macro. */
	class Lexer* lexer;
	
	Preprocessor* preprocessor;

	/** Push an atom to the context stack.
	* This is used to construct the ObjectTree and determine where children are on the aforementioned tree.
	* @param atomfragment Atom fragment ({,obj}, {gun,barry})
	*/
	Atom* pushContext(TokenizedPath atomfragment);
	
	/**
	 * Handle unindenting x levels.
	 * @param levels How many levels to dedent.
	 */
	void popIndent(int levels);
	
	/**
	 * Handle indenting x levels.
	 * @param levels How many levels to indent.
	 */
	void pushIndent(int levels);
    
private:
	// Context stack
	// 
	// /obj/item/knife = {obj,item,knife}
	TokenizedPath context;
	
	std::vector<int> popLevels;
	std::map<std::string, Atom*> atoms;
	int pindent;
};
}
typedef DM::Driver::TokenizedPath DMTokenPath;

#endif // DRIVER_H