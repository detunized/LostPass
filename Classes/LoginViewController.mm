#import "LoginViewController.h"
#import "LastPassProxy.h"
#import "LostPassAppDelegate.h"
#import "Settings.h"

#import "LastPassParser.h"

namespace
{

NSString *file_as_string(NSString *filename)
{
	return [NSString 
		stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@""]
		encoding:NSUTF8StringEncoding 
		error:nil
	];
}

char const *file_as_c_string(NSString *filename)
{
	return [file_as_string(filename) UTF8String];
}

}

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
	
	self.emailInput.text = [Settings lastEmail];
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

- (void)parseAndQuit:(NSString *)databseBase64 keyBase64:(NSString *)keyBase64
{
	lastPassDatabase.reset(new LastPass::Parser([databseBase64 UTF8String], [keyBase64 UTF8String]));
	[self dismissModalViewControllerAnimated:YES];
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
	[self parseAndQuit:file_as_string(@"account.dump") keyBase64:file_as_string(@"key.txt")];
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
			[self parseAndQuit:databseBase64 keyBase64:keyBase64];
		},
		
		^(NSString *errorMessage) {
			[self enableControls:YES];
			[self showBusyIndicator:NO];
			[self setErrorText:errorMessage];
		}
	);
#endif
}

#ifdef CONFIG_USE_LOCAL_DATABASE
- (void)viewDidAppear:(BOOL)animated
{
	dispatch_after(dispatch_time(0, 1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
		[self parseAndQuit:file_as_string(@"account.dump") keyBase64:file_as_string(@"key.txt")];
	});
}
#endif

@end
