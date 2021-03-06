@interface LoginViewController: UIViewController
{
@private
	BOOL allowCancel_;
}

@property(nonatomic, retain) IBOutlet UITextField *emailInput;
@property(nonatomic, retain) IBOutlet UITextField *passwordInput;
@property(nonatomic, retain) IBOutlet UIButton *loginButton;
@property(nonatomic, retain) IBOutlet UIButton *cancelButton;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *busyIndicator;
@property(nonatomic, retain) IBOutlet UILabel *errorLabel;

+ (LoginViewController *)loginScreen;
+ (LoginViewController *)cancelableLoginScreen;

- (IBAction)onEmailInputEditingChanged:(id)sender;
- (IBAction)onPasswordInputEditingChanged:(id)sender;
- (IBAction)onLoginButtonTouchUpInside:(id)sender;
- (IBAction)onCancelButtonTouchUpInside:(id)sender;

@end
