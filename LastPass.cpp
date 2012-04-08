#include "LastPass.h"

#include <iostream>
#include <fstream>

#include <libkern/OSByteOrder.h>

#include "openssl/bio.h"
#include "openssl/evp.h"
#include "openssl/sha.h"
#include "openssl/aes.h"

using namespace std;

LastPass::LastPass(char const *dump_filename, char const *credentials_filename)
{
	vector<char> dump;
	load_file(dump_filename, dump);
	decode_base64(dump, data_);

	load_credentials(credentials_filename);
	
	key_ = sha256(username_ + password_);
	
	parse();
}

void LastPass::load_file(char const *filename, vector<char> &data_out)
{
	ifstream in(filename);

	in.seekg(0, ios::end);
	size_t length = in.tellg();
	in.seekg(0, ios::beg);

	data_out.resize(length);
	in.read(&data_out[0], length);
}

void LastPass::decode_base64(vector<char> &encoded, vector<char> &decoded_out)
{
    BIO *context = BIO_push(BIO_new(BIO_f_base64()), BIO_new_mem_buf(&encoded[0], encoded.size()));
	BIO_set_flags(context, BIO_FLAGS_BASE64_NO_NL);
 
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

vector<uint8_t> LastPass::sha256(string const &text)
{
    vector<uint8_t> hash(SHA256_DIGEST_LENGTH);
    SHA256_CTX sha256;
    SHA256_Init(&sha256);
    SHA256_Update(&sha256, text.c_str(), text.size());
    SHA256_Final(&hash[0], &sha256);
	
	return hash;
}

void LastPass::load_credentials(char const *filename)
{
	ifstream in(filename);
	in >> username_ >> password_;
}

void LastPass::parse()
{
	size_t i = 0;
	char const *data = &data_[0];
	size_t size = data_.size();

	while (i + 8 <= size)
	{
		uint32_t chunk_id = OSReadBigInt32(data, i);
		uint32_t chunk_size = OSReadBigInt32(data, i + 4);
		char const *chunk_data = data + i + 8;
		
		i += 8 + chunk_size;

		cout 
			<< (char)((chunk_id >> 24) & 0xff) 
			<< (char)((chunk_id >> 16) & 0xff) 
			<< (char)((chunk_id >> 8) & 0xff) 
			<< (char)(chunk_id & 0xff) 
			<< "\n" 
			<< chunk_size 
			<< endl;
			
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

void LastPass::parse_ACCT(char const *data, size_t size)
{
	for (size_t id = 0, i = 0; i + 4 <= size; ++id)
	{
		uint32_t item_size = OSReadBigInt32(data, i);
		char const *item_data = data + i + 4;

		i += 4 + item_size;
		
		if (id == 1)
		{
			vector<uint8_t> name = decrypt_aes256_ecb(item_data, item_size);
			accounts_.push_back(string(name.begin(), name.end()));
		}
	}
}

vector<uint8_t> LastPass::decrypt_aes256_ecb(char const *data, size_t size)
{
	AES_KEY key;
	AES_set_decrypt_key(&key_[0], key_.size() * 8, &key);
	uint8_t in[16] = {0};
	uint8_t out[16] = {0};
	memcpy(in, data, std::min((size_t)16, size));
	AES_decrypt((uint8_t const *)data, out, &key);
	return vector<uint8_t>(out, out + std::min((size_t)16, size));
}

#if 0
unsigned char *aes_decrypt(EVP_CIPHER_CTX *e, unsigned char *ciphertext, int *len)
{
  /* plaintext will always be equal to or lesser than length of ciphertext*/
  int p_len = *len, f_len = 0;
  unsigned char *plaintext = malloc(p_len);
  
  EVP_DecryptInit_ex(e, NULL, NULL, NULL, NULL);
  EVP_DecryptUpdate(e, plaintext, &p_len, ciphertext, *len);
  EVP_DecryptFinal_ex(e, plaintext+p_len, &f_len);

  *len = p_len + f_len;
  return plaintext;
}
#endif