#import "LastPass.h"

@interface RootViewController: UITableViewController<UISearchBarDelegate>
{
	LastPass *lastPass_;
}

@property(nonatomic, retain) IBOutlet UISearchBar *searchBar;

@end
