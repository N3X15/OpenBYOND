#include <iostream>
#include <fstream>

#include "string_utils.h"
#include "ObjectTree.h"
#include "scripting/Driver.h"
#include <tclap/CmdLine.h>

int main(int argc, char *argv[])
{
	std::string version = string_format("%d.%d.%d",VERSION_MAJOR,VERSION_MINOR,VERSION_PATCH);
	try {
		TCLAP::CmdLine cmd("DM Test Interpreter", ' ', version);
		TCLAP::SwitchArg t_verbose("v","verbose","Spam debugging information.", cmd, false);
		TCLAP::SwitchArg t_suppress_header("","no-header","Spam debugging information.", cmd, false);
		TCLAP::UnlabeledMultiArg<std::string> t_files("fileName","DM files", false, "file");
		cmd.add(t_files);
		cmd.parse(argc,argv);
		
		if(!t_suppress_header.getValue()) {
			std::cout << "OpenBYOND DM Parser Prototype" << std::endl;
			std::cout << "___________________________________" << std::endl;
			std::cout << std::endl;
			std::cout << "(c)2014 OpenBYOND Contributors" << std::endl;
			std::cout << std::endl;
		}
		DM::Driver *driver = new DM::Driver();
		driver->trace_parsing=t_verbose.getValue();
		driver->trace_scanning=t_verbose.getValue();
		std::vector<std::string> files = t_files.getValue();
		for(int i = 0; i < files.size(); i++)
		{
			bool result = driver->parse_file(files[i]);
			if (result)
			{
				std::cout << ">>> Finished reading "<< files[i] << "." << std::endl;
			} else {
				std::cout << "!!! Failed to read "<< files[i] << "." << std::endl;
			}
		}
		std::cout << "--- Building Object Tree:" << std::endl;
		ObjectTree::getInstance().BuildTree();
		std::cout << ">>> Object Tree contains " << ObjectTree::getInstance().atoms.size() << " items." << std::endl;
	} catch (TCLAP::ArgException &e) { 
		std::cerr << "error: " << e.error() << " for arg " << e.argId() << std::endl;
	}
}