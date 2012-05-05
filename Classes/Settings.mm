#import "Settings.h"

@implementation Settings

namespace
{

NSString *const LAST_EMAIL = @"lastEmail";
NSString *const UNLOCK_CODE = @"unlockCode";

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

}

+ (void)initialize
{
	NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
		@"", LAST_EMAIL,
		@"", UNLOCK_CODE,
		nil];

	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

+ (NSString *)lastEmail
{
	return getString(LAST_EMAIL);
}

+ (void)setLastEmail:(NSString *)email
{
	setString(LAST_EMAIL, email);
}

// TODO: The unlock code should not be stored in the user settings!!!
//       This is just for testing.
+ (BOOL)haveUnlockCode
{
	return [getString(UNLOCK_CODE) length] > 0;
}

+ (NSString *)unlockCode
{
	return getString(UNLOCK_CODE);
}

+ (void)setUnlockCode:(NSString *)code
{
	setString(UNLOCK_CODE, code);
}

+ (BOOL)haveDatabase
{
#ifdef CONFIG_USE_LOCAL_DATABASE
	return YES;
#else
	return NO;
#endif
}

+ (NSString *)database
{
#ifdef CONFIG_USE_LOCAL_DATABASE
	return getFileContents(@"account.dump");
#else
	return @"";
#endif
}

+ (BOOL)haveEncryptionKey
{
#ifdef CONFIG_USE_LOCAL_DATABASE
	return YES;
#else
	return NO;
#endif
}

+ (NSString *)encryptionKey
{
#ifdef CONFIG_USE_LOCAL_DATABASE
	return getFileContents(@"key.txt");
#else
	return @"";
#endif
}

@end
