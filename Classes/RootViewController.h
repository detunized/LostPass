#import "LastPass.h"

@interface RootViewController: UITableViewController<UISearchBarDelegate>
{
	LastPass *lastPass_;
	std::vector<size_t> displayIndex_;
}

@property(nonatomic, retain) IBOutlet UISearchBar *searchBar;

@end
