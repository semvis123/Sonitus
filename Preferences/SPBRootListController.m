#include "SPBRootListController.h"

@implementation SPBRootListController

-(instancetype)init {
	self = [super init];

	if (self) {
		HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
		appearanceSettings.tintColor = [UIColor colorWithRed:0.1f green:0.45f blue:0.55f alpha:1];
		appearanceSettings.tableViewCellSeparatorColor = [UIColor clearColor];
		appearanceSettings.largeTitleStyle = HBAppearanceSettingsLargeTitleStyleNever;
		appearanceSettings.userInterfaceStyle = UIUserInterfaceStyleDark;
		appearanceSettings.statusBarStyle = UIStatusBarStyleLightContent;
		appearanceSettings.navigationBarTitleColor = [UIColor whiteColor];
		appearanceSettings.navigationBarBackgroundColor = [UIColor colorWithRed:0 green:0.19f blue:0.25f alpha: 1];
		self.hb_appearanceSettings = appearanceSettings;
	}
	return self;
}

-(NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
		PSSpecifierCustom *headphonesListSpecifier = (PSSpecifierCustom *) [self specifierForID:@"HeadphonesList"];
		NSArray *btDevices = [[BluetoothManager sharedInstance] pairedDevices];
		NSMutableArray *btNames = [[NSMutableArray alloc] initWithCapacity:btDevices.count+1];
		if (headphonesListSpecifier) {
			for (BluetoothDevice *device in btDevices) {
				[btNames addObject:[device name]];
			}

			[headphonesListSpecifier setValues:btNames titles:btNames];
		}
	}

	return _specifiers;
}
@end
