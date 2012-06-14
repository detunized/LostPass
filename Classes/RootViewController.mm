#import "RootViewController.h"
#import "AccountViewController.h"
#import "LoginViewController.h"
#import "LastPassProxy.h"
#import "LostPassAppDelegate.h"
#import "Settings.h"
#import "Utilities.h"

@implementation RootViewController

@synthesize accountNameToIndexMap = accountNameToIndexMap_;
@synthesize searchBar = searchBar_;

- (void)setInitialIndex
{
	assert(database_.get());
	
	// Cache NS strings.
	self.accountNameToIndexMap = [NSMutableArray arrayWithCapacity:database_->count()];
	for (size_t i = 0, count = database_->count(); i < count; ++i)
	{
		[self.accountNameToIndexMap addObject:[NSDictionary dictionaryWithObjectsAndKeys:
				toNs(database_->accounts()[i].name()), @"name",
				[NSNumber numberWithUnsignedInt:i], @"index",
				nil]];
	}

	// Sort by name
	[self.accountNameToIndexMap sortUsingComparator:^(id left, id right){
		return [[left objectForKey:@"name"] caseInsensitiveCompare:[right objectForKey:@"name"]];
	}];

	// Initial index.
	displayIndex_.clear();

	assert([self.accountNameToIndexMap count] == database_->count());
	displayIndex_.reserve([self.accountNameToIndexMap count]);
	for (size_t i = 0, count = [self.accountNameToIndexMap count]; i < count; ++i)
	{
		displayIndex_.push_back(i);
	}
}

- (void)resetView
{
	// Go back to the account list view.
	[self.navigationController popToRootViewControllerAnimated:NO];

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

- (void)showAccount:(size_t)index animated:(BOOL)animated
{
	[self.navigationController
		pushViewController:[AccountViewController accountScreen:&database_->accounts()[index]]
		animated:animated];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationController.delegate = self;
	
	self.tableView.tableHeaderView = self.searchBar;
	self.navigationItem.title = NSLocalizedString(@"Accounts", 0);

	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
		target:self 
		action:@selector(onRefresh:)] autorelease];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	assert(database_.get());
	size_t index = [Settings openAccountIndex];
	if (index < database_->accounts().size())
	{
		[self showAccount:index animated:NO];
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

	cell.textLabel.text = [[self.accountNameToIndexMap objectAtIndex:displayIndex_[indexPath.row]] objectForKey:@"name"];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	size_t index = [[[self.accountNameToIndexMap objectAtIndex:displayIndex_[indexPath.row]] objectForKey:@"index"] unsignedIntValue];
	[self showAccount:index animated:YES];
	[Settings setOpenAccountIndex:(int)index];
}

- (void)dealloc
{
	self.searchBar = nil;
	self.accountNameToIndexMap = nil;

	[super dealloc];
}

- (void)onRefresh:(id)sender
{
	[self presentModalViewController:[LoginViewController cancelableLoginScreen] animated:YES];
}

#pragma mark -
#pragma mark NotifyingNavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController 
	willPopViewController:(UIViewController *)viewController 
	animated:(BOOL)animated
{
	[Settings setOpenAccountIndex:-1];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	displayIndex_.clear();
	
	assert([self.accountNameToIndexMap count] == database_->count());
	for (size_t i = 0, count = [self.accountNameToIndexMap count]; i < count; ++i)
	{
		if ([[[self.accountNameToIndexMap objectAtIndex:i] objectForKey:@"name"] rangeOfString:searchText 
			options:NSCaseInsensitiveSearch].length > 0)
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
