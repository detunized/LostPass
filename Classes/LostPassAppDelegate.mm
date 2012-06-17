#import "LostPassAppDelegate.h"
#import "LoginViewController.h"
#import "UnlockViewController.h"
#import "Settings.h"
#import "Utilities.h"

namespace
{

NSTimeInterval const AUTOLOCK_TIME = 15;

NSTimeInterval const SMOKE_SCREEN_ANIMATION_DURATION = 0.4;
NSTimeInterval const RESET_ANIMATION_DURATION = 2;

NSString *WELCOME_MESSAGE =
	@"Welcome to LostPass!\n\n"
	@"Before you start please choose your personal 4-digit unlock code.\n\n"
	@"Tap to continue.";

NSString *WELCOME_BACK_MESSAGE =
	@"Welcome back to LostPass!\n\n"
	@"The app has been reset. Please choose your new personal 4-digit unlock code.\n\n"
	@"Tap to continue.";

NSString *RESET_MESSAGE =
	@"Hi, this is LostPass!\n\n"
	@"You entered the unlock code incorrectly too many times. The app is going to reset itself and you'll have to start over.  See you in a moment.\n\n"
	@"Tap to continue.";
	
BOOL databaseLoaded_ = NO;

}

@implementation LostPassAppDelegate

@synthesize modalScreens = modalScreens_;
@synthesize smokeScreen = smokeScreen_;
@synthesize curtain = curtain_;
@synthesize window = window_;
@synthesize navigationController = navigationController_;
@synthesize rootController = rootController_;

+ (LostPassAppDelegate *)instance
{
	return [UIApplication sharedApplication].delegate;
}

+ (void)setDatabaseToRoot:(std::auto_ptr<LastPass::Parser>)database
{
	[[self instance].rootController setDatabase:database];
}

+ (void)setEmptyDatabaseToRoot
{
	[self setDatabaseToRoot:std::auto_ptr<LastPass::Parser>(new LastPass::Parser())];
}

+ (void)resetDatabase
{
	[self setEmptyDatabaseToRoot];
	[Settings setDatabase:@"" encryptionKey:@""];
	databaseLoaded_ = NO;
}

+ (void)loadDatabase
{
	assert([Settings haveDatabaseAndKey]);
	[self setDatabaseToRoot:std::auto_ptr<LastPass::Parser>(new LastPass::Parser(
		[[Settings database] UTF8String], 
		[[Settings encryptionKey] UTF8String]))];
	databaseLoaded_ = YES;
}

- (void)showCurtain
{
	self.curtain = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"curtain.png"]] autorelease];
	[self.window addSubview:self.curtain];
}

- (void)hideCurtain
{
	[self.curtain removeFromSuperview];
	self.curtain = nil;
}

- (void)hideSmokeScreen
{
	[self.smokeScreen removeFromSuperview];
	self.smokeScreen = nil;
}

- (void)pushScreen:(UIViewController *)screen animated:(BOOL)animated
{
	// Push onto the last modal screen (if any).
	[[self.modalScreens count] == 0 ? self.navigationController : [self.modalScreens lastObject]
		presentModalViewController:screen
		animated:animated];

	[self.modalScreens addObject:screen];
}

- (void)popScreenAnimated:(BOOL)animated
{
	if ([self.modalScreens count] > 0)
	{
		[[self.modalScreens lastObject] dismissModalViewControllerAnimated:animated];
		[self.modalScreens removeLastObject];
	}
}

- (void)popAllScreens
{
	// We need to call this even if the stack it empty.  Root view could have opened
	// modal views of its own.  They won't be in the stack, but they will be killed
	// with this call as well.
	[self.navigationController dismissModalViewControllerAnimated:NO];
	[self.modalScreens removeAllObjects];
}

- (void)pushLoginScreen
{
	[self pushScreen:[LoginViewController loginScreen] animated:NO];
}

- (void)pushWelcomeSequence:(NSString *)welcomeText
{
	[self pushLoginScreen];

	UnlockViewController *unlockScreen = [UnlockViewController chooseScreen];
	unlockScreen.onCodeSet = ^(NSString *code) { 
		[Settings setUnlockCode:code];
		[self popScreenAnimated:YES];
	};
	[self pushScreen:unlockScreen animated:NO];
	
	// Welcome screen
	UIViewController *welcomeScreen = [SmokeScreenView 
		smokeScreenController:welcomeText 
		onTouched:^{ [self popScreenAnimated:NO]; }];
	[self pushScreen:welcomeScreen animated:NO];
}

- (void)resetEverything
{
	assert(self.smokeScreen);

	[self popAllScreens];
	[self pushWelcomeSequence:WELCOME_BACK_MESSAGE];
	
	// Simulate some busy work by showing the spinning star to the user.
	UIActivityIndicatorView *busyIcon = [[[UIActivityIndicatorView alloc] 
		initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
	busyIcon.frame = CGRectOffset(
		busyIcon.frame, 
		self.smokeScreen.frame.size.width / 2 - busyIcon.frame.size.width / 2, 
		self.smokeScreen.frame.size.height / 2 - busyIcon.frame.size.height / 2 );
	[self.smokeScreen addSubview:busyIcon];
	[busyIcon startAnimating];
	
	dispatch_after(
		dispatch_time(DISPATCH_TIME_NOW, RESET_ANIMATION_DURATION * NSEC_PER_SEC), 
		dispatch_get_current_queue(), 
		^{
			[self.smokeScreen slideOut:SMOKE_SCREEN_ANIMATION_DURATION
				onCompletion:^ {
					[self.smokeScreen removeFromSuperview];
					self.smokeScreen = nil;
				}];
		});
}

- (void)pushUnlockScreen
{
	assert([Settings haveUnlockCode]);
	assert([Settings haveDatabaseAndKey]);
	
	UnlockViewController *screen = [UnlockViewController verifyScreen:[Settings unlockCode]];
	
	screen.onCodeAccepted = ^{
		[Settings setFailedUnlockAttempts:0];

		if (!databaseLoaded_)
		{
			[LostPassAppDelegate loadDatabase];
		}

		[self popScreenAnimated:YES];
	};
	
	screen.onCodeRejected = ^{
		// Note: __block is needed to avoid a retain cycle within the block.
		self.smokeScreen = [SmokeScreenView 
			smokeScreenView:RESET_MESSAGE
			onTouched:^{ 
				[self resetEverything]; 
			}];
		[self.window addSubview:self.smokeScreen];

		[self.smokeScreen slideIn:SMOKE_SCREEN_ANIMATION_DURATION onCompletion:^{}];

		[Settings setWasReset:YES];
		[Settings setUnlockCode:@""];
		[LostPassAppDelegate resetDatabase];
		[Settings setFailedUnlockAttempts:0];
	};
	
	[self pushScreen:screen animated:NO];
}

- (void)pushScreens
{
	BOOL haveCode = [Settings haveUnlockCode];
	BOOL haveDatabase = [Settings haveDatabaseAndKey];

	if (haveCode)
	{
		if (haveDatabase)
		{
			// The unlock code is set and we have the database downloaded.
			// Show the unlock screen and go straigh to the accounts.
			// This should be the most common sittuation.
			[self pushUnlockScreen];
		}
		else
		{
			// The code is set, but there's no database, so there's no need for unlocking.
			// Go to the login screen.
			[self pushLoginScreen];
		}
	}
	else
	{
		if (haveDatabase)
		{
			// We have the database, but no code has been set.  This is strange.
			// Just wipe the database and make the user login.
			[LostPassAppDelegate resetDatabase];
		}

		[self pushWelcomeSequence:[Settings wasReset] ? WELCOME_BACK_MESSAGE : WELCOME_MESSAGE];
	}
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[Settings initialize];
	[LostPassAppDelegate setEmptyDatabaseToRoot];

	[self.window addSubview:self.navigationController.view];
	[self.window makeKeyAndVisible];
	
	self.modalScreens = [NSMutableArray arrayWithCapacity:4];
	
	return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	[self popAllScreens];
	[self hideCurtain];
	[self pushScreens];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Kill a keyboard if it's shown.
	[[self.window findFirstResponder] resignFirstResponder];

	[self popAllScreens];
	[self hideSmokeScreen];
	[self showCurtain];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
}

- (void)dealloc
{
	self.modalScreens = nil;
	self.smokeScreen = nil;
	self.curtain = nil;

	[rootController_ release];
	[navigationController_ release];
	[window_ release];

	[super dealloc];
}

@end
