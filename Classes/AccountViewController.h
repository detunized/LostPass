#import "LastPassParser.h"

@interface AccountViewController: UITableViewController
{
@private
	LastPass::Parser::Account const *account_;
}

@property(nonatomic, copy) NSString *message;

+ (AccountViewController *)accountScreen:(LastPass::Parser::Account const *)account;

@end
