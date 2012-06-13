#import "LastPassParser.h"

@interface AccountViewController: UITableViewController<ADBannerViewDelegate>
{
@private
	LastPass::Parser::Account const *account_;
}

@property(nonatomic, copy) NSString *message;

@property(nonatomic, retain) IBOutlet ADBannerView *adBannerView;

+ (AccountViewController *)accountScreen:(LastPass::Parser::Account const *)account;

@end
