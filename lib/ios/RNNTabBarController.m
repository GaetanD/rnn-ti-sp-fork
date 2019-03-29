#import "RNNTabBarController.h"

@implementation RNNTabBarController {
	NSUInteger _currentTabIndex;
}

- (id<UITabBarControllerDelegate>)delegate {
	return self;
}

- (void)viewDidLayoutSubviews {
	[self.presenter viewDidLayoutSubviews];
}

- (UIViewController *)getCurrentChild {
	return self.selectedViewController;
}

- (CGFloat)getTopBarHeight {
    for(UIViewController * child in [self childViewControllers]) {
        CGFloat childTopBarHeight = [child getTopBarHeight];
        if (childTopBarHeight > 0) return childTopBarHeight;
    }
    return [super getTopBarHeight];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return self.selectedViewController.supportedInterfaceOrientations;
}

- (void)setSelectedIndexByComponentID:(NSString *)componentID {
	for (id child in self.childViewControllers) {
		UIViewController<RNNLayoutProtocol>* vc = child;

		if ([vc conformsToProtocol:@protocol(RNNLayoutProtocol)] && [vc.layoutInfo.componentId isEqualToString:componentID]) {
			[self setSelectedIndex:[self.childViewControllers indexOfObject:child]];
		}
	}
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
	_currentTabIndex = selectedIndex;
	[super setSelectedIndex:selectedIndex];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return self.selectedViewController.preferredStatusBarStyle;
}

#pragma mark UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	[self.eventEmitter sendBottomTabSelected:@(tabBarController.selectedIndex) unselected:@(_currentTabIndex)];
	_currentTabIndex = tabBarController.selectedIndex;
}


// Fork: menu tab is only used as a placeholder, no VC should be mounted
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
	NSUInteger selectedIndex = [tabBarController.viewControllers indexOfObject:viewController];
	NSUInteger lastTabIndex = [tabBarController.viewControllers count] - 1;
	if (selectedIndex == lastTabIndex) {
		// We still send the event so we can use it on the JS side
		[_eventEmitter sendBottomTabSelected:@(selectedIndex) unselected:@(_currentTabIndex)];
		return NO;
	}
	return YES;
}

@end
