@interface Settings
{
}

+ (void)initialize;

+ (NSString *)lastEmail;
+ (void)setLastEmail:(NSString *)email;

+ (BOOL)haveCode;
+ (NSString *)code;

// The database is base64 encoded
+ (BOOL)haveDatabase;
+ (NSString *)database;

// The key is base64 encoded
+ (BOOL)haveEncryptionKey;
+ (NSString *)encryptionKey;

@end
