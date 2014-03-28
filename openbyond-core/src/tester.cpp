#include <iostream>
#include <fstream>
#include "scripting/Driver.h"

int main(int argc, char *argv[])
{
	DM::Driver driver;
		
    for(int i = 1; i < argc; ++i)
    {
		std::fstream infile(argv[i]);
		if (!infile.good())
		{
			std::cerr << "Could not open file: " << argv[i] << std::endl;
			return 0;
		}
		
		bool result = driver.parse_stream(infile, argv[i]);
		if (result)
		{
			std::cout << "Fin." << std::endl;
		}
	}
}