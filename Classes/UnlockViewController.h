@interface UnlockViewController: UIViewController<UITextFieldDelegate>
{
}

@property(nonatomic, retain) IBOutlet UIImageView *digit1;
@property(nonatomic, retain) IBOutlet UIImageView *digit2;
@property(nonatomic, retain) IBOutlet UIImageView *digit3;
@property(nonatomic, retain) IBOutlet UIImageView *digit4;
@property(nonatomic, retain) IBOutlet UITextField *unlockCodeEdit;

@end
