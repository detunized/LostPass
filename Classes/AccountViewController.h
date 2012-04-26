#import "LastPassParser.h"

@interface AccountViewController: UITableViewController
{
}

@property(nonatomic, assign) LastPass::Parser::Account const *account;

@end
