#include <vector>

class LastPass
{
public:
	LastPass(char const *filename);

private:
	std::vector<char> data_;
};
