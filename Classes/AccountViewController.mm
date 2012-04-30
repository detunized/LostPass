#import "AccountViewController.h"

@implementation AccountViewController

@synthesize account = account_;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
	
	SEL copyAction = nil;
	NSString *name = nil;
	std::string const *value = 0;

	switch (indexPath.row)
	{
	case 0:
		name = NSLocalizedString(@"Name", @"Name");
		value = &self.account->name();
		break;
	case 1:
		name = NSLocalizedString(@"Username", @"Username");
		value = &self.account->username();
		copyAction = @selector(copyUsername:);
		break;
	case 2:
		name = NSLocalizedString(@"Password", @"Password");
		value = &self.account->password();
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
		
		cell.accessoryView = button;
	}
    
    return cell;
}

- (void)copyToClipboard:(std::string const &)text
{
	[UIPasteboard generalPasteboard].string = [NSString stringWithUTF8String:text.c_str()];
}

- (void)copyUsername:(id)sender
{
	[self copyToClipboard:self.account->username()];
}

- (void)copyPassword:(id)sender
{
	[self copyToClipboard:self.account->password()];
}

@end
