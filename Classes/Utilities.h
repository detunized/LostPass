@interface UIView(FindFirstResponder)

- (UIView *)findFirstResponder;

@end

void disableApplicationInput();
void enableApplicationInput();

void callAfter(NSTimeInterval seconds, void (^block)());

std::ostream &operator <<(std::ostream &stream, CGPoint const &point);
std::ostream &operator <<(std::ostream &stream, CGSize const &size);
std::ostream &operator <<(std::ostream &stream, CGRect const &rect);