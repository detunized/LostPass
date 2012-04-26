#import "RootViewController.h"
#import "AccountViewController.h"
#import "LastPassProxy.h"

@implementation RootViewController

@synthesize searchBar = searchBar_;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	NSBundle *mainBundle = [NSBundle mainBundle];

	std::ifstream in([[mainBundle pathForResource:@"credentials" ofType:@"txt"] UTF8String]);
	std::string email;
	std::string password;
	in >> email >> password;
	
//	downloadLastPassAccounts([NSString stringWithUTF8String:email.c_str()], [NSString stringWithUTF8String:password.c_str()]);
	
	lastPass_ = new LastPassParser(
		[[mainBundle pathForResource:@"account" ofType:@"dump"] UTF8String],
		email.c_str(),
		password.c_str()
	);

	displayIndex_.reserve(lastPass_->count());
	for (size_t i = 0, count = lastPass_->count(); i < count; ++i)
	{
		displayIndex_.push_back(i);
	}

	self.tableView.tableHeaderView = self.searchBar;
	self.navigationItem.title = NSLocalizedString(@"Accounts", @"Accounts");
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

	cell.textLabel.text = [NSString stringWithUTF8String:lastPass_->accounts()[displayIndex_[indexPath.row]].name().c_str()];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	 AccountViewController *accountView = [[[AccountViewController alloc] initWithNibName:@"AccountViewController" bundle:nil] autorelease];
	 accountView.account = &lastPass_->accounts()[displayIndex_[indexPath.row]];
	 [self.navigationController pushViewController:accountView animated:YES];
}

- (void)dealloc
{
	delete lastPass_;
	lastPass_ = 0;
	
	self.searchBar = nil;

	[super dealloc];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	std::string pattern = [searchText UTF8String];

	displayIndex_.clear();
	for (size_t i = 0, count = lastPass_->count(); i < count; ++i)
	{
		if (lastPass_->accounts()[i].name().find(pattern) != std::string::npos)
		{
			displayIndex_.push_back(i);
		}
	}

	[self.tableView reloadData];
}

@end
