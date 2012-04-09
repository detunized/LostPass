class LastPass
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

	LastPass(char const *dump_filename, char const *credentials_filename);
	
	std::vector<Account> const &get_accounts() const
	{
		return accounts_;
	}

private:
	static void load_file(char const *filename, std::vector<char> &data_out);
	static void decode_base64(std::vector<char> &encoded, std::vector<char> &decoded_out);
	static std::vector<uint8_t> sha256(std::string const &text);
	
	void load_credentials(char const *filename);
	void parse();
	void parse_ACCT(char const *data, size_t size);
	
	std::vector<uint8_t> decrypt_aes256_ecb(char const *data, size_t size);

	std::vector<char> data_;
	std::string username_;
	std::string password_;
	std::vector<uint8_t> key_;
	std::vector<Account> accounts_;
};
