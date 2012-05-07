#import "SmokeScreenView.h"

@implementation SmokeScreenView

@synthesize titleLabel = titleLabel_;
@synthesize onTouched = onTouched_;

+ (SmokeScreenView *)smokeScreenView:(NSString *)title
{
	SmokeScreenView *view = [[[NSBundle mainBundle] loadNibNamed:@"SmokeScreenView" owner:nil options:nil] objectAtIndex:0];
	[view setTitle:title];
	return view;
}

+ (UIViewController *)smokeScreenController:(NSString *)title autoDismiss:(BOOL)autoDismiss
{
	// Note: __block is needed to avoid a retain cycle within the block.
	__block UIViewController *controller = [[[UIViewController alloc] initWithNibName:nil bundle:nil] autorelease];

	SmokeScreenView *view = [SmokeScreenView smokeScreenView:title];
	view.onTouched = autoDismiss
		? ^{ [controller dismissModalViewControllerAnimated:NO]; }
		: ^{};

	controller.view = view;
	
	return controller;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if (self = [super initWithCoder:decoder])
	{
		self.frame = [UIScreen mainScreen].applicationFrame;
	}

	return self;
}

- (void)dealloc
{
	self.titleLabel = nil;
	self.onTouched = nil;

	[super dealloc];
}

- (void)setTitle:(NSString *)title
{
	self.titleLabel.text = title;
	[self.titleLabel sizeToFit];
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	assert(self.onTouched);
	self.onTouched();
}

@end
