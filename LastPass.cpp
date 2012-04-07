#include "LastPass.h"

#include <iostream>
#include <fstream>

using namespace std;

LastPass::LastPass(char const *filename)
{
	ifstream in(filename);

	in.seekg(0, ios::end);
	size_t length = in.tellg();
	in.seekg(0, ios::beg);

	data_.resize(length);
	in.read(&data_[0], length);

	cout << data_.size() << endl;
}
