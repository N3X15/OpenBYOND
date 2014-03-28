#ifndef _HAVE_VECTOR_UTILS_H
#define _HAVE_VECTOR_UTILS_H

#include <vector>

// TODO: Unit test.
/**
* Implement python-style list index access in C++.
*/
template <typename T, class A>
std::vector<T,A> VectorCopy(std::vector<T,A> origin, int start = 0, int end = 0, int step = 1) {
	typename std::vector<T,A>::size_type _start;
	typename std::vector<T,A>::size_type _end;
	if(start<0)
	{
		_start = start + origin.size() - 1;
	} else {
		_start = start;
	}
	if(end<=0)
	{
		_end = end + origin.size() - 1;
	} else {
		_end = end;
	}
	//assert(_end > _start);
	std::vector<T> copy;
	for(std::vector<int>::size_type i = _start; i < _end; i += step){
		copy.push_back(origin[i]);
	}
	return copy;
};
#endif