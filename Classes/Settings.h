@interface Settings
{
}

+ (void)initialize;

+ (NSString *)lastEmail;
+ (void)setLastEmail:(NSString *)email;

+ (BOOL)haveUnlockCode;
+ (NSString *)unlockCode;
+ (void)setUnlockCode:(NSString *)code;

// The database is base64 encoded
+ (BOOL)haveDatabase;
+ (NSString *)database;
+ (void)setDatabase:(NSString *)database;

// The key is base64 encoded
+ (BOOL)haveEncryptionKey;
+ (NSString *)encryptionKey;
+ (void)setEncryptionKey:(NSString *)key;

@end
