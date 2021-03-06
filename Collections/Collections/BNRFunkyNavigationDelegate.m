//
//  BNRFunkyNavigationDelegate.m
//  Collections
//
//  Created by Stephen Christopher on 1/23/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "BNRFunkyNavigationDelegate.h"

#import "BNRFadeAnimator.h"
#import "BNRPinchTransition.h"
#import "BNRSliderTransition.h"

NSString * const kGrayScreenID = @"grayScreenVC";

@interface BNRFunkyNavigationDelegate () 

@property (nonatomic, strong) UIViewController *currentVC;
@property (nonatomic, strong) BNRFadeAnimator *fadeAnimator;
@property (nonatomic, strong) id<BNRInteractor> interactor;

@end

@implementation BNRFunkyNavigationDelegate

- (void)hookupInteractor
{
    [self.interactor addInteractorToViewController:self.currentVC
                                      forOperation:UINavigationControllerOperationPush toViewController:[self grayScreenViewController]];
}

- (UIViewController *)grayScreenViewController
{
    UIStoryboard *iPadStoryboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    UIViewController *grayVC = [iPadStoryboard instantiateViewControllerWithIdentifier:kGrayScreenID];
    return grayVC;
}

#pragma mark - set up different interaction controllers

- (void)activatePinchInteraction
{
    BOOL interactorIsPinch = [[self.interactor class] isSubclassOfClass:[BNRPinchTransition class]];
    if (!interactorIsPinch) {
        [self.interactor removeInteractorFromViewController:self.currentVC];

        BNRPinchTransition *pinchTransition = [BNRPinchTransition new];
        self.interactor = pinchTransition;
    }

    [self hookupInteractor];
}

- (void)activateShakeInteraction
{
    NSLog(@"turn on shake");
}

- (void)activateSliderInteractionWithSlider:(UISlider *)slider
{
    BOOL interactorIsSlider = [[self.interactor class] isSubclassOfClass:[BNRSliderTransition class]];
    if (!interactorIsSlider) {
        [self.interactor removeInteractorFromViewController:self.currentVC];
        
        BNRSliderTransition *sliderTransition = [BNRSliderTransition new];
        [sliderTransition setSlider:slider];
        self.interactor = sliderTransition;
    }

    [self hookupInteractor];

}

#pragma mark - <UINavigationControllerDelegate>

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    if (!self.fadeAnimator) {
        self.fadeAnimator = [BNRFadeAnimator new];
    }
    return self.fadeAnimator;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.currentVC = viewController;

    Class grayScreenClass = [[self grayScreenViewController] class];
    if ([viewController isKindOfClass:grayScreenClass]) {
        BOOL interactorIsPinch = [[self.interactor class] isSubclassOfClass:[BNRPinchTransition class]];
        if (!interactorIsPinch) {
            [self.interactor removeInteractorFromViewController:self.currentVC];

            BNRPinchTransition *pinchTransition = [BNRPinchTransition new];
            self.interactor = pinchTransition;
        }
        [self.interactor addInteractorToViewController:self.currentVC
                                          forOperation:UINavigationControllerOperationPop toViewController:nil];
    }
    return;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    if (self.interactor && self.interactor.isInteractive) {
        return self.interactor;
    }
    return nil;
}

@end
