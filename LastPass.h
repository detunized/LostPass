#include <vector>
#include <string>

class LastPass
{
public:
	LastPass(char const *dump_filename, char const *credentials_filename);

private:
	static void load_file(char const *filename, std::vector<char> &data_out);
	static void decode_base64(std::vector<char> &encoded, std::vector<char> &decoded_out);
	
	void load_credentials(char const *filename);
	void parse();
	void parse_ACCT(char const *data, size_t size);

	std::vector<char> data_;
	std::string username_;
	std::string password_;
};
