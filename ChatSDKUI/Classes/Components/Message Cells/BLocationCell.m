//
//  BLocation.m
//  Chat SDK
//
//  Created by Benjamin Smiley-andrews on 27/09/2013.
//  Copyright (c) 2013 deluge. All rights reserved.
//

#import "BLocationCell.h"

#import <ChatSDK/UI.h>
#import <ChatSDK/Core.h>
#import <MapKit/MapKit.h>

@implementation BLocationCell

@synthesize map;
@synthesize mapImageView;

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //        map = [BMapViewManager sharedManager].mapFromPool;
        //        [self.bubbleImageView addSubview:map.mapView];
        
        mapImageView = [[UIImageView alloc] init];
        mapImageView.layer.cornerRadius = 10;
        mapImageView.clipsToBounds = YES;
        mapImageView.userInteractionEnabled = NO;
        
        [self.bubbleImageView addSubview:mapImageView];
        
    }
    return self;
}

-(void) setMessage: (id<PElmMessage>) message withColorWeight:(float)colorWeight {
    [super setMessage:message withColorWeight:colorWeight];
    
    self.bubbleImageView.image = Nil;
    
    float longitude = [[self.message compatibilityMeta][bMessageLongitude] floatValue];
    float latitude = [[self.message compatibilityMeta][bMessageLatitude] floatValue];
    
    // Load the map from Google Maps
    /*NSString * api = @"https://maps.googleapis.com/maps/api/staticmap";
     NSString * markers = [NSString stringWithFormat:@"markers=%f,%f", latitude, longitude];
     NSString * size = [NSString stringWithFormat:@"zoom=18&size=%ix%i", bMaxMessageWidth, bMaxMessageWidth];
     NSString * key = [NSString stringWithFormat:@"key=%@", BChatSDK.config.googleMapsApiKey];
     NSString * url = [NSString stringWithFormat:@"%@?%@&%@&%@", api, markers, size, key];
     
     [mapImageView sd_setImageWithURL:url placeholderImage:Nil options:SDWebImageLowPriority & SDWebImageScaleDownLargeImages];*/
    
    
    MKMapSnapshotOptions *mapSnapshotOptions = [[MKMapSnapshotOptions alloc]init];
    
    
    
    // Set the region of the map that is rendered.
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude, longitude);
    
    //mapSnapshotOptions.region = MKCoordinateRegionMake(location, 0.0)
    mapSnapshotOptions.camera = [[MKMapCamera alloc]init];
    mapSnapshotOptions.camera.centerCoordinate = location;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 100, 100);
    
    // Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
    mapSnapshotOptions.scale = [UIScreen mainScreen].scale;
    
    // Set the size of the image output.
    mapSnapshotOptions.size = CGSizeMake(bMaxMessageWidth, bMaxMessageWidth);
    
    // Show buildings and Points of Interest on the snapshot
    mapSnapshotOptions.showsBuildings = YES;
    mapSnapshotOptions.showsPointsOfInterest = YES;
    
    MKMapSnapshotter *snapShotter = [[MKMapSnapshotter alloc]initWithOptions:mapSnapshotOptions];
    
    
    [snapShotter startWithCompletionHandler:^(MKMapSnapshot * _Nullable snapshot, NSError * _Nullable error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            mapImageView.image = snapshot.image;
        });
    }];
    
    // Get a new map
    //    [map setLongitude:longitude withLatitude:latitude];
    
}

-(void) willDisplayCell {
    [super willDisplayCell];
}

-(UIView *) cellContentView {
    return mapImageView;
}

-(void) dealloc {
    //    [[BMapViewManager sharedManager] returnToPool: map];
}

@end
