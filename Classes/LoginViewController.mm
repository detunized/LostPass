#import "LoginViewController.h"
#import "LastPassProxy.h"
#import "LostPassAppDelegate.h"
#import "Settings.h"

#import "LastPassParser.h"

namespace
{

enum MessageAnimationStyle
{
	MessageAnimationStyleSlideIn,
	MessageAnimationStyleSlideOut
};

NSTimeInterval const MESSAGE_SLIDE_IN_ANIMATION_DURATION = 0.4;
NSTimeInterval const MESSAGE_SLIDE_OUT_ANIMATION_DURATION = 0.2;
NSString *const WELCOME_MESSAGE = @"Please log into your LastPass account.";

}

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

- (void)animateMessage:(NSString *)text animationStyle:(MessageAnimationStyle)animationStyle onCompletion:(void (^)())onCompletion
{
	NSTimeInterval duration = 0;
	switch (animationStyle)
	{
	case MessageAnimationStyleSlideIn:
		self.errorLabel.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
		self.errorLabel.text = text;
		duration = MESSAGE_SLIDE_IN_ANIMATION_DURATION;
		break;
	case MessageAnimationStyleSlideOut:
		duration = MESSAGE_SLIDE_OUT_ANIMATION_DURATION; 
		break;
	default:
		assert(false);
		break;
	}
	
	[UIView animateWithDuration:duration
		animations:^{
			switch (animationStyle)
			{
			case MessageAnimationStyleSlideIn:
				self.errorLabel.transform = CGAffineTransformIdentity;
				break;
			case MessageAnimationStyleSlideOut:
				self.errorLabel.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width, 0);
				break;
			default:
				assert(false);
				break;
			}
		}
		completion:^(BOOL) {
			if (onCompletion)
			{
				onCompletion();
			}
		}];
}

- (void)showMessage:(NSString *)text onCompletion:(void (^)())onCompletion
{
	[self animateMessage:text animationStyle:MessageAnimationStyleSlideIn onCompletion:onCompletion];
}

- (void)hideMessage
{
	[self animateMessage:nil animationStyle:MessageAnimationStyleSlideOut onCompletion:nil];
}

- (void)clearErrorText
{
	self.errorLabel.text = @"";
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self clearErrorText];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self showMessage:WELCOME_MESSAGE onCompletion:nil];
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

- (void)showErrorAndRetry:(NSString *)text
{
	[self showBusyIndicator:NO];
	
	[self showMessage:text onCompletion:^{ 
		[self enableControls:YES]; 
	}];
}

- (void)quit
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)parseAndQuit
{
	[Settings setOpenAccountIndex:-1];
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
	[self hideMessage];
	
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
			[self showErrorAndRetry:errorMessage];
		}
	);
#endif
}

- (IBAction)onCancelButtonTouchUpInside:(id)sender
{
	[self quit];
}

@end
