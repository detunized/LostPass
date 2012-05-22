#import "Utilities.h"

void disableApplicationInput()
{
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}

void enableApplicationInput()
{
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

void callAfter(NSTimeInterval seconds, void (^block)())
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC), dispatch_get_current_queue(), block);
}
