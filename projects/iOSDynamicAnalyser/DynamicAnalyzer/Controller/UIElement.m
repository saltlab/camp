//
//  UIElement.m
//
//  Created by Mona on 12-04-07. All rights reserved.
//

#import "UIElement.h"
#import "DCIntrospect.h"


@implementation UIElement

@synthesize className, objectClass, object, action, target, visited, details, label;


#pragma mark -
#pragma mark Helper Methods

- (void)addActionForTargetUIElement {
    
    if ([self.object isKindOfClass:[UITableViewController class]] || [self.object isKindOfClass:[UITableViewCell class]]) {
        self.action = @"tableCellClicked";
        self.target = [NSString stringWithFormat:@"%@", [UITableViewCell class]];
    }
    else if ([NSStringFromClass([self.object class]) isEqualToString:@"UITableViewCellContentView"]) {
        self.action = @"tableCellClicked";
        self.target = [NSString stringWithFormat:@"%@", [UITableViewCell class]];
    }
    else if ([NSStringFromClass([self.object class]) isEqualToString:@"UITableViewCellContentView"] || [self.object isKindOfClass:[UITableViewCell class]]) {
        self.action = @"tableCellClicked";
        self.target = [NSString stringWithFormat:@"%@", [UITableViewCell class]];
    }
    else if ([self.object isKindOfClass:[UITabBar class]] || [self.object isKindOfClass:[UITabBarItem class]] || [NSStringFromClass([self.object class]) isEqualToString:@"UITabBarButton"]) {
        self.action = @"tabBarButtonClicked";
        self.target = [NSString stringWithFormat:@"%@", [UITabBarItem class]];
    }
	else if ([self.object respondsToSelector:@selector(allTargets)]) {
		
		UIControl *control = (UIControl *)self.object;
		UIControlEvents controlEvents = [control allControlEvents];
		NSSet *allTargets = [control allTargets];
		[allTargets enumerateObjectsUsingBlock:^(id _target, BOOL *stop)
		 {
			 self.target = _target;
			 NSArray *actions = [control actionsForTarget:target forControlEvent:controlEvents];
			 [actions enumerateObjectsUsingBlock:^(id _action, NSUInteger idx, BOOL *stop2)
			  {
				  self.action = (NSString *)_action;
			  }];
		 }];
    }
}

+ (UIElement*)addUIElement:(UIView*)_object {

    if ([_object isKindOfClass:[UILabel class]])
        return [self addLabel:(UILabel*)_object];
        
    else if ([_object isKindOfClass:[UIButton class]])
        return [self addButton:(UIButton*)_object];
    
    else if ([[NSString stringWithFormat:@"%@", [_object class]] isEqualToString:@"UITabBarButton"])
        return [self addTabItem1:(id)_object];
    
    //else if ([_object.superview isKindOfClass:[UITabBar class]])
    //    return [self addTabItem2:(UITabBar*)_object.superview];
    
    else if ([[NSString stringWithFormat:@"%@", [_object class]] isEqualToString:@"UITableViewCellContentView"])
        return [self addTableCell:(UITableViewCell*)_object];
    
    else if ([_object isKindOfClass:[UINavigationBar class]]) {
        UIView* touchedView = _object;
        for (UIView* v in [(UINavigationBar*)_object subviews])
            if ([[NSString stringWithFormat:@"%@", [v class]] isEqualToString:@"UINavigationItemButtonView"]) {
                touchedView = v;
            }
        return [self addNavigationItemView:touchedView withAction:@"goBack"];
    }
    
    
	UIElement *element = [[UIElement alloc] init];
    element.object = _object;
    element.objectClass = [_object class];
	element.className = [NSString stringWithFormat:@"%@", element.objectClass];
    element.details = @"";
    //element.details = [NSString stringWithFormat:@"%@", [_object performSelector:@selector(recursiveDescription)]];
    // list targets if there are any
	[element addActionForTargetUIElement];
    
	return element;
}

- (BOOL)isEqualToUIElement:(UIElement*)e {
	
	BOOL returnValue = NO;
	
	if((self.className && e.className && [self.className isEqualToString:e.className]) || (!self.className && !e.className))// &&
		
        
		if(((self.action!=nil && e.action!=nil && [self.action isEqualToString:e.action]) || (self.action==nil && e.action==nil)) ||
		   ([self.action	hasSuffix:@"ButtonItem"] && [e.action hasSuffix:@"ButtonItem"])) {
            
            if ([self.action hasSuffix:@"UndefinedBackButtonItem"] || [e.action hasSuffix:@"UndefinedBackButtonItem"] || [self.action hasSuffix:@"LeftBarButtonItem"] || [e.action hasSuffix:@"LeftBarButtonItem"]) {
                returnValue = TRUE;
            }
            else if ([self.action	hasSuffix:@"BarButtonItem"] && [e.action hasSuffix:@"BarButtonItem"]) {
				
				UIBarButtonItem *barItem1 = (UIBarButtonItem *)self.objectClass;
				UIBarButtonItem *barItem2 = (UIBarButtonItem *)e.objectClass;
				
				if ([barItem1 isEqual:barItem2])
					//if ((barItem1.tag == barItem2.tag) &&
					//	(barItem1.enabled == barItem2.enabled) &&
					//	(barItem1.image == barItem2.image) &&
					//	(barItem1.title == barItem2.title))
					
					returnValue = TRUE;
			}
			//if((self.target && e.target && [self.target isEqual:e.target]) || (!self.target && !e.target)) {
			else if ([self.objectClass isSubclassOfClass:UIView.class] &&
				[e.objectClass isSubclassOfClass:UIView.class]) {
				
				UIView *view1 = (UIView *)self.objectClass;
				UIView *view2 = (UIView *)e.objectClass;
				
				if ([view1 isEqual:view2])
					//if ((view1.tag && view2.tag) || (view1.tag && view2.tag && view1.tag == view2.tag))
					//if (view1.backgroundColor == view2.backgroundColor) //&&
					//if (view1.hidden == view2.hidden) //&&
					//if (view1.userInteractionEnabled == view2.userInteractionEnabled) //&&
					//if ([[self.object accessibilityLabel] isEqualToString:[e.object accessibilityLabel]])
					
					returnValue = TRUE;
			}
		}
	
	return returnValue;
}

+ (UIElement*)addNavigationItem:(UIBarButtonItem*)barButtonItem withAction:(NSString*)action {
	
	UIElement *element = [[UIElement alloc] init];
	element.action = action;
	element.target = barButtonItem.target;
	element.object = (id)barButtonItem;
	element.objectClass = [element.object class];
    element.className = [NSString stringWithFormat:@"%@", [UIButton class]];
    element.details = @"";
    //element.details = [NSString stringWithFormat:@"%@", barButtonItem];
    
	return element;
}

+ (UIElement*)addNavigationItemView:(UIView*)thisBackButtonView withAction:(NSString*)action {
	
	UIElement *element = [[UIElement alloc] init];
	element.action = action;
	element.target = nil;
	element.object = (UIView*)thisBackButtonView;
	element.objectClass = [element.object class]; 
    element.className = [NSString stringWithFormat:@"%@", [UIButton class]];
    element.label = @"Back";
    element.details = @"";
    //element.details = [NSString stringWithFormat:@"%@", thisBackButtonView];
    
	return element;
}

+ (UIElement*)addTableView:(UITableView*)_tableView {

    int numberOfCells = 0;
    //finding the number of cells in your table view by looping through its sections
    for (NSInteger section = 0; section < [_tableView numberOfSections]; section++)
        numberOfCells += [_tableView numberOfRowsInSection:section];

    UIElement *element = [[UIElement alloc] init];
    element.object = _tableView;
    element.objectClass = [_tableView class];
	element.className = [NSString stringWithFormat:@"%@", _tableView.class];
    
    element.target = [NSString stringWithFormat:@"%@", _tableView.class];
    element.action = _tableView.allowsSelection?@"tableCellClicked":@"";
    element.label = @"";
    
    element.details = [NSString stringWithFormat:@"%i", numberOfCells];
    //element.details = [NSString stringWithFormat:@"More details - \n Number of cells: %i \n Visible cells: %@", numberOfCells, _tableView.visibleCells];
    

    return element;
}

+ (UIElement*)addTableCell:(UITableViewCell*)cell {
    
    UIElement *element = [[UIElement alloc] init];
    element.object = cell;
    element.objectClass = [cell class];
	element.className = [NSString stringWithFormat:@"%@", [UITableViewCell class]];
    
    [element addActionForTargetUIElement];
    element.label = @"";
    for (UIView *v in [cell subviews])
		if ([v isKindOfClass:[UILabel class]])
            element.label = [(UILabel*)v text];
    
    element.details = @"";
    //element.details = [NSString stringWithFormat:@"More details - \n Button: %@ ", [[[DCIntrospect alloc] init] logPropertiesForObject:_button]];
    
	return element;
}

+ (UIElement*)addTabView:(UITabBarController*)_tabController {
    
    //UITabBarItem* thisUITabBarItem = _tabController.tabBar.selectedItem;
    
    UIElement *element = [[UIElement alloc] init];
    element.object = _tabController.tabBar;
    element.objectClass = [_tabController.tabBar class];
	element.className = [NSString stringWithFormat:@"%@", [_tabController.tabBar class]];
    
    element.target = [NSString stringWithFormat:@"%@", _tabController.class];
    element.action = @"itemClicked";
    element.label = @"";//thisUITabBarItem.title;

    element.details = [NSString stringWithFormat:@"%i", (int)_tabController.tabBar.items.count];
    //element.details = [NSString stringWithFormat:@"More details - \n Number of tabs: %d \n SelectedTab: %@ ", _tabController.tabBar.items.count, [[[DCIntrospect alloc] init] logPropertiesForObject:thisUITabBarItem]];

	return element;
}

+ (UIElement*)addTabItem1:(UIBarButtonItem*)tabItem {
    
    UIElement *element = [[UIElement alloc] init];
    element.object = tabItem;
    element.objectClass = [tabItem class];
	element.className = [NSString stringWithFormat:@"%@", [tabItem class]];
    
    element.action = @"itemClicked";
    element.label = @"";
    NSString* detail = [NSString stringWithFormat:@"%@", [tabItem performSelector:@selector(recursiveDescription)]];
    if([detail rangeOfString:@"text = '" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        NSRange firstInstance = [detail rangeOfString:@"text = '"];
        detail = [detail substringFromIndex:firstInstance.location + firstInstance.length];
        firstInstance = [detail rangeOfString:@"'"];
        element.label = [detail substringToIndex:firstInstance.location];
    }
                         
    element.details = @"";
    //element.details = [NSString stringWithFormat:@"More details - \n Number of tabs: %d \n SelectedTab: %@ ", _tabController.tabBar.items.count, [[[DCIntrospect alloc] init] logPropertiesForObject:thisUITabBarItem]];
    
	return element;
}

+ (UIElement*)addTabItem2:(UITabBar*)tabBar {
    
    UITabBarItem* thisUITabBarItem = tabBar.selectedItem;
    
    UIElement *element = [[UIElement alloc] init];
    element.object = thisUITabBarItem;
    element.objectClass = [thisUITabBarItem class];
	element.className = [NSString stringWithFormat:@"%@", [thisUITabBarItem class]];
    
    element.action = @"itemClicked";
    element.label = thisUITabBarItem.title;
    
    element.details = @"";
    //element.details = [NSString stringWithFormat:@"More details - \n Number of tabs: %d \n SelectedTab: %@ ", _tabController.tabBar.items.count, [[[DCIntrospect alloc] init] logPropertiesForObject:thisUITabBarItem]];
    
	return element;
}

+ (UIElement*)addLabel:(UILabel*)_label {
    
    UIElement *element = [[UIElement alloc] init];
    element.object = _label;
    element.objectClass = [_label class];
	element.className = [NSString stringWithFormat:@"%@", [_label class]];
    
    element.target = @"";
    element.action = @"";
    element.label = _label.text;
    
    element.details = @"";
    //element.details = [NSString stringWithFormat:@"More details - \n Font:%@ \n Number of lines: %d \n Lable: %@ ", _label.font, _label.numberOfLines, [[[DCIntrospect alloc] init] logPropertiesForObject:_label]];
    
	return element;
}

+ (UIElement*)addButton:(UIButton*)_button {
    
    UIElement *element = [[UIElement alloc] init];
    element.object = _button;
    element.objectClass = [_button class];
	element.className = [NSString stringWithFormat:@"%@", [UIButton class]];
    
    [element addActionForTargetUIElement];
    element.label = _button.titleLabel.text;
    
    element.details = @"";
    //element.details = [NSString stringWithFormat:@"More details - \n Button: %@ ", [[[DCIntrospect alloc] init] logPropertiesForObject:_button]];
    
	return element;
}



+ (UIElement*)addAlertView:(UIAlertView*)view {
    
    UIElement *element = [[UIElement alloc] init];
    element.object = view;
    element.objectClass = [view class];
	element.className = [NSString stringWithFormat:@"%@", [UIAlertView class]];
    
    [element addActionForTargetUIElement];
    //element.label = view.title;
    
    element.details = [NSString stringWithFormat:@"More details - \n Button: %@ ", [[[DCIntrospect alloc] init] logPropertiesForObject:view]];
    
	return element;
}


@end
