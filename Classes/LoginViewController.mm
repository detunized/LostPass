#import "LoginViewController.h"
#import "LastPassProxy.h"

@implementation LoginViewController

@synthesize emailInput = emailInput_;
@synthesize passwordInput = passwordInput_;
@synthesize loginButton = loginButton_;
@synthesize busyIndicator = busyIndicator_;
@synthesize errorLabel = errorLabel_;

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
	self.errorLabel = nil;
}

- (void)enableLoginButton
{
	self.loginButton.enabled = [self.emailInput.text length] > 0 && [self.passwordInput.text length] > 0;
}

- (void)enableControls:(BOOL)enable
{
	self.emailInput.enabled = enable;
	self.passwordInput.enabled = enable;
	self.loginButton.enabled = enable;
}

- (void)setErrorText:(NSString *)text
{
	if ([text length] > 0)
	{
		self.errorLabel.text = text;
		self.errorLabel.hidden = NO;
	}
	else
	{
		self.errorLabel.hidden = YES;
	}

}

- (void)showBusyIndicator:(BOOL)show
{
	self.busyIndicator.hidden = !show;
	
	if (show)
	{
		[self.busyIndicator startAnimating];
	}
	else
	{
		[self.busyIndicator stopAnimating];
	}
}

- (IBAction)onEmailInputEditingChanged:(id)sender
{
	[self enableLoginButton];
}

- (IBAction)onPasswordInputEditingChanged:(id)sender
{
	[self enableLoginButton];
}

- (IBAction)onLoginButtonTouchUpInside:(id)sender
{
	[self enableControls:NO];
	[self showBusyIndicator:YES];
	[self setErrorText:@""];
	
	downloadLastPassDatabase(
		self.emailInput.text, 
		self.passwordInput.text,
		
		^(NSString *databseBase64) {
			[self showBusyIndicator:NO];
			NSLog(@"%@", databseBase64);
		},
		
		^(NSString *errorMessage) {
			[self enableControls:YES];
			[self showBusyIndicator:NO];
			[self setErrorText:errorMessage];
		}
	);
}

@end
