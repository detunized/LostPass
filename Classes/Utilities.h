@interface UIView(FindFirstResponder)

- (UIView *)findFirstResponder;

@end

void disableApplicationInput();
void enableApplicationInput();

void callAfter(NSTimeInterval seconds, void (^block)());

inline char const *toC(NSString *nsString)
{
	return [nsString UTF8String];
}

inline std::string toStd(NSString *nsString)
{
	return toC(nsString);
}

inline NSString *toNs(char const *cString)
{
	return [NSString stringWithUTF8String:cString];
}

inline NSString *toNs(std::string const& stdString)
{
	return toNs(stdString.c_str());
}

std::ostream &operator <<(std::ostream &stream, CGPoint const &point);
std::ostream &operator <<(std::ostream &stream, CGSize const &size);
std::ostream &operator <<(std::ostream &stream, CGRect const &rect);