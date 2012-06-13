#import "AccountViewController.h"
#import "Utilities.h"

namespace
{

enum TableRows
{
	TableRowName,
	TableRowUsername,
	TableRowPassword,

	TableRowCount
};

NSTimeInterval const MESSAGE_SHOW_DURATION = 1;

}

@implementation AccountViewController

@synthesize message = message_;
@synthesize adBannerView = adBannerView_;

+ (AccountViewController *)accountScreen:(LastPass::Parser::Account const *)account
{
	AccountViewController *controller = [[[AccountViewController alloc] 
		initWithNibName:@"AccountViewController" 
		bundle:nil] autorelease];
	controller->account_ = account;
	return controller;
}

- (void)dealloc
{
	self.message = nil;
	self.adBannerView = nil;

	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	self.message = @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return TableRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *const cellIdentifier = @"cell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifier] autorelease];
	}

	SEL copyAction = nil;
	NSString *name = nil;
	std::string const *value = 0;

	switch (indexPath.row)
	{
	case TableRowName:
		name = NSLocalizedString(@"Name", 0);
		value = &account_->name();
		break;
	case TableRowUsername:
		name = NSLocalizedString(@"Username", 0);
		value = &account_->username();
		copyAction = @selector(copyUsername:);
		break;
	case TableRowPassword:
		name = NSLocalizedString(@"Password", 0);
		value = &account_->password();
		copyAction = @selector(copyPassword:);
		break;
	}

	cell.textLabel.text = name;
	cell.detailTextLabel.text = [NSString stringWithUTF8String:value->c_str()];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	if (copyAction)
	{
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button addTarget:self action:copyAction forControlEvents:UIControlEventTouchUpInside];

		UIImage *image = [UIImage imageNamed:@"copy.png"];
		[button setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
		[button setImage:image forState:UIControlStateNormal];
		[button setImage:[UIImage imageNamed:@"copy-pressed.png"] forState:UIControlStateHighlighted];
		
		cell.accessoryView = button;
	}
	else
	{
		cell.accessoryView = nil;
	}

	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return self.message;
}

- (void)updateMessage:(NSString *)message
{
	if (![message isEqualToString:self.message])
	{
		self.message = message;
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
	}
}

- (void)copyToClipboard:(std::string const &)text description:(NSString *)description
{
	[UIPasteboard generalPasteboard].string = [NSString stringWithUTF8String:text.c_str()];
	
	// Show a message for a short period of time.
	[self updateMessage:[NSString stringWithFormat:NSLocalizedString(@"%@ is copied to clipboard", 0), description]];
	callAfter(MESSAGE_SHOW_DURATION, ^{ [self updateMessage:@""]; });
}

- (void)copyUsername:(id)sender
{
	[self copyToClipboard:account_->username() description:NSLocalizedString(@"Username", 0)];
}

- (void)copyPassword:(id)sender
{
	[self copyToClipboard:account_->password() description:NSLocalizedString(@"Password", 0)];
}

#pragma mark -
#pragma mark ADBannerViewDelegate

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	self.adBannerView.hidden = NO;
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	self.adBannerView.hidden = YES;
}

@end
