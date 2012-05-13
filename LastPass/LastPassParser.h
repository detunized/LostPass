#ifndef lastpass_parser_h_included
#define lastpass_parser_h_included

namespace LastPass
{

class Parser
{
public:
	class Account
	{
	public:
		Account(std::string const &name, std::string const &username, std::string const &password):
			name_(name),
			username_(username),
			password_(password)
		{
		}

		std::string const &name() const
		{
			return name_;
		}
		
		std::string const &username() const
		{
			return username_;
		}
		
		std::string const &password() const
		{
			return password_;
		}
		
	private:
		std::string name_;
		std::string username_;
		std::string password_;
	};
	
	static size_t const KEY_LENGTH = 32;

	// Creates valid empty database
	Parser()
	{
	}

	Parser(char const *database_base64, char const *key_base64);
	
	size_t count() const
	{
		return accounts_.size();
	}

	std::vector<Account> const &accounts() const
	{
		return accounts_;
	}

private:
	static void decode_base64(char const *encoded, std::vector<uint8_t> &decoded_out);
	
	void parse();
	void parse_ACCT(uint8_t const *data, size_t size);

	// Guesses encryption cipher from the data contents.
	std::vector<uint8_t> decrypt_aes256(uint8_t const *data, size_t size);

	std::vector<uint8_t> decrypt_aes256_ecb(uint8_t const *data, size_t size);
	std::vector<uint8_t> decrypt_aes256_cbc(uint8_t const *iv, uint8_t const *data, size_t size);

	// The cipher parameter is actually an OpenSSL EVP_CIPHER.  Exposing this would force users of this library
	// to include libcrypto headers for no good reason.
	std::vector<uint8_t> decrypt_aes256(void const *cipher, uint8_t const *iv, uint8_t const *data, size_t size);

	std::vector<uint8_t> data_;
	std::vector<uint8_t> key_;
	std::vector<Account> accounts_;
};

}

#endif
