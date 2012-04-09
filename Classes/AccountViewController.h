#import "LastPass.h"

@interface AccountViewController: UITableViewController
{
}

@property(nonatomic, assign) LastPass::Account const *account;

@end
