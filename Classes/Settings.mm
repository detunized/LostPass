#import "Settings.h"

@implementation Settings

namespace
{

NSString *const LAST_EMAIL = @"lastEmail";

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

}

+ (void)initialize
{
	NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
		@"", LAST_EMAIL,
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

@end
