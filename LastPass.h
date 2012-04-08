#include <vector>

class LastPass
{
public:
	LastPass(char const *filename);

private:
	void decode();

	std::vector<char> data_;
	std::vector<char> decoded_data_;
};
