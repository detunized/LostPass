#import "RootViewController.h"
#import "AccountViewController.h"
#import "LoginViewController.h"
#import "LastPassProxy.h"
#import "LostPassAppDelegate.h"

@implementation RootViewController

@synthesize searchBar = searchBar_;

- (void)setInitialIndex
{
	displayIndex_.clear();

	assert(database_.get());
	displayIndex_.reserve(database_->count());
	for (size_t i = 0, count = database_->count(); i < count; ++i)
	{
		displayIndex_.push_back(i);
	}
}

- (void)resetView
{
	[self setInitialIndex];
	[self.tableView reloadData];
	
	self.searchBar.text = @"";
}

- (void)setDatabase:(std::auto_ptr<LastPass::Parser>)database
{
	assert(database.get());

	database_ = database;
	[self resetView];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.tableView.tableHeaderView = self.searchBar;
	self.navigationItem.title = NSLocalizedString(@"Accounts", 0);
	
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
		target:self 
		action:@selector(onRefresh:)] autorelease];
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

	cell.textLabel.text = [NSString stringWithUTF8String:database_->accounts()[displayIndex_[indexPath.row]].name().c_str()];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.navigationController
		pushViewController:[AccountViewController accountScreen:&database_->accounts()[displayIndex_[indexPath.row]]]
		animated:YES];
}

- (void)dealloc
{
	self.searchBar = nil;

	[super dealloc];
}

- (void)onRefresh:(id)sender
{
	[self presentModalViewController:[LoginViewController cancelableLoginScreen] animated:YES];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	std::string pattern = [searchText UTF8String];

	displayIndex_.clear();
	for (size_t i = 0, count = database_->count(); i < count; ++i)
	{
		if (database_->accounts()[i].name().find(pattern) != std::string::npos)
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
