//
//  AppDelegate.m
//  ChillN
//
//  Created by Vincent Jardel on 26/03/2015.
//  Copyright (c) 2015 ChillCompany. All rights reserved.
//

#import "AppDelegate.h"
@import GoogleMaps;
@import GooglePlaces;
#import "EventDetailViewController.h"
#import "HomeViewController.h"


@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //     Heroku Migration
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"VpU4JfFKNOI1syoeVaWwmSGbDeMFBfVLld2T7Fdi";
        configuration.clientKey = @"1UxA7TR2HDuFSnILmLrJWi7zdlsnQz2ZYj2t9kls";
        configuration.server = @"http://chilln.herokuapp.com/parse";
    }]];
    [PFUser enableRevocableSessionInBackground];
        
    
    // Google Maps
    [GMSPlacesClient provideAPIKey:@"AIzaSyBVaaKEBzTMw52xC58U4K53_qBYBLy_9Ak"];
    
//        [Parse setApplicationId:@"VpU4JfFKNOI1syoeVaWwmSGbDeMFBfVLld2T7Fdi"
//                      clientKey:@"1UxA7TR2HDuFSnILmLrJWi7zdlsnQz2ZYj2t9kls"];
    
    if ([PFUser currentUser].objectId) { // LOGGED = TRUE
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    } else {
        UIViewController* rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LoginViewController"];
        UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:rootController];
        
        self.window.rootViewController = navigation;
    }
    
    //Push Notifications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
        application.applicationIconBadgeNumber = 0;
    }
    
    UIImage *customBackButton = [[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [UINavigationBar appearance].backIndicatorImage = customBackButton;
    [UINavigationBar appearance].backIndicatorTransitionMaskImage = customBackButton;
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if ([PFUser currentUser].objectId) {
        self.objectId = userInfo[@"eventId"];
        if ([self.objectId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]  != 0 && self.objectId != nil) {
            if (application.applicationState == UIApplicationStateActive) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: userInfo[@"aps"][@"alert"]
                                                                message: nil
                                                               delegate: self
                                                      cancelButtonTitle: @"Annuler"
                                                      otherButtonTitles: @"Voir", nil];
                alert.tag = 100;
                [alert show];
                
            } else if (application.applicationState == UIApplicationStateBackground || application.applicationState == UIApplicationStateInactive) {
                [self moveToDetailEvent];
            }
        } else {
            [PFPush handlePush:userInfo];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            [self moveToDetailEvent];
        }
    }
}

- (void)moveToDetailEvent {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    EventDetailViewController *eventDetailVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"EventDetail"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Events"];
    [query whereKey:@"objectId" equalTo:self.objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (!error) {
            eventDetailVC.event = object;
            
            [navController setViewControllers:@[[mainStoryboard instantiateViewControllerWithIdentifier:@"Main"],
                                                eventDetailVC]
                                     animated:NO];
        }
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
        application.applicationIconBadgeNumber = 0;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
