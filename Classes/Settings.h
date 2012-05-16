@interface Settings
{
}

+ (void)initialize;

+ (BOOL)wasReset;
+ (void)setWasReset:(BOOL)yesNo;

+ (NSString *)lastEmail;
+ (void)setLastEmail:(NSString *)email;

+ (BOOL)haveUnlockCode;
+ (NSString *)unlockCode;
+ (void)setUnlockCode:(NSString *)code;

// The database and the encryption key are base64 encoded
+ (BOOL)haveDatabaseAndKey;
+ (NSString *)database;
+ (NSString *)encryptionKey;
+ (void)setDatabase:(NSString *)database encryptionKey:(NSString *)key;

@end
