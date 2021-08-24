#include "SPBSonyListController.h"

HBPreferences *preferences;

@implementation SPBSonyListController

-(instancetype)init {
	self = [super init];

	if (self) {
		preferences = [[HBPreferences alloc] initWithIdentifier:@"com.semvis.sonituspreferences"];
		[preferences registerDefaults:@{
			@"Enabled": @YES,
			@"HeadphonesName": @"WH-1000XM3",
			@"SonyWindReductionSupport": @YES,
			@"SonyNCValue": @0,
			@"SonyfocusOnVoiceNC": @NO,
			@"SonyASMValue": @20,
			@"SonyFocusOnVoiceASM": @NO
		}];
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
		_specifiers = [self loadSpecifiersFromPlistName:@"Sony" target:self];
		PSSpecifier *ASMTextSpecifier = [self specifierForID:@"ASMValueText"];
		[ASMTextSpecifier setName:[NSString stringWithFormat:@"Ambient sound level: %ld", [preferences integerForKey:@"SonyASMValue"]]];
		PSSpecifier *NCTextSpecifier = [self specifierForID:@"NCValueText"];
		[NCTextSpecifier setName:[NSString stringWithFormat:@"Ambient sound level: %ld", [preferences integerForKey:@"SonyNCValue"]]];
	}

	return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];
	if ([specifier.properties[@"key"] isEqualToString:@"SonyASMValue"]) {
		PSSpecifier *ASMTextSpecifier = [self specifierForID:@"ASMValueText"];
		[ASMTextSpecifier setName:[NSString stringWithFormat:@"Ambient sound level: %ld", [preferences integerForKey:@"SonyASMValue"]]];
		[self reloadSpecifiers];
	} else if ([specifier.properties[@"key"] isEqualToString:@"SonyNCValue"]) {
		PSSpecifier *NCTextSpecifier = [self specifierForID:@"NCValueText"];
		[NCTextSpecifier setName:[NSString stringWithFormat:@"Ambient sound level: %ld", [preferences integerForKey:@"SonyNCValue"]]];
		[self reloadSpecifiers];
	}
}


-(void)viewDidLoad {
	[super viewDidLoad];
}

@end
