#import "UnlockViewController.h"

namespace
{

NSString *modeTitles[] = {
	@"Choose Unlock Code",
	@"Enter Unlock Code"
};

NSTimeInterval const RESTART_DELAY = 1.0;
NSTimeInterval const QUIT_DELAY = 1.0;

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
	
	self.titleLabel.text = modeTitles[self.mode];
	self.subtitleLabel.text = @"";
	state_ = 0;
	
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
	self.onCodeRejected = nil;

	self.titleLabel = nil;
	self.subtitleLabel = nil;
	self.digit1 = nil;
	self.digit2 = nil;
	self.digit3 = nil;
	self.digit4 = nil;
	self.unlockCodeEdit = nil;
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

- (void)restartAfter:(NSTimeInterval)seconds title:(NSString *)title subtitle:(NSString *)subtitle
{
	callAfter(seconds, ^{
		[self clearCode];
		[self setText:title subtitle:subtitle];
		enableInput();
	});
}

- (void)quitAfter:(NSTimeInterval)seconds
{
	[self.unlockCodeEdit resignFirstResponder];

	callAfter(seconds, ^{
		[self dismissModalViewControllerAnimated:YES];
		enableInput();
	});						
}

- (void)setChosenCode:(NSString *)code
{
	self.code = code;

	assert(state_ == 0);
	++state_;
	
	[self restartAfter:RESTART_DELAY title:@"Verify Unlock Code" subtitle:@""];
}

- (void)verifyChosenCode:(NSString *)code
{
	assert([self.code length] == UnlockViewControllerCodeLength);

	if ([code isEqualToString:self.code])
	{
		enableInput();
		
		assert(self.onCodeSet);
		self.onCodeSet(code);
	}
	else
	{
		self.code = @"";
		state_ = 0;
		
		[self restartAfter:RESTART_DELAY title:@"Choose Unlock Code" subtitle:@"Verification failed"];
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

	[self quitAfter:QUIT_DELAY];
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
			? @"Wrong code. You have 1 attempt left"
			: [NSString stringWithFormat:@"Wrong code. You have %d attempts left", attemptsLeft];
	
		[self restartAfter:RESTART_DELAY title:@"Enter Unlock Code" subtitle:subtitle];
	}
	else
	{
		enableInput();
	
		assert(self.onCodeRejected);
		self.onCodeRejected();
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

	assert(UnlockViewControllerCodeLength == 4);
	UIImageView *digits[UnlockViewControllerCodeLength] = {self.digit1, self.digit2, self.digit3, self.digit4};
	size_t length = [code length];
	for (size_t i = 0; i < UnlockViewControllerCodeLength; ++i)
	{
		digits[i].hidden = i >= length;
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