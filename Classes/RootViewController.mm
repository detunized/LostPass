#import "RootViewController.h"
#import "AccountViewController.h"

@implementation RootViewController

@synthesize searchBar = searchBar_;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	NSBundle *mainBundle = [NSBundle mainBundle];
	lastPass_ = new LastPass(
		[[mainBundle pathForResource:@"account" ofType:@"dump"] UTF8String],
		[[mainBundle pathForResource:@"credentials" ofType:@"txt"] UTF8String]
	);

	self.tableView.tableHeaderView = self.searchBar;
	self.navigationItem.title = NSLocalizedString(@"Accounts", @"Accounts");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return lastPass_->get_accounts().size();
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}

	cell.textLabel.text = [NSString stringWithUTF8String:lastPass_->get_accounts()[indexPath.row].name().c_str()];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	 AccountViewController *accountView = [[[AccountViewController alloc] initWithNibName:@"AccountViewController" bundle:nil] autorelease];
	 accountView.account = &lastPass_->get_accounts()[indexPath.row];
	 [self.navigationController pushViewController:accountView animated:YES];
}

- (void)dealloc
{
	delete lastPass_;
	lastPass_ = 0;

	searchBar_ = nil;

	[super dealloc];
}

@end
