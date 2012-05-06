#import "LostPassAppDelegate.h"
#import "RootViewController.h"
#import "LoginViewController.h"
#import "UnlockViewController.h"
#import "SmokeScreenView.h"
#import "Settings.h"

std::auto_ptr<LastPass::Parser> lastPassDatabase;

namespace
{

NSTimeInterval const SMOKE_SCREEN_ANIMATION_DURATION = 0.4;

}

@implementation LostPassAppDelegate

@synthesize window = window_;
@synthesize navigationController = navigationController_;

+ (void)resetDatabase
{
	lastPassDatabase.reset();
	[Settings setDatabase:@"" encryptionKey:@""];
}

+ (void)loadDatabase
{
	assert([Settings haveDatabaseAndKey]);
	lastPassDatabase.reset(new LastPass::Parser([[Settings database] UTF8String], [[Settings encryptionKey] UTF8String]));
}

- (void)pushWelcomeSequence
{
	LoginViewController *loginScreen = [[[LoginViewController alloc] initWithNibName:nil bundle:nil] autorelease];
	[self.navigationController presentModalViewController:loginScreen animated:NO];

	UnlockViewController *unlockScreen = [UnlockViewController chooseScreen];
	unlockScreen.onCodeSet = ^(NSString *code) { 
		[Settings setUnlockCode:code];
		[loginScreen dismissModalViewControllerAnimated:YES];
	};
	[loginScreen presentModalViewController:unlockScreen animated:NO];
	
	// Welcome screen
	UIViewController *welcomeScreen = [SmokeScreenView smokeScreenController:YES];
	[unlockScreen presentModalViewController:welcomeScreen animated:NO];
}

- (void)resetEverything:(SmokeScreenView *)smokeScreen
{
	[self.navigationController dismissModalViewControllerAnimated:NO];
	[self pushWelcomeSequence];

	[smokeScreen slideOut:SMOKE_SCREEN_ANIMATION_DURATION
		onCompletion:^ {
			[smokeScreen removeFromSuperview];
		}];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[Settings initialize];

	[self.window addSubview:self.navigationController.view];
	[self.window makeKeyAndVisible];
	
	BOOL haveCode = [Settings haveUnlockCode];
	BOOL haveDatabase = [Settings haveDatabaseAndKey];

	if (haveCode)
	{
		UIViewController *screen = nil;
		
		if (haveDatabase)
		{
			// The unlock code is set and we have the database downloaded.
			// Show the unlock screen and go straigh to the accounts.
			// This should be the most common sittuation.
			UnlockViewController *unlockScreen = [UnlockViewController verifyScreen:[Settings unlockCode]];
			
			unlockScreen.onCodeAccepted = ^{
				[LostPassAppDelegate loadDatabase];
				[self.navigationController dismissModalViewControllerAnimated:YES];
			};
			
			unlockScreen.onCodeRejected = ^{
				// Note: __block is needed to avoid a retain cycle within the block.
				__block SmokeScreenView *smokeScreen = [SmokeScreenView smokeScreenView];
				[self.window addSubview:smokeScreen];

				smokeScreen.onTouched = ^{
					[self resetEverything:smokeScreen];
				};
			
				[smokeScreen slideIn:SMOKE_SCREEN_ANIMATION_DURATION onCompletion:^{}];

				[LostPassAppDelegate resetDatabase];
			};
			
			screen = unlockScreen;
		}
		else
		{
			// The code is set, but there's no database, so there's no need for unlocking.
			// Go to the login screen.
			screen = [[[LoginViewController alloc] initWithNibName:nil bundle:nil] autorelease];
		}

		[self.navigationController presentModalViewController:screen animated:NO];
	}
	else
	{
		if (haveDatabase)
		{
			// We have the database, but no code has been set.  This is strange.
			// Just wipe the database and make the user login.
			[LostPassAppDelegate resetDatabase];
		}

		[self pushWelcomeSequence];
	}

	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 See also applicationDidEnterBackground:.
	 */
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	/*
	 Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
	 */
}

- (void)dealloc
{
	[navigationController_ release];
	[window_ release];

	[super dealloc];
}

@end
