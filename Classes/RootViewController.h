#import "LastPassParser.h"

@interface RootViewController: UITableViewController<UINavigationControllerDelegate, UISearchBarDelegate>
{
@private
	std::auto_ptr<LastPass::Parser> database_;
	std::vector<size_t> displayIndex_;
}

@property(nonatomic, retain) NSMutableArray *accountNameToIndexMap;
@property(nonatomic, retain) IBOutlet UISearchBar *searchBar;

- (void)setDatabase:(std::auto_ptr<LastPass::Parser>)database;

@end
