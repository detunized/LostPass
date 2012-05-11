#import "RootViewController.h"

@interface LostPassAppDelegate: NSObject<UIApplicationDelegate>
{
}

@property(nonatomic, retain) IBOutlet UIWindow *window;
@property(nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property(nonatomic, retain) IBOutlet RootViewController *rootController;

+ (void)loadDatabase;

@end
