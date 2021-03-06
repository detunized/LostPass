#import "LastPassProxy.h"

@interface LastPassProxy: NSObject<UIWebViewDelegate>
{
	int state_;
}

@property(nonatomic, retain) UIWebView *browser;
@property(nonatomic, copy) NSString *username;
@property(nonatomic, copy) NSString *password;
@property(nonatomic, copy) SuccessBlock onSuccess;
@property(nonatomic, copy) ErrorBlock onError;

@end

@implementation LastPassProxy

@synthesize browser = browser_;
@synthesize username = username_;
@synthesize password = password_;
@synthesize onSuccess = onSuccess_;
@synthesize onError = onError_;

namespace
{
	enum State
	{
		STATE_INITIAL,
		STATE_HOME,
		STATE_LOGIN,
		STATE_DOWNLOAD,
		STATE_DONE,
		STATE_FAILED
	};
	
	NSString *jsCallPrefix = @"lastpass.";
}

- (id)init:(NSString *)username password:(NSString *)password onSuccess:(SuccessBlock)onSuccess onError:(ErrorBlock)onError
{
	if (self = [super init])
	{
		state_ = STATE_INITIAL;
	
		self.browser = [[[UIWebView alloc] init] autorelease];
		self.browser.delegate = self;
		
		self.username = username;
		self.password = password;
		
		self.onSuccess = onSuccess;
		self.onError = onError;
	}
	
	return self;
}

- (void)dealloc
{
	self.browser = nil;
	self.username = nil;
	self.password = nil;
	self.onSuccess = nil;
	self.onError = nil;

	[super dealloc];
}

- (void)start
{
	state_ = STATE_HOME;
	[self.browser loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://lastpass.com/mobile/"]]];
}

- (NSString *)executeJs:(NSString *)js
{
	return [self.browser stringByEvaluatingJavaScriptFromString:js];
}

- (void)injectJs
{
	[self executeJs:[NSString stringWithContentsOfFile:
		[[NSBundle mainBundle] pathForResource:@"lastpass" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil]];
}

- (void)processJsCall:(NSString *)call arguments:(NSString *)arguments
{
	if ([call isEqualToString:@"logged-in"])
	{
		state_ = STATE_DOWNLOAD;
	}
	else if ([call isEqualToString:@"downloaded"])
	{
		state_ = STATE_DONE;
		self.onSuccess([self executeJs:@"lastpass.database"], [self executeJs:@"lastpass.key"]);
	}
	else if ([call isEqualToString:@"login-failed"])
	{
		state_ = STATE_FAILED;
		self.onError(arguments);
	}
	else if ([call isEqualToString:@"download-failed"])
	{
		state_ = STATE_FAILED;
		self.onError(arguments);
	}
	
	if (state_ == STATE_DONE)
	{
		self.browser = nil;
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// Once the home page is loaded we need to inject our js code in it and proceed to login.
	if (state_ == STATE_HOME)
	{
		[self injectJs];

		state_ = STATE_LOGIN;
		[self executeJs:[NSString stringWithFormat:@"lastpass.download('%@', '%@')", self.username, self.password]];
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	self.onError(NSLocalizedString(@"Could not connect to LastPass.", 0));
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL *url = [request URL];

	if ([[url scheme] hasPrefix:jsCallPrefix])
	{
		[self processJsCall:[[url scheme] substringFromIndex:[jsCallPrefix length]]
			arguments:[[url resourceSpecifier] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

		return NO;
	}

	return YES;
}

@end

void downloadLastPassDatabase(NSString *username, NSString *password, SuccessBlock onSuccess, ErrorBlock onError)
{
	LastPassProxy *proxy = [[LastPassProxy alloc] init:username password:password onSuccess:onSuccess onError:onError];
	[proxy start];
}
