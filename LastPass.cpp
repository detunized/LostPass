#include "LastPass.h"

#include <iostream>
#include <fstream>

#include "openssl/bio.h"
#include "openssl/evp.h"

using namespace std;

LastPass::LastPass(char const *dump_filename, char const *credentials_filename)
{
	vector<char> dump;
	load_file(dump_filename, dump);
	decode_base64(dump, data_);

	load_credentials(credentials_filename);
}

void LastPass::load_file(char const *filename, std::vector<char> &data_out)
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

void LastPass::load_credentials(char const *filename)
{
	ifstream in(filename);
	in >> username_ >> password_;
}
