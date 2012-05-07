@interface LoginViewController: UIViewController
{
}

@property(nonatomic, retain) IBOutlet UITextField *emailInput;
@property(nonatomic, retain) IBOutlet UITextField *passwordInput;
@property(nonatomic, retain) IBOutlet UIButton *loginButton;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *busyIndicator;
@property(nonatomic, retain) IBOutlet UILabel *errorLabel;

+ (LoginViewController *)loginScreen;

- (IBAction)onEmailInputEditingChanged:(id)sender;
- (IBAction)onPasswordInputEditingChanged:(id)sender;
- (IBAction)onLoginButtonTouchUpInside:(id)sender;

@end
