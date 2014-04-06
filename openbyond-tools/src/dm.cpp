#include <iostream>
#include <fstream>

#include "ObjectTree.h"
#include "scripting/Driver.h"

int main(int argc, char *argv[])
{
	DM::Driver driver;
	std::cout << "OpenBYOND DM Parser Prototype" << std::endl;
	std::cout << "___________________________________" << std::endl;
	std::cout << std::endl;
	std::cout << "(c)2014 OpenBYOND Contributors" << std::endl;
	std::cout << std::endl;
	for(int i = 1; i < argc; ++i)
	{
		/*
		std::fstream infile(argv[i]);
		if (!infile.good())
		{
			std::cerr << "!!! Could not open file: " << argv[i] << std::endl;
			return 0;
		}
		*/
		bool result = driver.parse_file(argv[i]);
		if (result)
		{
			std::cout << ">>> Finished reading "<< argv[i] << "." << std::endl;
		}
	}
	std::cout << "--- Building Object Tree:" << std::endl;
	ObjectTree::getInstance().BuildTree();
	std::cout << ">>> Object Tree contains " << ObjectTree::getInstance().atoms.size() << " items." << std::endl;
}