#import "LastPassParser.h"

extern std::auto_ptr<LastPass::Parser> lastPassDatabase;

@interface LostPassAppDelegate: NSObject<UIApplicationDelegate>
{
}

@property(nonatomic, retain) IBOutlet UIWindow *window;
@property(nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
