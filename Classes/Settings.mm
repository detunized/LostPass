#import "Settings.h"

#import "../external/SFHFKeychainUtils.h"

@implementation Settings

namespace
{

NSString *const KEYCHAIN_SERVICE_NAME = @"net.detunized.lostpass";

NSString *const WAS_RESET = @"wasReset";
NSString *const LAST_EMAIL = @"lastEmail";
NSString *const UNLOCK_CODE = @"unlockCode";
NSString *const DATABASE = @"database";
NSString *const ENCRYPTION_KEY = @"encryptionKey";

BOOL getBool(NSString *key)
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

void setBool(NSString *key, BOOL value)
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:value forKey:key];
	[defaults synchronize];
}

NSString *getString(NSString *key)
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

void setString(NSString *key, NSString *value)
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:value forKey:key];
	[defaults synchronize];
}

NSString *getFileContents(NSString *filename)
{
	return [NSString 
		stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@""]
		encoding:NSUTF8StringEncoding 
		error:nil
	];
}

NSString *retrieveFromKeychain(NSString *key)
{
	NSString *value = [SFHFKeychainUtils getPasswordForUsername:key andServiceName:KEYCHAIN_SERVICE_NAME error:nil];
	return value ? value : @"";
}

void storeInKeychain(NSString *key, NSString *value)
{
	[SFHFKeychainUtils storeUsername:key andPassword:value forServiceName:KEYCHAIN_SERVICE_NAME updateExisting:YES error:nil];
}

}

+ (void)initialize
{
	NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithBool:NO], WAS_RESET,
		@"", LAST_EMAIL,
		@"", DATABASE,
		nil];

	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

+ (BOOL)wasReset
{
	return getBool(WAS_RESET);
}

+ (void)setWasReset:(BOOL)yesNo
{
	setBool(WAS_RESET, yesNo);
}

+ (NSString *)lastEmail
{
	return getString(LAST_EMAIL);
}

+ (void)setLastEmail:(NSString *)email
{
	setString(LAST_EMAIL, email);
}

+ (BOOL)haveUnlockCode
{
	return [retrieveFromKeychain(UNLOCK_CODE) length] > 0;
}

+ (NSString *)unlockCode
{
	return retrieveFromKeychain(UNLOCK_CODE);
}

+ (void)setUnlockCode:(NSString *)code
{
	storeInKeychain(UNLOCK_CODE, code);
}

+ (BOOL)haveDatabaseAndKey;
{
#ifdef CONFIG_USE_LOCAL_DATABASE
	return YES;
#else
	return [getString(DATABASE) length] > 0 && [retrieveFromKeychain(ENCRYPTION_KEY) length] > 0;
#endif
}

+ (NSString *)database
{
#ifdef CONFIG_USE_LOCAL_DATABASE
	return getFileContents(@"account.dump");
#else
	return getString(DATABASE);
#endif
}

+ (NSString *)encryptionKey
{
#ifdef CONFIG_USE_LOCAL_DATABASE
	return getFileContents(@"key.txt");
#else
	return retrieveFromKeychain(ENCRYPTION_KEY);
#endif
}

+ (void)setDatabase:(NSString *)database encryptionKey:(NSString *)key;
{
#ifdef CONFIG_USE_LOCAL_DATABASE
#else
	setString(DATABASE, database);
	storeInKeychain(ENCRYPTION_KEY, key);
#endif
}

@end
