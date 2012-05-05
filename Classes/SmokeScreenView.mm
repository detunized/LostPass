#import "SmokeScreenView.h"

@implementation SmokeScreenView

@synthesize titleLabel = titleLabel_;

+ (SmokeScreenView *)smokeScreen
{
	return [[[NSBundle mainBundle] loadNibNamed:@"SmokeScreenView" owner:nil options:nil] objectAtIndex:0];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder])
	{
		self.frame = [UIScreen mainScreen].applicationFrame;
    }

    return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];

	// TODO: Init outlets here.
	self.titleLabel.text = @"LostPass, bitches!";
	self.titleLabel.textColor = [UIColor whiteColor];
}

- (void)dealloc
{
	self.titleLabel = nil;

    [super dealloc];
}

@end
