#import "Utilities.h"

@implementation UIView(FindFirstResponder)

// This code comes from http://stackoverflow.com/questions/1823317/
// Thanks Thomas Mueller
- (UIView *)findFirstResponder
{
	if (self.isFirstResponder)
	{
		return self;
	}

	for (UIView *view in self.subviews)
	{
		if (UIView *responder = [view findFirstResponder])
		{
			return responder;
		}
	}

	return nil;
}

@end

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

std::ostream &operator <<(std::ostream &stream, CGPoint const &point)
{
	return stream << point.x << ", " << point.y;
}

std::ostream &operator <<(std::ostream &stream, CGSize const &size)
{
	return stream << size.width << ", " << size.height;
}

std::ostream &operator <<(std::ostream &stream, CGRect const &rect)
{
	return stream << rect.origin << ", " << rect.size;
}
