typedef void (^SuccessBlock)(NSString *databaseBase64, NSString *keyBase64);
typedef void (^ErrorBlock)(NSString *errorMessage);

void downloadLastPassDatabase(NSString *username, NSString *password, SuccessBlock onSuccess, ErrorBlock onError);
