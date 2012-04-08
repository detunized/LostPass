#include "LastPass.h"

#include <iostream>
#include <fstream>

#include "openssl/bio.h"
#include "openssl/evp.h"

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
	
	decode();
}

void LastPass::decode()
{
	decoded_data_.clear();

    // Construct an OpenSSL context
    BIO *command = BIO_new(BIO_f_base64());
    BIO *context = BIO_new_mem_buf(&data_[0], data_.size());
         
    // Tell the context to encode base64
    context = BIO_push(command, context);
 
	BIO_set_flags(context, BIO_FLAGS_BASE64_NO_NL);
 
	size_t const BUFFSIZE = 256;
    int len;
    char inbuf[BUFFSIZE];
    while ((len = BIO_read(context, inbuf, BUFFSIZE)) > 0)
    {
		cout << "len: " << len << endl;
		decoded_data_.insert(decoded_data_.end(), inbuf, inbuf + len);
    }
 
    BIO_free_all(context);
	
	cout << decoded_data_.size() << endl << &decoded_data_[0] << endl;
}
