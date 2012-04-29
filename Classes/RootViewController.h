@interface RootViewController: UITableViewController<UISearchBarDelegate>
{
	std::vector<size_t> displayIndex_;
}

@property(nonatomic, retain) IBOutlet UISearchBar *searchBar;

@end
