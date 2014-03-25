#include "Atom.h"


Atom::Atom(std::string path, std::string filename = "", unsigned int line = 0):
	properties(),
	mapSpecified(),
	children(),
	line(line),
	filename(filename),
	path(path),
	ob_inherited(false)
{}


Atom::~Atom(void)
{
}
