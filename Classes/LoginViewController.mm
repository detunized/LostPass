#import "LoginViewController.h"

@implementation LoginViewController

@synthesize emailInput = emailInput_;
@synthesize passwordInput = passwordInput_;
@synthesize loginButton = loginButton_;
@synthesize busyIndicator = busyIndicator_;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.loginButton.layer.cornerRadius = 6;
	self.loginButton.layer.borderWidth = 1;
	self.loginButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.loginButton.clipsToBounds = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	
	self.emailInput = nil;
	self.passwordInput = nil;
	self.loginButton = nil;
	self.busyIndicator = nil;
}

- (IBAction)onLoginButtonTouchUpInside:(id)sender
{
	self.emailInput.enabled = NO;
	self.passwordInput.enabled = NO;
	self.loginButton.enabled = NO;
	self.busyIndicator.hidden = NO;
}

@end
