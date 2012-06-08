@interface UIView(FindFirstResponder)

- (UIView *)findFirstResponder;

@end

void disableApplicationInput();
void enableApplicationInput();

void callAfter(NSTimeInterval seconds, void (^block)());
