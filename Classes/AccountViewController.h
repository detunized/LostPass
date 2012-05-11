#import "LastPassParser.h"

@interface AccountViewController: UITableViewController
{
@private
	LastPass::Parser::Account const *account_;
}

+ (AccountViewController *)accountScreen:(LastPass::Parser::Account const *)account;

@end
