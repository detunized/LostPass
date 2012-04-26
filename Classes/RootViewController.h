#import "LastPassParser.h"

@interface RootViewController: UITableViewController<UISearchBarDelegate>
{
	LastPassParser *lastPass_;
	std::vector<size_t> displayIndex_;
}

@property(nonatomic, retain) IBOutlet UISearchBar *searchBar;

@end
