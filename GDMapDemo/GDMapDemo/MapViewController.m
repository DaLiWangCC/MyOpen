//
//  MapViewController.m
//  CatEyesDemo
//
//  Created by wanghao on 16/4/29.
//  Copyright © 2016年 wanghao. All rights reserved.
//

//常量
#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height



#import "MapViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "MapSearchViewController.h"

@interface MapViewController ()<MAMapViewDelegate,AMapSearchDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate,UISearchBarDelegate,UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;

@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UIView *mapBackView;

@property (nonatomic,retain) AMapSearchAPI *search;

@property (nonatomic,retain) NSString *currentCity;

@property (nonatomic,retain) UILongPressGestureRecognizer *longPressGesture;//长按手势

@property (nonatomic,retain) NSArray *pathPolylines;
@end

@implementation MapViewController

- (NSArray *)pathPolylines
{
    if (!_pathPolylines) {
        _pathPolylines = [NSArray array];
    }
    return _pathPolylines;
}

- (AMapSearchAPI *)search
{
    if (!_search) {
        _search = [[AMapSearchAPI alloc] init];
        _search.delegate = self;
    }
    return _search;
}

- (MAMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
        _mapView.delegate = self;
        _mapView.showsUserLocation = YES;    //YES 为打开定位，NO为关闭定位
        
        [_mapView setUserTrackingMode: MAUserTrackingModeFollow animated:NO]; //地图跟着位置移动
        
        //自定义定位经度圈样式
        _mapView.customizeUserLocationAccuracyCircleRepresentation = NO;
        
        _mapView.userTrackingMode = MAUserTrackingModeFollow;
        
        //后台定位
        _mapView.pausesLocationUpdatesAutomatically = NO;
        
        _mapView.allowsBackgroundLocationUpdates = YES;//iOS9以上系统必须配置
    
    }
    return _mapView;
}

#pragma  mark -- viewDidLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //配置用户Key
    [MAMapServices sharedServices].apiKey = @"76bb9bc3718375ad03acba7c333694c4";
    
    
    [self.view insertSubview:self.mapView atIndex:0];
    
    
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.searchBar.delegate = self;
//    _searchController.delegate = self;
    _searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.hidesNavigationBarDuringPresentation = NO;
    _searchController.searchBar.frame = CGRectMake(kWidth/2 - 100, 20, 200, 44.0);


    
    self.navigationItem.titleView = _searchController.searchBar;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(leftAction)];
    

    
    [self addGesture];
}




#pragma mark -- 大头针和遮盖

//自定义的经纬度和区域
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    /* 自定义定位精度对应的MACircleView. */
    if (overlay == mapView.userLocationAccuracyCircle)
    {
        MACircleRenderer *accuracyCircleRenderer = [[MACircleRenderer alloc] initWithCircle:overlay];
        
        accuracyCircleRenderer.lineWidth    = 2.f;
        accuracyCircleRenderer.strokeColor  = [UIColor lightGrayColor];
        accuracyCircleRenderer.fillColor    = [UIColor colorWithRed:1 green:0 blue:0 alpha:.3];
        
        return accuracyCircleRenderer;
    }
    
    //画路线
//    if ([overlay isKindOfClass:[MAPolygon class]])
//    {
//        
//        MAPolygonRenderer *polygonView = [[MAPolygonRenderer alloc] initWithPolygon:overlay];
//        
//        polygonView.lineWidth = 5.f;
//        polygonView.strokeColor = [UIColor colorWithRed:0.986 green:0.185 blue:0.019 alpha:1.000];
//        polygonView.fillColor = [UIColor colorWithRed:0.940 green:0.771 blue:0.143 alpha:0.800];
//        polygonView.lineJoinType = kMALineJoinMiter;//连接类型
//        
//        return polygonView;
//    }
    //画路线
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        
        MAPolylineRenderer *polygonView = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        
        polygonView.lineWidth = 8.f;
        polygonView.strokeColor = [UIColor colorWithRed:0.015 green:0.658 blue:0.986 alpha:1.000];
        polygonView.fillColor = [UIColor colorWithRed:0.940 green:0.771 blue:0.143 alpha:0.800];
        polygonView.lineJoinType = kMALineJoinRound;//连接类型
        
        return polygonView;
    }
    return nil;
    
}

//添加大头针
- (void)addAnnotation
{
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = _currentLocation.coordinate;
    pointAnnotation.coordinate = CLLocationCoordinate2DMake(_currentPOI.location.latitude, _currentPOI.location.longitude);
    pointAnnotation.title = _currentPOI.name;
      pointAnnotation.subtitle = @"阜通东大街6号";
//    pointAnnotation.subtitle = _currentPOI.address;

    
    [_mapView addAnnotation:pointAnnotation];
    [_mapView selectAnnotation:pointAnnotation animated:YES];
}




//大头针的回调
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    
    /* 自定义userLocation对应的annotationView. */
    if ([annotation isKindOfClass:[MAUserLocation class]])
    {
        static NSString *userLocationStyleReuseIndetifier = @"userLocationStyleReuseIndetifier";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:userLocationStyleReuseIndetifier];
        }
        annotationView.image = [UIImage imageNamed:@"userPosition"];
        
        return annotationView;
    }
    
    //大头针
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;

        return annotationView;
    }
    return nil;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- 功能

//地图样式切换
- (IBAction)SatelliteMapAction:(id)sender {
    _mapView.mapType = MAMapTypeSatellite;
}
- (IBAction)standardMapAction:(id)sender {
    _mapView.mapType = MAMapTypeStandard;
}
- (IBAction)nightMapAction:(id)sender {
    _mapView.mapType = MAMapTypeStandardNight;
}
//实时交通
- (IBAction)currentTrafficAction:(UIButton *)sender {
    if (!sender.selected) {
        sender.selected = YES;
        _mapView.showTraffic= NO;
    }
    else
    {
        sender.selected = NO;
        _mapView.showTraffic= YES;
    }
}

#pragma mark -- 地图位置偏移

//地图回到原点
- (IBAction)backToCurrent:(id)sender {
    [_mapView setCenterCoordinate: _currentLocation.coordinate animated:YES];
    
    
    //恢复缩放比例和角度
    [_mapView setZoomLevel:18 animated:YES];
    
    [_mapView setRotationDegree:0 animated:YES duration:0.5];
    [_mapView setCameraDegree:0 animated:YES duration:0.5];
}


//搜索

- (IBAction)searchAction:(id)sender {
    //初始化检索对象
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    //构造AMapPOIAroundSearchRequest对象，设置周边请求参数
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    AMapPOIKeywordsSearchRequest *requestKey = [[AMapPOIKeywordsSearchRequest alloc]init];
    //当前位置
    request.location = [AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];

    //关键字
    requestKey.keywords = self.searchTF.text;
    // types属性表示限定搜索POI的类别，默认为：餐饮服务|商务住宅|生活服务
    // POI的类型共分为20种大类别，分别为：
    // 汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|
    // 医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|
    // 交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施
//    request.types = @"餐饮服务|生活服务";
    request.radius =  5000;//<! 查询半径，范围：0-50000，单位：米 [default = 3000]
    request.sortrule = 0;
    request.requireExtension = YES;
    
    //发起周边搜索
    [self.search AMapPOIAroundSearch:request];
//    [self.search AMapPOIKeywordsSearch:requestKey];

}


#pragma mark -- search代理方法

//实现POI搜索对应的回调函数
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if(response.pois.count == 0)
    {
        return;
    }
    
    //通过 AMapPOISearchResponse 对象处理搜索结果
    NSString *strCount = [NSString stringWithFormat:@"count: %ld",response.count];
    NSString *strSuggestion = [NSString stringWithFormat:@"Suggestion: %@", response.suggestion];
    NSString *strPoi = @"";
    for (AMapPOI *p in response.pois) {
        strPoi = [NSString stringWithFormat:@"%@\nPOI: %@,%@,%@", strPoi, p.description,p.name,p.type];
    }
    NSString *result = [NSString stringWithFormat:@"%@ \n %@ \n %@", strCount, strSuggestion, strPoi];
    NSLog(@"Place: %@", result);
}

//实现输入提示的回调函数
-(void)onInputTipsSearchDone:(AMapInputTipsSearchRequest*)request response:(AMapInputTipsSearchResponse *)response
{
    if(response.tips.count == 0)
    {
        return;
    }
    
    //通过AMapInputTipsSearchResponse对象处理搜索结果
    NSString *strCount = [NSString stringWithFormat:@"count: %ld", response.count];
    NSString *strtips = @"";
    for (AMapTip *p in response.tips) {
        strtips = [NSString stringWithFormat:@"%@\nTip: %@,%@", strtips, p.description,p.name];
    }
    NSString *result = [NSString stringWithFormat:@"%@ \n %@", strCount, strtips];
    
    NSLog(@"InputTips: %@", result);
}

#pragma mark -- 定位位置发生改变

//当位置更新时，会进定位回调，通过回调函数，能获取到定位点的经纬度坐标
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    
    if(updatingLocation)
    {
        //取出当前位置的坐标
        NSLog(@"%f,%f,%@",userLocation.coordinate.latitude,userLocation.coordinate.longitude,userLocation.title);
        self.currentLocation = userLocation;
        
        //构造AMapReGeocodeSearchRequest对象
        AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
        regeo.location = [AMapGeoPoint locationWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
        
        regeo.radius = 10000;
        regeo.requireExtension = YES;
        
        //发起逆地理编码
        [self.search AMapReGoecodeSearch: regeo];
    }
}


//实现逆地理编码的回调函数
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    
    if(response.regeocode != nil)
    {
        //通过AMapReGeocodeSearchResponse对象处理搜索结果
        NSString *result = [NSString stringWithFormat:@"ReGeocode: %@", response.regeocode];
        NSLog(@"ReGeo: %@", result);
        _currentCity = response.regeocode.addressComponent.city;
        NSLog(@"city  %@",_currentCity);
    }
}


#pragma mark -- 路径查询
//规划线路查询
- (IBAction)findWayAction:(id)sender {
    //构造AMapDrivingRouteSearchRequest对象，设置驾车路径规划请求参数
    AMapWalkingRouteSearchRequest *request = [[AMapWalkingRouteSearchRequest alloc] init];
//    request.origin = [AMapGeoPoint locationWithLatitude:34.223979 longitude:108.900445];
//    request.destination = [AMapGeoPoint locationWithLatitude:34.224113 longitude:108.900536];
    
    
    request.origin = [AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
    
    request.destination = [AMapGeoPoint locationWithLatitude:_destinationPoint.coordinate.latitude longitude:_destinationPoint.coordinate.longitude];
    
    
//    request.strategy = 2;//距离优先
//    request.requireExtension = YES;
    
    //发起路径搜索
    [_search AMapWalkingRouteSearch: request];
    
  
//    [self drawPolygon];
   
}


//实现路径搜索的回调函数
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if(response.route == nil)
    {
        return;
    }
    
    //通过AMapNavigationSearchResponse对象处理搜索结果
    NSString *route = [NSString stringWithFormat:@"Navi: %@", response.route];
    
    NSLog(@"%@", route);
    AMapPath *path = response.route.paths[0];
    AMapStep *step = path.steps[0];
    NSLog(@"%@",step.polyline);
    NSLog(@"%@",response.route.paths[0]);
    
    
    if (response.count > 0)
    {
        [_mapView removeOverlays:_pathPolylines];
        _pathPolylines = nil;
        
        // 只显⽰示第⼀条 规划的路径
        _pathPolylines = [self polylinesForPath:response.route.paths[0]];
        NSLog(@"%@",response.route.paths[0]);
        
        [_mapView addOverlays:_pathPolylines];
        
//        解析第一条返回结果
//        搜索路线
        MAPointAnnotation *currentAnnotation = [[MAPointAnnotation alloc]init];
        currentAnnotation.coordinate = _mapView.userLocation.coordinate;
        [_mapView showAnnotations:@[_destinationPoint, currentAnnotation] animated:YES];
        [_mapView addAnnotation:currentAnnotation];
    }
    
    
//    [self drawPolygonWith:response.route.origin dest:response.route.destination];
}

//绘制多边形
- (void)drawPolygon
{
    //构造多边形数据对象
    CLLocationCoordinate2D coordinates[3];
//    108.900536,34.223808;108.90033,34.223476;108.900246,34.223351
    coordinates[0].latitude = 34.221808;
    coordinates[0].longitude = 108.900536;
    
    coordinates[1].latitude = 34.223476;
    coordinates[1].longitude = 108.90133;
    
    coordinates[2].latitude = 34.226351;
    coordinates[2].longitude = 108.900246;
    
//    MAPolygon *polygon = [MAPolygon polygonWithCoordinates:coordinates count:3];
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coordinates count:3];
    
    //在地图上添加多边形对象
//    [_mapView addOverlay: polygon];
    [_mapView addOverlay:polyline];
}

#pragma mark -- push到搜索页面
- (IBAction)jumpTosearchAction:(id)sender {
    
    [self.searchController.searchBar endEditing:YES];
    MapSearchViewController *mapSearchVC = [[MapSearchViewController alloc]initWithNibName:@"MapSearchViewController" bundle:nil];
    
    mapSearchVC.currentCity = _currentCity;
    mapSearchVC.currentLocation = _currentLocation;
    
    mapSearchVC.moveBlock = ^(AMapPOI *poi)
    {
        [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude) animated:YES];
        self.currentPOI = poi;
        self.destinationPoint = [[MAPointAnnotation alloc]init];
        _destinationPoint.coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
        
        [self findWayAction:nil];
        //添加大头针
        [self addAnnotation];
    };
    
//    [self presentViewController:mapSearchVC animated:YES completion:nil];
    
    [self.navigationController pushViewController:mapSearchVC animated:YES];
}

//push到搜索页面
- (void)textFieldDidBeginEditing:(UITextField *)textField
{

    
    MapSearchViewController *mapSearchVC = [[MapSearchViewController alloc]initWithNibName:@"MapSearchViewController" bundle:nil];
    
    mapSearchVC.currentCity = _currentCity;
    mapSearchVC.currentLocation = _currentLocation;
    
    mapSearchVC.moveBlock = ^(AMapPOI *poi)
    {
        [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude) animated:YES];
        self.currentPOI = poi;
        self.destinationPoint = [[MAPointAnnotation alloc]init];
        _destinationPoint.coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
        
        [self findWayAction:nil];
        //添加大头针
        [self addAnnotation];

    };
    
//    [self presentViewController:mapSearchVC animated:YES completion:nil];
    [self.navigationController pushViewController:mapSearchVC animated:YES];
}


//添加手势
- (void)addGesture
{
//    _annotations = [NSMutableArray array];
//    _pois = nil;
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _longPressGesture.delegate = self;
    [_mapView addGestureRecognizer:_longPressGesture];
}

//长按手势相应
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint p = [gesture locationInView:_mapView];
        NSLog(@"press on (%f, %f)", p.x, p.y);
    }
    CLLocationCoordinate2D coordinate = [_mapView convertPoint:[gesture locationInView:_mapView] toCoordinateFromView:_mapView];

    // 添加标注
    if (_destinationPoint != nil) {
        // 清理
        [_mapView removeAnnotation:_destinationPoint];
        _destinationPoint = nil;
    }
    _destinationPoint = [[MAPointAnnotation alloc] init];
    _destinationPoint.coordinate = coordinate;
    _destinationPoint.title = @"目标点";
    [_mapView addAnnotation:_destinationPoint];

}

//路线解析
- (NSArray *)polylinesForPath:(AMapPath *)path
{
    if (path == nil || path.steps.count == 0)
    {
        return nil;
    }
    NSMutableArray *polylines = [NSMutableArray array];
    [path.steps enumerateObjectsUsingBlock:^(AMapStep *step, NSUInteger idx, BOOL *stop) {
        NSUInteger count = 0;
        CLLocationCoordinate2D *coordinates = [self coordinatesForString:step.polyline
                                                         coordinateCount:&count
                                                              parseToken:@";"];
        

        MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coordinates count:count];
        
//          MAPolygon *polygon = [MAPolygon polygonWithCoordinates:coordinates count:count];
        
        [polylines addObject:polyline];
        free(coordinates), coordinates = NULL;
    }];
    return polylines;
}

//解析经纬度
- (CLLocationCoordinate2D *)coordinatesForString:(NSString *)string
                                 coordinateCount:(NSUInteger *)coordinateCount
                                      parseToken:(NSString *)token
{
    if (string == nil)
    {
        return NULL;
    }
    
    if (token == nil)
    {
        token = @",";
    }
    
    NSString *str = @"";
    if (![token isEqualToString:@","])
    {
        str = [string stringByReplacingOccurrencesOfString:token withString:@","];
    }
    
    else
    {
        str = [NSString stringWithString:string];
    }
    
    NSArray *components = [str componentsSeparatedByString:@","];
    NSUInteger count = [components count] / 2;
    if (coordinateCount != NULL)
    {
        *coordinateCount = count;
    }
    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D*)malloc(count * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < count; i++)
    {
        coordinates[i].longitude = [[components objectAtIndex:2 * i]     doubleValue];
        coordinates[i].latitude  = [[components objectAtIndex:2 * i + 1] doubleValue];
    }
    
    
    return coordinates;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
   
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _searchController.active = NO;
    MapSearchViewController *mapSearchVC = [[MapSearchViewController alloc]initWithNibName:@"MapSearchViewController" bundle:nil];
    
    mapSearchVC.currentCity = _currentCity;
    mapSearchVC.currentLocation = _currentLocation;
    mapSearchVC.searchStr = _searchController.searchBar.text;
    
    mapSearchVC.moveBlock = ^(AMapPOI *poi)
    {
        [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude) animated:YES];
        self.currentPOI = poi;
        //添加大头针
        [self addAnnotation];
    };
    
    
    //    [self presentViewController:mapSearchVC animated:YES completion:nil];
    
    
    [self.navigationController pushViewController:mapSearchVC animated:YES];

}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}


//返回按钮
- (void)leftAction
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
