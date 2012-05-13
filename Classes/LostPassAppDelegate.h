#import "RootViewController.h"
#import "SmokeScreenView.h"

@interface LostPassAppDelegate: NSObject<UIApplicationDelegate>
{
}

@property(nonatomic, retain) NSMutableArray *modalScreens;
@property(nonatomic, retain) SmokeScreenView *smokeScreen;

@property(nonatomic, retain) IBOutlet UIWindow *window;
@property(nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property(nonatomic, retain) IBOutlet RootViewController *rootController;

+ (void)loadDatabase;

@end
