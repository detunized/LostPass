#include "LastPassParser.h"

namespace LastPass
{

using namespace std;

Parser::Parser(char const *database_base64, uint8_t const *key):
	key_(key, key + KEY_LENGTH)
{
	decode_base64(database_base64, data_);
	parse();
}

void Parser::decode_base64(char const *encoded, vector<uint8_t> &decoded_out)
{
    BIO *context = BIO_push(BIO_new(BIO_f_base64()), BIO_new_mem_buf(const_cast<char *>(encoded), strlen(encoded)));
	BIO_set_flags(context, BIO_FLAGS_BASE64_NO_NL | BIO_FLAGS_MEM_RDONLY);
 
	decoded_out.clear();

	size_t const BUFFER_SIZE = 256;
    int bytes_read;
    char buffer[BUFFER_SIZE];
    while ((bytes_read = BIO_read(context, buffer, BUFFER_SIZE)) > 0)
    {
		decoded_out.insert(decoded_out.end(), buffer, buffer + bytes_read);
    }
 
    BIO_free_all(context);
}

void Parser::parse()
{
	size_t i = 0;
	uint8_t const *data = &data_[0];
	size_t size = data_.size();

	while (i + 8 <= size)
	{
		uint32_t chunk_id = OSReadBigInt32(data, i);
		uint32_t chunk_size = OSReadBigInt32(data, i + 4);
		uint8_t const *chunk_data = data + i + 8;
		
		i += 8 + chunk_size;

		switch (chunk_id)
		{
		case 'ACCT':
			parse_ACCT(chunk_data, chunk_size);
			break;
		default:
			break;
		}
	}
}

void Parser::parse_ACCT(uint8_t const *data, size_t size)
{
	vector<uint8_t> name;
	vector<uint8_t> username;
	vector<uint8_t> password;

	for (size_t id = 0, i = 0; i + 4 <= size; ++id)
	{
		uint32_t item_size = OSReadBigInt32(data, i);
		uint8_t const *item_data = data + i + 4;

		i += 4 + item_size;
		
		if (id == 1)
		{
			name = decrypt_aes256_ecb(item_data, item_size);
		}
		else if (id == 7)
		{
			username = decrypt_aes256_ecb(item_data, item_size);
		}
		else if (id == 8)
		{
			password = decrypt_aes256_ecb(item_data, item_size);

			accounts_.push_back(Account(
				string(name.begin(), name.end()), 
				string(username.begin(), username.end()), 
				string(password.begin(), password.end())
			));
		}
	}
}

vector<uint8_t> Parser::decrypt_aes256_ecb(uint8_t const *data, size_t size)
{
	EVP_CIPHER_CTX context;
	EVP_CIPHER_CTX_init(&context);
	EVP_DecryptInit(&context, EVP_aes_256_ecb(), &key_[0], 0);
	
	vector<uint8_t> out(size + EVP_MAX_BLOCK_LENGTH);
	int decrypted_size = 0;
	EVP_DecryptUpdate(&context, &out[0], &decrypted_size, (uint8_t const *)data, size);
	
	int final_size = 0;
	EVP_DecryptFinal(&context, &out[decrypted_size], &final_size);
	
	EVP_CIPHER_CTX_cleanup(&context);
	
	out.resize(decrypted_size + final_size);
	return out;
}

}
