enum
{
	UnlockViewControllerCodeLength = 4,
	UnlockViewControllerVerifyAttempts = 3,
};

enum UnlockViewControllerMode
{
	UnlockViewControllerModeChoose,
	UnlockViewControllerModeVerify,
};

typedef void (^UnlockViewControllerCodeSet)(NSString *code);
typedef void (^UnlockViewControllerCodeAccepted)();
typedef void (^UnlockViewControllerCodeRejected)();

@interface UnlockViewController: UIViewController<UITextFieldDelegate>
{
	int state_;
	UIImageView *digits_[UnlockViewControllerCodeLength];
}

@property(nonatomic, assign) UnlockViewControllerMode mode;
@property(nonatomic, copy) NSString *code;

@property(nonatomic, copy) UnlockViewControllerCodeSet onCodeSet;
@property(nonatomic, copy) UnlockViewControllerCodeAccepted onCodeAccepted;
@property(nonatomic, copy) UnlockViewControllerCodeRejected onCodeRejected;

@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UILabel *subtitleLabel;
@property(nonatomic, retain) IBOutlet UIImageView *digit1;
@property(nonatomic, retain) IBOutlet UIImageView *digit2;
@property(nonatomic, retain) IBOutlet UIImageView *digit3;
@property(nonatomic, retain) IBOutlet UIImageView *digit4;
@property(nonatomic, retain) IBOutlet UITextField *unlockCodeEdit;

+ (UnlockViewController *)chooseScreen;
+ (UnlockViewController *)verifyScreen:(NSString *)code;

@end
