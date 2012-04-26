#import "LastPassParser.h"

@interface RootViewController: UITableViewController<UISearchBarDelegate>
{
	LastPass::Parser *lastPass_;
	std::vector<size_t> displayIndex_;
}

@property(nonatomic, retain) IBOutlet UISearchBar *searchBar;

@end
