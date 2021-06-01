#include "HPBRootListController.h"

@implementation SPBRootListController

-(NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
		PSSpecifier *headphonesListSpecifier = [self specifierForID:@"HeadphonesList"];
		NSArray *btDevices = [[BluetoothManager sharedInstance] pairedDevices];
		NSMutableArray *btNames = [[NSMutableArray alloc] initWithCapacity:btDevices.count+1];
		if (headphonesListSpecifier) {
			for (int i = 0; i < btDevices.count; i++) {
				[btNames addObject:[btDevices[i] name]];
			}

			[headphonesListSpecifier setValues:btNames titles:btNames];
		}
	}

	return _specifiers;
}

-(void)viewDidLoad {
	[super viewDidLoad];
	self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
	self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
	[[self headerImageView] setContentMode:UIViewContentModeScaleAspectFill];
	[[self headerImageView] setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/headphonifyPreferences.bundle/banner.png"]];
	[[self headerImageView] setClipsToBounds:YES];
	[[self headerView] addSubview:[self headerImageView]];

	self.headerImageView.translatesAutoresizingMaskIntoConstraints = NO;
	[NSLayoutConstraint activateConstraints:@[
		[self.headerImageView.topAnchor constraintEqualToAnchor:self.headerView.topAnchor],
		[self.headerImageView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor],
		[self.headerImageView.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor],
		[self.headerImageView.bottomAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
	]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	tableView.tableHeaderView = [self headerView];
	tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
	return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

-(void)_returnKeyPressed:(id)arg1 {
	[self.view endEditing:YES];
}

-(void)twitter {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/semvis123"] options:@{} completionHandler:nil];
}
-(void)github {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/semvis123"] options:@{} completionHandler:nil];
}
-(void)donate {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.buymeacoffee.com/semvis123"] options:@{} completionHandler:nil];
}

-(void)respring:(id)sender {
	pid_t pid;
	const char *args[] = {"sbreload", NULL, NULL, NULL};
	posix_spawn(&pid, "usr/bin/sbreload", NULL, NULL, (char *const *)args, NULL);
}

@end
