#import "AccountViewController.h"

namespace
{

enum TableRows
{
	TableRowName,
	TableRowUsername,
	TableRowPassword,

	TableRowCount
};

}

@implementation AccountViewController

+ (AccountViewController *)accountScreen:(LastPass::Parser::Account const *)account
{
	AccountViewController *controller = [[[AccountViewController alloc] 
		initWithNibName:@"AccountViewController" 
		bundle:nil] autorelease];
	controller->account_ = account;
	return controller;
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
	SEL copyAction = nil;
	NSString *name = nil;
	std::string const *value = 0;

	switch (indexPath.row)
	{
	case TableRowName:
		name = NSLocalizedString(@"Name", @"Name");
		value = &account_->name();
		break;
	case TableRowUsername:
		name = NSLocalizedString(@"Username", @"Username");
		value = &account_->username();
		copyAction = @selector(copyUsername:);
		break;
	case TableRowPassword:
		name = NSLocalizedString(@"Password", @"Password");
		value = &account_->password();
		copyAction = @selector(copyPassword:);
		break;
	}
	
	NSString *cellType = copyAction ? @"cell-with-copy-button" : @"cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType];
	if (!cell)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellType] autorelease];
		
		// These things are permanent and are set only once.
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

		if (copyAction)
		{
			UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
			[button addTarget:self action:copyAction forControlEvents:UIControlEventTouchUpInside];

			UIImage *image = [UIImage imageNamed:@"copy.png"];
			[button setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
			[button setImage:image forState:UIControlStateNormal];
			
			cell.accessoryView = button;
		}
	}

	// These might change when the cell is reused.
	cell.textLabel.text = name;
	cell.detailTextLabel.text = [NSString stringWithUTF8String:value->c_str()];

	return cell;
}

- (void)copyToClipboard:(std::string const &)text
{
	[UIPasteboard generalPasteboard].string = [NSString stringWithUTF8String:text.c_str()];
}

- (void)copyUsername:(id)sender
{
	[self copyToClipboard:account_->username()];
}

- (void)copyPassword:(id)sender
{
	[self copyToClipboard:account_->password()];
}

@end
