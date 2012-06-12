@interface NotifyingNavigationController: UINavigationController
{
}

@end

@protocol NotifyingNavigationControllerDelegate<UINavigationControllerDelegate>

@optional

- (void)navigationController:(UINavigationController *)navigationController willPopViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)navigationController:(UINavigationController *)navigationController didPopViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

