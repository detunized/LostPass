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

- (void)animate:(NSTimeInterval)seconds 
	fromTransform:(CGAffineTransform)fromTransform 
	toTransform:(CGAffineTransform)toTransform 
	onCompletion:(void (^)())onCompletion
{
	self.transform = fromTransform;

	[UIView animateWithDuration:seconds
		animations:^{
			self.transform = toTransform;
		}
		completion:^(BOOL) {
			onCompletion();
		}];
}

- (void)slideIn:(NSTimeInterval)seconds onCompletion:(void (^)())onCompletion
{
	[self animate:seconds 
		fromTransform:CGAffineTransformMakeTranslation(self.frame.size.width, 0) 
		toTransform:CGAffineTransformIdentity
		onCompletion:onCompletion];
}

- (void)slideOut:(NSTimeInterval)seconds onCompletion:(void (^)())onCompletion
{
	[self animate:seconds 
		fromTransform:CGAffineTransformIdentity
		toTransform:CGAffineTransformMakeTranslation(-self.frame.size.width, 0)
		onCompletion:onCompletion];
}

@end
