#import "UnlockViewController.h"

@implementation UnlockViewController

@synthesize digit1 = digit1_;
@synthesize digit2 = digit2_;
@synthesize digit3 = digit3_;
@synthesize digit4 = digit4_;
@synthesize unlockCodeEdit = unlockCodeEdit_;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.unlockCodeEdit addTarget:self action:@selector(onTextChanged:) forControlEvents:UIControlEventEditingChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.unlockCodeEdit becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

	self.digit1 = nil;
	self.digit2 = nil;
	self.digit3 = nil;
	self.digit4 = nil;
	self.unlockCodeEdit = nil;
}

- (void)onTextChanged:(id)sender
{
	UIImageView *digits[4] = { self.digit1, self.digit2, self.digit3, self.digit4 };
	size_t length = [self.unlockCodeEdit.text length];
	for (size_t i = 0; i < 4; ++i)
	{
		digits[i].hidden = i >= length;
	}
	
	if (length == 4)
	{
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];

		if ([self.unlockCodeEdit.text isEqualToString:@"0000"])
		{
			[self.unlockCodeEdit resignFirstResponder];

			dispatch_after(dispatch_time(0, 1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
				[self dismissModalViewControllerAnimated:YES];
				[[UIApplication sharedApplication] endIgnoringInteractionEvents];
			});
		}
		else
		{
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			dispatch_after(dispatch_time(0, 1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
				self.unlockCodeEdit.text = @"";
				[[UIApplication sharedApplication] endIgnoringInteractionEvents];
			});
		}
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	return [textField.text length] + [string length] <= 4;
}

@end
