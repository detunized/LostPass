#import "LoginViewController.h"
#import "LastPassProxy.h"
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
	
#ifdef CONFIG_USE_LOCAL_DATABASE
	LastPass::Parser parser(file_as_c_string(@"account.dump"), file_as_c_string(@"key.txt"));
#else
	downloadLastPassDatabase(
		self.emailInput.text, 
		self.passwordInput.text,
		
		^(NSString *databseBase64, NSString *key) {
			[self showBusyIndicator:NO];
			
			std::vector<uint8_t> key_u8;
			key_u8.reserve([key length]);
			for (size_t i = 0, count = [key length]; i < count; ++i)
			{
				key_u8.push_back(static_cast<uint8_t>([key characterAtIndex:i]));
			}
			
			LastPass::Parser parser([databseBase64 UTF8String], &key_u8[0]);
		},
		
		^(NSString *errorMessage) {
			[self enableControls:YES];
			[self showBusyIndicator:NO];
			[self setErrorText:errorMessage];
		}
	);
#endif
}

@end
