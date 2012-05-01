#import "UnlockViewController.h"

namespace
{

NSString *modeTitles[] = {
	@"Choose Unlock Code",
	@"Enter Unlock Code"
};

}

@implementation UnlockViewController

@synthesize mode = mode_;
@synthesize code = code_;
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

	self.titleLabel = nil;
	self.subtitleLabel = nil;
	self.digit1 = nil;
	self.digit2 = nil;
	self.digit3 = nil;
	self.digit4 = nil;
	self.unlockCodeEdit = nil;
}

- (void)setChosenCode:(NSString *)code
{
	self.code = code;

	assert(state_ == 0);
	++state_;

	dispatch_after(dispatch_time(0, 1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
		self.unlockCodeEdit.text = @"";
		self.titleLabel.text = @"Verify Unlock Code";
		self.subtitleLabel.text = @"";
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	});
}

- (void)verifyChosenCode:(NSString *)code
{
	assert([self.code length] == UnlockViewControllerCodeLength);

	if ([code isEqualToString:self.code])
	{
		[self.unlockCodeEdit resignFirstResponder];

		dispatch_after(dispatch_time(0, 1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
			[self dismissModalViewControllerAnimated:YES];
			[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		});						
	}
	else
	{
		self.code = code;
		state_ = 0;
		dispatch_after(dispatch_time(0, 1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
			self.unlockCodeEdit.text = @"";
			self.titleLabel.text = @"Choose Unlock Code";
			self.subtitleLabel.text = @"Verification failed";
			[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		});
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

	[self.unlockCodeEdit resignFirstResponder];

	dispatch_after(dispatch_time(0, 1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
		[self dismissModalViewControllerAnimated:YES];
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	});
}

- (void)rejectCode:(NSString *)code
{
	assert(![code isEqualToString:self.code]);

	++state_;
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

	dispatch_after(dispatch_time(0, 1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
		self.unlockCodeEdit.text = @"";
		self.titleLabel.text = @"Enter Unlock Code";
		self.subtitleLabel.text = [NSString stringWithFormat:@"Wrong code. You have %d attempts left.", 3 - state_];
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	});
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
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	
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
	UIImageView *digits[4] = {self.digit1, self.digit2, self.digit3, self.digit4};
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
