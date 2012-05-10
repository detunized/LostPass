#import "LoginViewController.h"
#import "LastPassProxy.h"
#import "LostPassAppDelegate.h"
#import "Settings.h"

#import "LastPassParser.h"

@implementation LoginViewController

@synthesize emailInput = emailInput_;
@synthesize passwordInput = passwordInput_;
@synthesize loginButton = loginButton_;
@synthesize cancelButton = cancelButton_;
@synthesize busyIndicator = busyIndicator_;
@synthesize errorLabel = errorLabel_;

+ (LoginViewController *)loginScreen:(BOOL)allowCancel
{
	LoginViewController *controller = [[[LoginViewController alloc] initWithNibName:nil bundle:nil] autorelease];
	controller->allowCancel_ = allowCancel;
	return controller;
}

+ (LoginViewController *)loginScreen
{
	return [LoginViewController loginScreen:NO];
}

+ (LoginViewController *)cancelableLoginScreen
{
	return [LoginViewController loginScreen:YES];
}

- (void)setupCustomButton:(UIButton *)button
{
	button.layer.cornerRadius = 6;
	button.layer.borderWidth = 1;
	button.layer.borderColor = [UIColor lightGrayColor].CGColor;
	button.clipsToBounds = YES;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self setupCustomButton:self.loginButton];
	[self setupCustomButton:self.cancelButton];
	
	self.cancelButton.hidden = !allowCancel_;

	self.emailInput.text = [Settings lastEmail];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	
	self.emailInput = nil;
	self.passwordInput = nil;
	self.loginButton = nil;
	self.cancelButton = nil;
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
	self.cancelButton.enabled = enable;
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

- (void)quit
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)parseAndQuit
{
	[LostPassAppDelegate loadDatabase];
	[self quit];
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
#ifdef CONFIG_USE_LOCAL_DATABASE
	[self parseAndQuit];
#else
	[self enableControls:NO];
	[self showBusyIndicator:YES];
	[self setErrorText:@""];
	
	[Settings setLastEmail:self.emailInput.text];

	downloadLastPassDatabase(
		self.emailInput.text, 
		self.passwordInput.text,
		
		^(NSString *databseBase64, NSString *keyBase64) {
			[self showBusyIndicator:NO];
			[Settings setDatabase:databseBase64 encryptionKey:keyBase64];
			[self parseAndQuit];
		},
		
		^(NSString *errorMessage) {
			[self enableControls:YES];
			[self showBusyIndicator:NO];
			[self setErrorText:errorMessage];
		}
	);
#endif
}

- (IBAction)onCancelButtonTouchUpInside:(id)sender
{
	[self quit];
}

@end
