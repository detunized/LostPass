#import "UnlockViewController.h"

namespace
{

enum SubtitleAnimationStyle
{
	SubtitleAnimationStyleSlideIn,
	SubtitleAnimationStyleSlideOut
};

NSString *CHOOSE_CODE_TITLE = @"Choose Unlock Code";
NSString *VERIFY_CODE_TITLE = @"Verify Unlock Code";
NSString *ENTER_CODE_TITLE = @"Enter Unlock Code";

NSTimeInterval const RESTART_DELAY = 1.0;
NSTimeInterval const STAR_ANIMATION_DURATION = 0.4;

void disableInput()
{
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}

void enableInput()
{
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

void callAfter(NSTimeInterval seconds, void (^block)())
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC), dispatch_get_current_queue(), block);
}

}

@implementation UnlockViewController

@synthesize mode = mode_;
@synthesize code = code_;

@synthesize onCodeSet = onCodeSet_;
@synthesize onCodeAccepted = onCodeAccepted_;
@synthesize onCodeRejected = onCodeRejected_;

@synthesize titleLabel = titleLabel_;
@synthesize subtitleLabel = subtitleLabel_;
@synthesize digit1 = digit1_;
@synthesize digit2 = digit2_;
@synthesize digit3 = digit3_;
@synthesize digit4 = digit4_;
@synthesize unlockCodeEdit = unlockCodeEdit_;

+ (UnlockViewController *)chooseScreen
{
	UnlockViewController *screen = [[[UnlockViewController alloc] initWithNibName:nil bundle:nil] autorelease];
	screen.mode = UnlockViewControllerModeChoose;
	
	return screen;
}

+ (UnlockViewController *)verifyScreen:(NSString *)code
{
	assert([code length] == UnlockViewControllerCodeLength);

	UnlockViewController *screen = [[[UnlockViewController alloc] initWithNibName:nil bundle:nil] autorelease];
	screen.mode = UnlockViewControllerModeVerify;
	screen.code = code;
	
	return screen;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.unlockCodeEdit addTarget:self action:@selector(onTextChanged:) forControlEvents:UIControlEventEditingChanged];
	
	switch (self.mode)
	{
	case UnlockViewControllerModeChoose:
		self.titleLabel.text = CHOOSE_CODE_TITLE;
		break;
	case UnlockViewControllerModeVerify:
		self.titleLabel.text = ENTER_CODE_TITLE;
		break;
	default:
		assert(false);
		break;
	}
	
	self.subtitleLabel.text = @"";
	state_ = 0;
	
	assert(UnlockViewControllerCodeLength == 4);
	digits_[0] = self.digit1;
	digits_[1] = self.digit2;
	digits_[2] = self.digit3;
	digits_[3] = self.digit4;
	
	// Check that the code is set
	if (self.mode == UnlockViewControllerModeVerify)
	{
		assert([self.code length] == UnlockViewControllerCodeLength);
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.unlockCodeEdit becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

	self.code = nil;
	
	self.onCodeSet = nil;
	self.onCodeAccepted = nil;
	self.onCodeRejected = nil;

	self.titleLabel = nil;
	self.subtitleLabel = nil;
	self.digit1 = nil;
	self.digit2 = nil;
	self.digit3 = nil;
	self.digit4 = nil;
	self.unlockCodeEdit = nil;
}

- (void)dismissKeyboard
{
	[self.unlockCodeEdit resignFirstResponder];
}

- (void)clearCode
{
	self.unlockCodeEdit.text = @"";
}

- (void)setText:(NSString *)title subtitle:(NSString *)subtitle
{
	self.titleLabel.text = title;
	self.subtitleLabel.text = subtitle;
}

- (void)resetAnimation
{
	for (size_t i = 0; i < UnlockViewControllerCodeLength; ++i)
	{
		digits_[i].transform = CGAffineTransformIdentity;
		digits_[i].alpha = 1;
	}
}

- (void)animateStarsFor:(NSTimeInterval)seconds 
	transform:(CGAffineTransform)transform 
	alpha:(CGFloat)alpha
	subtitle:(NSString *)subtitle
	subtitleAnimationStyle:(SubtitleAnimationStyle)subtitleAnimationStyle
	onCompletion:(void (^)(BOOL finished))onCompletion
{
	if (subtitleAnimationStyle == SubtitleAnimationStyleSlideIn)
	{
		self.subtitleLabel.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
		self.subtitleLabel.text = subtitle;
	}
	
	[UIView animateWithDuration:seconds
		animations:^{
			for (size_t i = 0; i < UnlockViewControllerCodeLength; ++i)
			{
				digits_[i].transform = transform;
				digits_[i].alpha = alpha;
			}
			
			switch (subtitleAnimationStyle)
			{
			case SubtitleAnimationStyleSlideIn:
				self.subtitleLabel.transform = CGAffineTransformIdentity;
				break;
			case SubtitleAnimationStyleSlideOut:
				self.subtitleLabel.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width, 0);
				break;
			default:
				assert(false);
				break;
			}
		}
		completion:onCompletion];
}

- (void)restart:(NSString *)title subtitle:(NSString *)subtitle
{
	[self clearCode];
	[self setText:title subtitle:subtitle];
	[self resetAnimation];
	enableInput();
}

- (void)restartAfter:(NSTimeInterval)seconds title:(NSString *)title subtitle:(NSString *)subtitle
{
	callAfter(seconds, ^{
		[self restart:title subtitle:subtitle];
	});
}

- (void)setChosenCode:(NSString *)code
{
	self.code = code;

	assert(state_ == 0);
	++state_;
	
	[self animateStarsFor:STAR_ANIMATION_DURATION 
		transform:CGAffineTransformMakeScale(0.01f, 1) 
		alpha:0 
		subtitle:@"" 
		subtitleAnimationStyle:SubtitleAnimationStyleSlideIn
		onCompletion:^(BOOL) {
			[self restart:VERIFY_CODE_TITLE subtitle:@""];
		}];
}

- (void)verifyChosenCode:(NSString *)code
{
	assert([self.code length] == UnlockViewControllerCodeLength);

	if ([code isEqualToString:self.code])
	{
		[self animateStarsFor:STAR_ANIMATION_DURATION 
			transform:CGAffineTransformMakeRotation(M_PI)
			alpha:0 
			subtitle:@"" 
			subtitleAnimationStyle:SubtitleAnimationStyleSlideIn
			onCompletion:^(BOOL) {
				enableInput();
				assert(self.onCodeSet);
				self.onCodeSet(code);
			}];
	}
	else
	{
		self.code = @"";
		state_ = 0;
		
		[self animateStarsFor:STAR_ANIMATION_DURATION 
			transform:CGAffineTransformMakeScale(0.01f, 1) 
			alpha:0 
			subtitle:@"Verification failed"
			subtitleAnimationStyle:SubtitleAnimationStyleSlideIn
			onCompletion:^(BOOL) {
				[self restart:CHOOSE_CODE_TITLE subtitle:@"Verification failed"];
			}];
	}
}

- (void)chooseCode:(NSString *)code
{
	switch (state_)
	{
	case 0:
		[self setChosenCode:code];
		break;
	case 1:
		[self verifyChosenCode:code];
		break;
	default:
		assert(false);
		break;
	}
}

- (void)acceptCode:(NSString *)code
{
	assert([code isEqualToString:self.code]);
	
	[self dismissKeyboard];
	
	[self animateStarsFor:STAR_ANIMATION_DURATION 
		transform:CGAffineTransformMakeRotation(M_PI)
		alpha:1
		subtitle:@""
		subtitleAnimationStyle:SubtitleAnimationStyleSlideOut
		onCompletion:^(BOOL) {
			enableInput();
			assert(self.onCodeAccepted);
			self.onCodeAccepted();
		}];
}

- (void)rejectCode:(NSString *)code
{
	assert(![code isEqualToString:self.code]);

	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	++state_;

	int attemptsLeft = UnlockViewControllerVerifyAttempts - state_;
	if (attemptsLeft > 0)
	{
		NSString *subtitle = attemptsLeft == 1
			? @"Wrong code. You have 1 attempt left."
			: [NSString stringWithFormat:@"Wrong code. You have %d attempts left.", attemptsLeft];
			
		[self animateStarsFor:STAR_ANIMATION_DURATION
			transform:CGAffineTransformMakeScale(0.01f, 1) 
			alpha:0 
			subtitle:subtitle
			subtitleAnimationStyle:SubtitleAnimationStyleSlideIn
			onCompletion:^(BOOL) {
				[self restart:ENTER_CODE_TITLE subtitle:subtitle];
			}];
	}
	else
	{
		[self dismissKeyboard];

		[self animateStarsFor:STAR_ANIMATION_DURATION
			transform:CGAffineTransformMakeScale(0.01f, 0.01f) 
			alpha:0 
			subtitle:@""
			subtitleAnimationStyle:SubtitleAnimationStyleSlideOut
			onCompletion:^(BOOL) {
				enableInput();
				assert(self.onCodeRejected);
				self.onCodeRejected();
			}];
	}
}

- (void)verifyCode:(NSString *)code
{
	if ([code isEqualToString:self.code])
	{
		[self acceptCode:code];
	}
	else
	{
		[self rejectCode:code];
	}
}

- (void)processCode:(NSString *)code
{
	disableInput();
	
	switch (self.mode)
	{
	case UnlockViewControllerModeChoose:
		[self chooseCode:code];
		break;
	case UnlockViewControllerModeVerify:
		[self verifyCode:code];
		break;
	default:
		assert(false);
		break;
	}
}

- (void)onTextChanged:(id)sender
{
	NSString *code = self.unlockCodeEdit.text;

	size_t length = [code length];
	for (size_t i = 0; i < UnlockViewControllerCodeLength; ++i)
	{
		digits_[i].hidden = i >= length;
	}
	
	if (length == UnlockViewControllerCodeLength)
	{
		[self processCode:code];
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	return [textField.text length] + [string length] <= UnlockViewControllerCodeLength;
}

@end
