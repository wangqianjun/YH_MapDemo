//
//  ViewController.m
//  YH_MapDemo
//
//  Created by 王钱钧 on 15/8/20.
//  Copyright (c) 2015年 王钱钧. All rights reserved.
//

#import "ViewController.h"
#import <MapboxGL/MapboxGL.h>

@interface ViewController ()<MGLMapViewDelegate>
@property (nonatomic, strong) MGLMapView *mapView;
@property (nonatomic, strong) MGLPointAnnotation *point1;
@property (nonatomic, strong) MGLPointAnnotation *point2;
@property (nonatomic, strong) MGLPointAnnotation *point3;
@property (nonatomic, strong) MGLPointAnnotation *point4;

@end

@implementation ViewController

- (MGLPointAnnotation *)point1
{
    if (!_point1) {
        _point1 = [[MGLPointAnnotation alloc] init];
        _point1.coordinate = CLLocationCoordinate2DMake(45.52214, -122.63748);
        _point1.title = @"Hello!";
        _point1.subtitle = @"Welcome to The YOHO!.";


    }
    
    return _point1;
}

- (MGLPointAnnotation *)point2
{
    if (!_point2) {
        _point2 = [[MGLPointAnnotation alloc] init];
        _point2.coordinate = CLLocationCoordinate2DMake(45.50294, -122.68407);
        _point2.title = @"Hello!";
        _point2.subtitle = @"Welcome to The YOHO!.";
        
        
    }
    
    return _point2;
}
- (MGLPointAnnotation *)point3
{
    if (!_point3) {
        _point3 = [[MGLPointAnnotation alloc] init];
        _point3.coordinate = CLLocationCoordinate2DMake(45.49821, -122.68428);
        _point3.title = @"Hello!";
        _point3.subtitle = @"Welcome to The YOHO!.";
        
        
    }
    
    return _point3;
}
- (MGLPointAnnotation *)point4
{
    if (!_point4) {
        _point4 = [[MGLPointAnnotation alloc] init];
        _point4.coordinate = CLLocationCoordinate2DMake(45.49893, -122.70774);
        _point4.title = @"Hello!";
        _point4.subtitle = @"Welcome to The YOHO!.";
        
        
    }
    
    return _point4;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *styleURL = [NSURL URLWithString:@"asset://styles/dark-v7.json"];

    self.mapView = [[MGLMapView alloc]initWithFrame:self.view.bounds styleURL:styleURL];
    [self.view addSubview:self.mapView];
    self.mapView.delegate = self;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // set the map's center coordinate  // 32.04,118.78
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(45.5076, -122.6736) // 45.5076, -122.6736
                            zoomLevel:15
                             animated:NO];
    [self.view addSubview:self.mapView];
    
    // 用户当前位置
//    self.mapView.userTrackingMode = MGLUserTrackingModeFollow;

    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Declare the annotation `point` and set its coordinates, title, and subtitle
    
    
    // Add annotation `point` to the map
    [self.mapView addAnnotation:self.point1];
    [self.mapView addAnnotation:self.point2];

    [self.mapView addAnnotation:self.point3];

    [self.mapView addAnnotation:self.point4];

    
    [self performSelector:@selector(drawPolyline) withObject:nil afterDelay:0.1];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id <MGLAnnotation>)annotation {
    return YES;
}

- (void)mapView:(MGLMapView * __nonnull)mapView didSelectAnnotation:(id<MGLAnnotation> __nonnull)annotation
{
    
}

// 设置坐标位置的图片
- (MGLAnnotationImage *)mapView:(MGLMapView *)mapView imageForAnnotation:(id <MGLAnnotation>)annotation
{
    NSString *imageName = @"annotation1";
    
    if (annotation == self.point2) {
        imageName = @"annotation2";
    }
    
    if (annotation == self.point3) {
        imageName = @"annotation3";
    }
    
    if (annotation == self.point4) {
        imageName = @"annotation4";
    }
    
    
    MGLAnnotationImage *annotationImage = [MGLAnnotationImage annotationImageWithImage:[UIImage imageNamed:imageName] reuseIdentifier:imageName];
    return annotationImage;
}



// 画线
- (void)drawPolyline
{
    // Perform GeoJSON parsing on a background thread
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue, ^(void)
                   {
                       // Get the path for example.geojson in the app's bundle
                       NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"example" ofType:@"geojson"];
                       
                       // Load and serialize the GeoJSON into a dictionary filled with properly-typed objects
                       NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:jsonPath] options:0 error:nil];
                       
                       // Load the `features` dictionary for iteration
                       for (NSDictionary *feature in jsonDict[@"features"])
                       {
                           // Our GeoJSON only has one feature: a line string
                           if ([feature[@"geometry"][@"type"] isEqualToString:@"LineString"])
                           {
                               // Get the raw array of coordinates for our line
                               NSArray *rawCoordinates = feature[@"geometry"][@"coordinates"];
                               NSUInteger coordinatesCount = rawCoordinates.count;
                               
                               // Create a coordinates array, sized to fit all of the coordinates in the line.
                               // This array will hold the properly formatted coordinates for our MGLPolyline.
                               CLLocationCoordinate2D coordinates[coordinatesCount];
                               
                               // Iterate over `rawCoordinates` once for each coordinate on the line
                               for (NSUInteger index = 0; index < coordinatesCount; index++)
                               {
                                   // Get the individual coordinate for this index
                                   NSArray *point = [rawCoordinates objectAtIndex:index];
                                   
                                   // GeoJSON is "longitude, latitude" order, but we need the opposite
                                   CLLocationDegrees lat = [[point objectAtIndex:1] doubleValue];
                                   CLLocationDegrees lng = [[point objectAtIndex:0] doubleValue];
                                   CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lng);
                                   
                                   // Add this formatted coordinate to the final coordinates array at the same index
                                   coordinates[index] = coordinate;
                               }
                               
                               // Create our polyline with the formatted coordinates array
                               MGLPolyline *polyline = [MGLPolyline polylineWithCoordinates:coordinates count:coordinatesCount];
                               
                               // Optionally set the title of the polyline, which can be used for:
                               //  - Callout view
                               //  - Object identification
                               // In this case, set it to the name included in the GeoJSON
                               polyline.title = feature[@"properties"][@"name"]; // "Crema to Council Crest"
                               
                               // Add the polyline to the map, back on the main thread
                               // Use weak reference to self to prevent retain cycle
                               __weak typeof(self) weakSelf = self;
                               dispatch_async(dispatch_get_main_queue(), ^(void)
                                              {
                                                  [weakSelf.mapView addAnnotation:polyline];
                                              });
                           }
                       }
                       
                   });
}

- (CGFloat)mapView:(MGLMapView *)mapView alphaForShapeAnnotation:(MGLShape *)annotation
{
    // Set the alpha for all shape annotations to 1 (full opacity)
    return 1.0f;
}

- (CGFloat)mapView:(MGLMapView *)mapView lineWidthForPolylineAnnotation:(MGLPolyline *)annotation
{
    // Set the line width for polyline annotations
    return 2.0f;
}

- (UIColor *)mapView:(MGLMapView *)mapView strokeColorForShapeAnnotation:(MGLShape *)annotation
{
    // Set the stroke color for shape annotations
    // ... but give our polyline a unique color by checking for its `title` property
    if ([annotation.title isEqualToString:@"Crema to Council Crest"])
    {
        // Mapbox cyan
        return [UIColor colorWithRed:59.0f/255.0f green:178.0f/255.0f blue:208.0f/255.0f alpha:1.0f];
    }
    else
    {
        return [UIColor redColor];
    }
}


@end
