@interface LoginViewController: UIViewController
{
}

@property(nonatomic, retain) IBOutlet UITextField *emailInput;
@property(nonatomic, retain) IBOutlet UITextField *passwordInput;
@property(nonatomic, retain) IBOutlet UIButton *loginButton;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *busyIndicator;

- (IBAction)onLoginButtonTouchUpInside:(id)sender;

@end
