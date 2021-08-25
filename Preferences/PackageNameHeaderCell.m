#import "PackageNameHeaderCell.h"

@implementation PackageNameHeaderCell
- (void)setFrame:(CGRect)frame {
	frame.origin.y = 0;
	frame.origin.x = 0;
	CGFloat contentOffset;
	UINavigationBar *navigationBar; 
	// fix for Shuffle inset Tables setting
 	if ([NSStringFromClass([self.superview class]) isEqualToString:@"UITableViewWrapperView"]) {		
		contentOffset = ((UIScrollView *)[self.superview.superview valueForKey:@"scrollView"]).contentOffset.y;
		navigationBar = ((SPBRootListController *)[self.superview.superview.superview valueForKey:@"viewDelegate"]).navigationController.navigationController.navigationBar; 
	} else {
		contentOffset = ((UIScrollView *)[self.superview valueForKey:@"scrollView"]).contentOffset.y;
		navigationBar = ((SPBRootListController *)[self.superview.superview valueForKey:@"viewDelegate"]).navigationController.navigationController.navigationBar; 
	}
	CGFloat navBarCompensation = navigationBar.frame.size.height + navigationBar.frame.origin.y; 
	CGFloat sum = navBarCompensation + contentOffset;
	if (sum < 0) {
		frame = CGRectMake( 0, sum, frame.size.width, frame.size.height - sum);
		float magic = -sum / frame.size.height;
		((CAGradientLayer *)self.layer).colors = @[
			(id)[UIColor colorWithRed: fmin(1, 0.02+magic*0.02) green: fmin(1, 0.29+magic*0.29) blue: fmin(1, 0.37+magic*0.37)  alpha: 1.00].CGColor,
			(id)[UIColor colorWithRed: 0.01 green: 0.08 blue: 0.09 alpha: 1.00].CGColor
			];
	}
	[super setFrame:frame];
}
@end
