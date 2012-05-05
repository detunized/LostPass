@interface Settings
{
}

+ (void)initialize;

+ (NSString *)lastEmail;
+ (void)setLastEmail:(NSString *)email;

+ (BOOL)haveCode;
+ (BOOL)haveDatabase;

@end
