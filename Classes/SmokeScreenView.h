typedef void (^SmokeScreenViewOnTouched)();

@interface SmokeScreenView: UIView
{
}

@property(nonatomic, copy) SmokeScreenViewOnTouched onTouched;
@property(nonatomic, retain) IBOutlet UILabel *titleLabel;

+ (SmokeScreenView *)smokeScreenView:(NSString *)title onTouched:(SmokeScreenViewOnTouched)onTouched;
+ (UIViewController *)smokeScreenController:(NSString *)title onTouched:(SmokeScreenViewOnTouched)onTouched;

- (void)setTitle:(NSString *)title;

- (void)slideIn:(NSTimeInterval)seconds onCompletion:(void (^)())onCompletion;
- (void)slideOut:(NSTimeInterval)seconds onCompletion:(void (^)())onCompletion;

@end
