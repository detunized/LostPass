#import "RootViewController.h"
#import "AccountViewController.h"
#import "LastPassProxy.h"
#import "LostPassAppDelegate.h"

@implementation RootViewController

@synthesize searchBar = searchBar_;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.tableView.tableHeaderView = self.searchBar;
	self.navigationItem.title = NSLocalizedString(@"Accounts", @"Accounts");
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (displayIndex_.empty())
	{
		displayIndex_.reserve(lastPassDatabase->count());
		for (size_t i = 0, count = lastPassDatabase->count(); i < count; ++i)
		{
			displayIndex_.push_back(i);
		}
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return displayIndex_.size();
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}

	cell.textLabel.text = [NSString stringWithUTF8String:lastPassDatabase->accounts()[displayIndex_[indexPath.row]].name().c_str()];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	 AccountViewController *accountView = [[[AccountViewController alloc] initWithNibName:@"AccountViewController" bundle:nil] autorelease];
	 accountView.account = &lastPassDatabase->accounts()[displayIndex_[indexPath.row]];
	 [self.navigationController pushViewController:accountView animated:YES];
}

- (void)dealloc
{
	self.searchBar = nil;

	[super dealloc];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	std::string pattern = [searchText UTF8String];

	displayIndex_.clear();
	for (size_t i = 0, count = lastPassDatabase->count(); i < count; ++i)
	{
		if (lastPassDatabase->accounts()[i].name().find(pattern) != std::string::npos)
		{
			displayIndex_.push_back(i);
		}
	}

	[self.tableView reloadData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
	[searchBar setShowsCancelButton:YES animated:YES];
	return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
	[searchBar setShowsCancelButton:NO animated:YES];
	return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[self.searchBar resignFirstResponder];
}

@end
