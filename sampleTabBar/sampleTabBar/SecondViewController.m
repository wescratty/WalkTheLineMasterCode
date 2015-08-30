//
//  LocationViewController.m
//  sampleTabBar
//
//  Created by Wes Cratty on 1/2/15.
//  Copyright (c) 2015 Wes Cratty. All rights reserved.
//

#import "SecondViewController.h"
#import <Corelocation/CoreLocation.h>
#import "AppDelegate.h"

//static int iterations =0;


@interface SecondViewController ()
<CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UILabel *latitude;
@property (weak, nonatomic) IBOutlet UILabel *longitude;
@property (weak, nonatomic) IBOutlet UILabel *seconds;
@property (weak, nonatomic) IBOutlet UILabel *speed;

- (IBAction)buttonPressed:(UIButton*)sender;

@end

@implementation SecondViewController

{
    CLLocationManager *manager;
    CLGeocoder *geocoder;
    CLPlacemark *placmark;
    int counter;
}

//====================================================================
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    manager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    
}


//====================================================================
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//====================================================================
- (IBAction)buttonPressed:(UIButton*)sender {
    
    if ([[sender currentTitle] isEqualToString:@"Start"]) {
        manager.delegate = self;
        if ([manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [manager requestWhenInUseAuthorization];
        }
        
        manager.desiredAccuracy = kCLLocationAccuracyBest;
        [manager startUpdatingLocation];
        
    }else if ([[sender currentTitle] isEqualToString:@"Stop"]) {
        [manager stopUpdatingLocation];
        
        
    }else if ([[sender currentTitle] isEqualToString:@"Reset Data"]) {
        
        counter = 0;
        while (0<[[NSArray sharedInstance] count]) {
            int arraySize =(int)[[NSArray sharedInstance] count];
            [[NSArray sharedInstance] removeObjectAtIndex:arraySize-1];
            //            printf("1");
        }
        self.seconds.text =[NSString stringWithFormat:@"%lu",(unsigned long)[[NSArray sharedInstance] count] ];
        self.speed.text = [NSString stringWithFormat:@"%f", 0.0];
    }
    
}


//====================================================================
-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Error: %@",error);
    NSLog(@"Failed to get location :(");
}


//====================================================================
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation    {
    int mphConvert = 2.23693629;
    counter++;
//    NSLog(@"counter :%d",counter);
    if (counter<3) {
        return;
    }
    
    if (newLocation.horizontalAccuracy < 0) return;
    if (newLocation.verticalAccuracy < 0) return;
    
    CLLocation *currentLocation = newLocation;
    double speed = newLocation.speed;

    if (speed<0){
        speed =0;
    }
    
    [[NSArray sharedInstance] addObject:[NSNumber numberWithDouble:speed*mphConvert]];
  //    iterations++;
    
    if (currentLocation != nil){
        
        self.latitude.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        self.longitude.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        self.seconds.text =[NSString stringWithFormat:@"%lu",(unsigned long)[[NSArray sharedInstance] count]-1 ];
        self.speed.text = [NSString stringWithFormat:@"%f", speed*mphConvert];
    }
    
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count]>0) {
            placemarks = [placemarks lastObject];
    
        }else{
            NSLog(@"%@",error.debugDescription);
        }
    }];
    
}

@end

