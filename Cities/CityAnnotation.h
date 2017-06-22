//
//  CityAnnotation.h
//  Cities
//
//  Created by Ulaş Sancak on 22/06/2017.
//  Copyright © 2017 Ulaş Sancak. All rights reserved.
//

#import <MapKit/MKAnnotation.h>

@interface CityAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy, nullable) NSString *title;
@property (nonatomic, readonly, copy, nullable) NSString *subtitle;

- (instancetype _Nonnull )initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *_Nullable)title subtitle:(NSString *_Nullable)subtitle;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
