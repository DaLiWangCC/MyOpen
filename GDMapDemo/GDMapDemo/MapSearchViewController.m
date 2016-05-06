//
//  MapSearchViewController.m
//  CatEyesDemo
//
//  Created by wanghao on 16/4/29.
//  Copyright © 2016年 wanghao. All rights reserved.
//

//常量
#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height


#import "MapSearchViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "MapViewController.h"

@interface MapSearchViewController ()<UISearchBarDelegate,UISearchResultsUpdating,UITableViewDataSource,UITableViewDelegate,AMapSearchDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic,retain) NSMutableArray *dataList;
@property (strong,nonatomic) NSMutableArray  *searchList;

@property (nonatomic,retain) AMapSearchAPI *search;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;//搜索的文本输入框


@property (nonatomic,assign) BOOL isSelected;//是否点击了搜索，点击之前都是只能匹配
@end

@implementation MapSearchViewController

- (NSMutableArray *)searchList
{
    if (!_searchList) {
        _searchList = [NSMutableArray array];
    }
    return _searchList;
}
- (NSMutableArray *)dataList
{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

//- (UISearchController *)searchController
//{
//    if (!_searchController) {
//         _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
//        _searchController.searchResultsUpdater = self;
//        _searchController.searchBar.delegate = self;
//        _searchController.dimsBackgroundDuringPresentation = NO;
//        _searchController.hidesNavigationBarDuringPresentation = NO;
//        _searchController.searchBar.frame = CGRectMake(kWidth/2 - 100, 20, 200, 44.0);
//    }
//    return _searchController;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    //添加到顶部
    
    
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.searchBar.delegate = self;
    //    _searchController.delegate = self;
    _searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.hidesNavigationBarDuringPresentation = NO;
    _searchController.searchBar.frame = CGRectMake(kWidth/2 - 100, 20, 200, 44.0);
    
    self.navigationItem.titleView = self.searchController.searchBar;


    self.searchController.searchBar.text = _searchStr;
    [_searchController.searchBar becomeFirstResponder];
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backToMapVC)];
    

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CELL"];

    NSLog(@"搜索界面%@,%@",_currentLocation,_currentCity);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_searchController.searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //设置区域的行数(重点),这个就是使用委托之后需要需要判断是一下是否是需要使用Search之后的视图:
    if (!_isSelected) {
        return [self.searchList count];
    }else{
        return [self.dataList count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *flag=@"CELL";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:flag];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:flag];
    }
    //如果搜索框激活
    if (!_isSelected) {
        AMapPOI *poi = _searchList[indexPath.row];
        [cell.textLabel setText:poi.name];
    }
    else{
        AMapPOI *poi = _dataList[indexPath.row];
        [cell.textLabel setText:poi.name];
    }
    return cell;
}


//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    [self.searchController.searchBar resignFirstResponder];

    
    AMapPOI *poi = [[AMapPOI alloc]init];
    //如果搜索框激活
    if (!_isSelected) {
        poi = _searchList[indexPath.row];

    }
    else{
        poi = _dataList[indexPath.row];
    }
    
    NSLog(@"%@,%f,%f",poi.name,poi.location.latitude,poi.location.longitude);
    

     self.moveBlock(poi);

        
    [self.navigationController popViewControllerAnimated:YES];

   
}


#pragma mark -- 代理方法
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    NSLog(@"搜索Begin");
    return YES;
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    
    NSLog(@"搜索End");
    return YES;
}

//搜索框激活时，使用提示搜索
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
   
    //发起输入提示搜索
    AMapInputTipsSearchRequest *tipsRequest = [[AMapInputTipsSearchRequest alloc] init];
    tipsRequest.keywords = _searchController.searchBar.text;
    tipsRequest.city = _currentCity;
    [_search AMapInputTipsSearch: tipsRequest];

}



//搜索

- (IBAction)searchAction:(id)sender {
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    
    //构造AMapPOIAroundSearchRequest对象，设置周边请求参数
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
  
    //当前位置
    request.location = [AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
    
    //关键字
    request.keywords = _searchController.searchBar.text;
    NSLog(@"%@",_searchController.searchBar.text);
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
    [_search AMapPOIAroundSearch:request];
    
}


//实现POI搜索对应的回调函数
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if(response.pois.count == 0)
    {
        return;
    }
    
    //通过 AMapPOISearchResponse 对象处理搜索结果
  
    [self.dataList removeAllObjects];
    for (AMapPOI *p in response.pois) {
        NSLog(@"%@",[NSString stringWithFormat:@"%@\nPOI: %@,%@", p.description,p.name,p.address]);
        
        //搜索结果存在数组
        [self.dataList addObject:p];
    }
    
    _isSelected = YES;
    [self.tableView reloadData];
  
}

//实现输入提示的回调函数
-(void)onInputTipsSearchDone:(AMapInputTipsSearchRequest*)request response:(AMapInputTipsSearchResponse *)response
{
    if(response.tips.count == 0)
    {
        return;
    }
    
    //通过AMapInputTipsSearchResponse对象处理搜索结果
  
    
    //先清空数组
    [self.searchList removeAllObjects];
    for (AMapTip *p in response.tips) {
        
        //把搜索结果存在数组
       
        [self.searchList addObject:p];
    }
  
    _isSelected = NO;
    //刷新表格
    [self.tableView reloadData];
}


- (void)backToMapVC
{
    [self.searchController.searchBar endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
