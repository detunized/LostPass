#include "LastPassParser.h"

using namespace std;

static size_t write_data_callback(void *contents, size_t size, size_t count, void *user_parameter)
{
	vector<uint8_t> *storage = (vector<uint8_t> *)user_parameter;
	size_t bytes = size * count;
	storage->insert(storage->end(), (uint8_t *)contents, (uint8_t *)contents + bytes);

	return bytes;
}

static void download()
{
	CURL *curl = curl_easy_init();
	if (curl)
	{
		vector<uint8_t> response;

		curl_easy_setopt(curl, CURLOPT_USERAGENT, "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7");
		curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0l);
		
		//curl_easy_setopt(curl, CURLOPT_VERBOSE, 1l);
		
		curl_easy_setopt(curl, CURLOPT_URL, "https://lastpass.com/login.php");
		curl_easy_setopt(curl, CURLOPT_POSTFIELDS, "method=mobile&web=1&xml=1&username=yolastpass%40mailinator.com&hash=16274d9fc71aadffe805c4364559ff5ffa1d757da7cc0415d3b48c68b96ffa4d&iterations=1");
		
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data_callback);
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)&response);
		curl_easy_setopt(curl, CURLOPT_COOKIEJAR, "/Users/detunized/dev/temp/cookie.txt");

		CURLcode result = curl_easy_perform(curl);
		cout << "===\n" << result << "\n===\n" << string(response.begin(), response.end()) << "\n===\n";

		curl_easy_cleanup(curl);
	}
}

LastPassParser::LastPassParser(char const *dump_filename, char const *username, char const *password):
	username_(username),
	password_(password)
{
	vector<char> dump;
	load_file(dump_filename, dump);
	decode_base64(dump, data_);

	key_ = make_key(1);
	
	parse();

	//download();
}

void LastPassParser::load_file(char const *filename, vector<char> &data_out)
{
	ifstream in(filename);

	in.seekg(0, ios::end);
	size_t length = in.tellg();
	in.seekg(0, ios::beg);

	data_out.resize(length);
	in.read(&data_out[0], length);
}

void LastPassParser::decode_base64(vector<char> &encoded, vector<char> &decoded_out)
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

vector<uint8_t> LastPassParser::sha256(string const &text)
{
    vector<uint8_t> hash(SHA256_DIGEST_LENGTH);
    SHA256_CTX sha256;
    SHA256_Init(&sha256);
    SHA256_Update(&sha256, text.c_str(), text.size());
    SHA256_Final(&hash[0], &sha256);
	
	return hash;
}

vector<uint8_t> LastPassParser::make_key(size_t iteration_count)
{
	if (iteration_count == 1)
	{
		return sha256(username_ + password_);
	}
	else
	{
		static size_t const key_length = 32;
	
		vector<uint8_t> key(key_length);
		PKCS5_PBKDF2_HMAC(
			password_.c_str(), 
			password_.size(), 
			(uint8_t const *)username_.c_str(), 
			username_.size(), 
			iteration_count, 
			EVP_sha256(), 
			key_length, 
			&key[0]);
		
		return key;
	}
}

void LastPassParser::parse()
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

//		cout 
//			<< (char)((chunk_id >> 24) & 0xff) 
//			<< (char)((chunk_id >> 16) & 0xff) 
//			<< (char)((chunk_id >> 8) & 0xff) 
//			<< (char)(chunk_id & 0xff) 
//			<< "\n" 
//			<< chunk_size 
//			<< endl;
			
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

void LastPassParser::parse_ACCT(char const *data, size_t size)
{
	vector<uint8_t> name;
	vector<uint8_t> username;
	vector<uint8_t> password;

	for (size_t id = 0, i = 0; i + 4 <= size; ++id)
	{
		uint32_t item_size = OSReadBigInt32(data, i);
		char const *item_data = data + i + 4;

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

vector<uint8_t> LastPassParser::decrypt_aes256_ecb(char const *data, size_t size)
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
	
	//cout << "'" << string(&out[0], &out[decrypted_size + final_size]) << "' " << size << ", " << decrypted_size << ", " << final_size << endl;

	out.resize(decrypted_size + final_size);
	return out;
}
