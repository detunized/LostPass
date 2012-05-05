#import "SmokeScreenView.h"

@implementation SmokeScreenView

+ (SmokeScreenView *)smokeScreen
{
	return [[[SmokeScreenView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
	{
		// TODO: Use xib for this.
		[self addSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-background.png"]] autorelease]];
    }

    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
