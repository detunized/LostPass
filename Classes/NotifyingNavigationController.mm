#include "NotifyingNavigationController.h"

@implementation NotifyingNavigationController;

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
	id delegate = self.delegate; // To prevent warnings

	if (delegate && [delegate respondsToSelector:@selector(navigationController:willPopViewController:animated:)])
	{
		[delegate navigationController:self willPopViewController:[self.viewControllers lastObject] animated:animated];
	}

	UIViewController *popped = [super popViewControllerAnimated:animated];

	if (delegate && [delegate respondsToSelector:@selector(navigationController:didPopViewController:animated:)])
	{
		[delegate navigationController:self didPopViewController:popped animated:animated];
	}
	
	return popped;
}

@end
