enum
{
	UnlockViewControllerCodeLength = 4,
};

enum UnlockViewControllerMode
{
	UnlockViewControllerModeChoose,
	UnlockViewControllerModeVerify,
};

@interface UnlockViewController: UIViewController<UITextFieldDelegate>
{
	int state_;
}

@property(nonatomic, assign) UnlockViewControllerMode mode;
@property(nonatomic, copy) NSString *code;

@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UILabel *subtitleLabel;
@property(nonatomic, retain) IBOutlet UIImageView *digit1;
@property(nonatomic, retain) IBOutlet UIImageView *digit2;
@property(nonatomic, retain) IBOutlet UIImageView *digit3;
@property(nonatomic, retain) IBOutlet UIImageView *digit4;
@property(nonatomic, retain) IBOutlet UITextField *unlockCodeEdit;

@end
