//
//  SSWAnimator.h
//
//  Created by Arkadiusz Holko http://holko.pl on 29-05-14.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// Undocumented animation curve used for the navigation controller's transition.
FOUNDATION_EXPORT UIViewAnimationOptions const SSWNavigationTransitionCurve;

@interface SSWAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@end
