//
//  ChooseCountryController.m
//  Yoosee
//
//  Created by guojunyi on 14-5-21.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "ChooseCountryController.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "Constants.h"
#import "ChooseCountryCell.h"
#import "SortBar.h"
#import "BindPhoneController.h"
#import "LoginController.h"
#import "NewRegisterController.h"
@interface ChooseCountryController ()

@end

@implementation ChooseCountryController{
    
}

-(void)dealloc{
    [self.bindPhoneController release];
    [self.loginController release];
    [self.registerController release];
    [self.tableView release];
    [self.countrys_en release];
    [self.countrys_zh release];
    [self.countrys release];
    [self.datas release];
    [self.promptView release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.countrys_zh = @[@[@"A",@"阿尔巴尼亚 :355",@"阿尔及利亚 :213",@"阿富汗 :93",@"阿根廷 :54",@"阿拉伯联合酋长国 :971",@"阿鲁巴 :297",@"阿曼 :968",@"阿塞拜疆 :994",@"阿森松岛 :247",@"埃及 :20",@"埃塞俄比亚 :251",@"爱尔兰 :353",@"爱沙尼亚 :372",@"安道尔 :376",@"安哥拉 :244",@"安圭拉 :1264",@"安提瓜和巴布达 :1268",@"澳大利亚 :61",@"奥地利 :43",@"奥兰群岛 :358",@"澳门 :853"],@[@"B",@"巴巴多斯 :1246",@"巴布亚新几内亚 :675",@"巴哈马 :1242",@"巴基斯坦 :92",@"巴拉圭 :595",@"巴勒斯坦 :970",@"巴林 :973",@"巴拿马 :507",@"巴西 :55",@"白俄罗斯 :375",@"百慕大 :1441",@"保加利亚 :359",@"北马里亚纳群岛 :1",@"贝宁 :229",@"比利时 :32",@"冰岛 :354",@"波多黎各 :1787",@"波兰 :48",@"玻利维亚 :591",@"波斯尼亚和黑塞哥维那 :387",@"博茨瓦纳 :267",@"伯利兹 :501",@"不丹 :975",@"布基纳法索 :226",@"布隆迪 :257"],@[@"C",@"朝鲜 :850",@"赤道几内亚 :240"],@[@"D",@"丹麦 :45",@"德国 :49",@"东帝汶 :670",@"多哥 :228",@"多米尼加共和国 :1809",@"多米尼克 :1767"],@[@"E",@"俄罗斯 :7",@"厄瓜多尔 :593",@"厄立特里亚 :291"],@[@"F",@"法国 :33",@"法罗群岛 :298",@"法属波利尼西亚 :689",@"法属圭亚那 :594",@"法属圣马丁 :590",@"梵蒂冈 :379",@"菲律宾 :63",@"斐济 :679",@"芬兰 :358",@"佛得角 :238",@"福克兰群岛 :500"],@[@"G",@"冈比亚 :220",@"刚果（布） :242",@"刚果（金） :243",@"哥伦比亚 :57",@"哥斯达黎加 :506",@"格林纳达 :1473",@"格陵兰 :299",@"格鲁吉亚 :995",@"根西岛 :44",@"古巴 :53",@"瓜德罗普岛 :590",@"关岛 :1671",@"圭亚那 :592"],@[@"H",@"哈萨克斯坦 :7",@"海地 :509",@"韩国 :82",@"荷兰 :31",@"荷兰加勒比 :599",@"荷属圣马丁 :1721",@"黑山共和国 :382",@"洪都拉斯 :504"],@[@"J",@"基里巴斯 :686",@"吉布提 :253",@"吉尔吉斯斯坦 :996",@"几内亚 :224",@"几内亚比绍 :245",@"加拿大 :1",@"加纳 :233",@"加蓬 :241",@"柬埔寨 :855",@"捷克共和国 :420",@"津巴布韦 :263"],@[@"K",@"喀麦隆 :237",@"卡塔尔 :974",@"开曼群岛 :1345",@"科科斯群岛 :61",@"科摩罗 :269",@"科特迪瓦 :225",@"科威特 :965",@"克罗地亚 :385",@"肯尼亚 :254",@"库克群岛 :682",@"库拉索 :599"],@[@"L",@"拉脱维亚 :371",@"莱索托 :266",@"老挝 :856",@"黎巴嫩 :961",@"利比里亚 :231",@"利比亚 :218",@"立陶宛 :370",@"列支敦士登 :423",@"留尼汪 :262",@"卢森堡 :352",@"卢旺达 :250",@"罗马尼亚 :40"],@[@"M",@"马达加斯加 :261",@"马尔代夫 :960",@"马耳他 :356",@"马拉维 :265",@"马来西亚 :60",@"马里 :223",@"马其顿 :389",@"马绍尔群岛 :692",@"马提尼克 :596",@"马约特 :262",@"曼岛 :44",@"毛里求斯 :230",@"毛里塔尼亚 :222",@"美国 :1",@"美属萨摩亚 :1684",@"美属维京群岛 :1340",@"蒙古 :976",@"蒙塞拉特 :1664",@"孟加拉国 :880",@"密克罗尼西亚联邦 :691",@"秘鲁 :51",@"缅甸 :95",@"摩尔多瓦 :373",@"摩洛哥 :212",@"摩纳哥 :377",@"莫桑比克 :258",@"墨西哥 :52"],@[@"N",@"纳米比亚 :264",@"南非 :27",@"南苏丹 :211",@"瑙鲁 :674",@"尼泊尔 :977",@"尼加拉瓜 :505",@"尼日尔 :227",@"尼日利亚 :234",@"纽埃 :683",@"挪威 :47",@"诺福克岛 :6723"],@[@"P",@"帕劳 :680",@"葡萄牙 :351"],@[@"R",@"日本:81",@"瑞典 :46",@"瑞士 :41"],@[@"S",@"萨尔瓦多 :503",@"萨摩亚 :685",@"塞尔维亚 :381",@"塞拉利昂 :232",@"塞内加尔 :221",@"塞浦路斯 :357",@"塞舌尔 :248",@"沙特阿拉伯 :966",@"圣巴泰勒米 :590",@"圣诞岛 :61",@"圣多美和普林西比 :239",@"圣赫勒拿 :290",@"圣基茨和尼维斯 :1869",@"圣卢西亚 :1758",@"圣马力诺 :378",@"圣皮埃尔和密克隆群岛 :508",@"圣文森特和格林纳丁斯 :1784",@"斯里兰卡 :94",@"斯洛伐克 :421",@"斯洛文尼亚 :386",@"斯瓦尔巴特和扬马延 :47",@"斯威士兰 :268",@"苏丹 :249",@"苏里南 :597",@"所罗门群岛 :677",@"索马里 :252"],@[@"T",@"塔吉克斯坦 :992",@"台湾 :886",@"泰国 :66",@"坦桑尼亚 :255",@"汤加 :676",@"特克斯和凯科斯群岛 :1649",@"特里斯坦-达库尼亚群岛 :290",@"特立尼达和多巴哥 :1868",@"突尼斯 :216",@"图瓦卢 :688",@"土耳其 :90",@"土库曼斯坦 :993",@"托克劳 :690"],@[@"W",@"瓦利斯和富图纳 :681",@"瓦努阿图 :678",@"危地马拉 :502",@"委内瑞拉 :58",@"文莱 :673",@"乌干达 :256",@"乌克兰 :380",@"乌拉圭 :598",@"乌兹别克斯坦 :998"],@[@"X",@"西班牙 :34",@"希腊 :30",@"西撒哈拉 :212",@"香港:852",@"新加坡 :65",@"新喀里多尼亚 :687",@"新西兰 :64",@"匈牙利 :36",@"叙利亚 :963"],@[@"Y",@"牙买加 :1876",@"亚美尼亚 :374",@"也门 :967",@"伊拉克 :964",@"伊朗 :98",@"以色列 :972",@"意大利 :39",@"印度 :91",@"印度尼西亚 :62",@"英国 :44",@"英属维京群岛 :1284",@"英属印度洋领地 :246",@"约旦 :962",@"越南 :84"],@[@"Z",@"赞比亚 :260",@"泽西岛 :44",@"乍得 :235",@"直布罗陀 :350",@"智利 :56",@"中非共和国 :236",@"中国:86"]];
    
    self.countrys_en = @[@[@"A",@"Afghanistan:93",@"Aland Islands:358",@"Albania:355",@"Algeria:213",@"America:1",@"Andorra:376",@"Angola:244",@"Anguilla:1264",@"Antigua and Barbuda:1268",@"Argentina:54",@"Armenia:374",@"Aruba:297",@"Ascension:247",@"Australia:61",@"Austria:43",@"Azerbaijan:994"],@[@"B",@"Bahamas:1242",@"Bahrain:973",@"Bangladesh:880",@"Barbados:1246",@"Belarus:375",@"Belgium:32",@"Belize:501",@"Benin:229",@"Bermuda:1441",@"Bhutan:975",@"Bolivia:591",@"Bosnia and Herzegovina:387",@"Botswana:267",@"Brazil:55",@"Britain:44",@"British Indian Ocean Territory:246",@"British Virgin Islands:1284",@"Brunei:673",@"Bulgarian:359",@"Burkina Faso:226",@"Burundi:257"],@[@"C",@"Cambodia:855",@"Cameroon:237",@"Canada:1",@"Cape Verde:238",@"Cayman Islands:1345",@"Central African Republic:236",@"Chad:235",@"Chile:56",@"China:86",@"Christmas Island:61",@"Cocos Islands:61",@"Colombia:57",@"Comoros:269",@"Congo (Brazzaville):242",@"Congo (DRC):243",@"Cook Islands:682",@"Costa Rica:506",@"Croatia:385",@"Cuba:53",@"Curacao:599",@"Cyprus:357",@"Czech Republic:420",@"C?te d'Ivoire:225"],@[@"D",@"Denmark:45",@"Djibouti:253",@"Dominica:1767",@"Dominican Republic:1809",@"Dutch Caribbean:599"],@[@"E",@"East Timor:670",@"Ecuador:593",@"Egypt:20",@"El Salvador:503",@"Equatorial Guinea:240",@"Eritrea:291",@"Estonia:372",@"Ethiopia:251"],@[@"F",@"Falkland Islands:500",@"Faroe Islands:298",@"Federated States of Micronesia:691",@"Fiji:679",@"Finland:358",@"France:33",@"French Guiana:594",@"French Polynesia:689",@"French St. Martin:590"],@[@"G",@"Gabon:241",@"Gambia:220",@"Georgia:995",@"Germany:49",@"Ghana:233",@"Gibraltar:350",@"Greece:30",@"Greenland:299",@"Grenada:1473",@"Guadeloupe:590",@"Guam:1671",@"Guatemala:502",@"Guernsey:44",@"Guinea-Bissau:245",@"Guinea:224",@"Guyana:592"],@[@"H",@"Haiti:509",@"Honduras:504",@"Hong Kong:852",@"Hungary:36"],@[@"I",@"Iceland:354",@"India:91",@"Indonesia:62",@"Iran:98",@"Iraq:964",@"Ireland:353",@"Isle of Man:44",@"Israel:972",@"Italy:39"],@[@"J",@"Jamaica:1876",@"Japan:81",@"Jersey:44",@"Jordan:962"],@[@"K",@"Kazakhstan:7",@"Kenya:254",@"Kirghizstan:996",@"Kiribati:686",@"Korea:82",@"Korea:850",@"Kuwait:965"],@[@"L",@"Laos:856",@"Latvia:371",@"Lebanon:961",@"Lesotho:266",@"Liberia:231",@"Libya:218",@"Liechtenstein:423",@"Lithuania:370",@"Luxembourg:352"],@[@"M",@"Macao:853",@"Macedonia:389",@"Madagascar:261",@"Malawi:265",@"Malaysia:60",@"Maldives:960",@"Mali:223",@"Malta:356",@"Martinique:596",@"Mauritania:222",@"Mauritius:230",@"Mayotte:262",@"Mexico:52",@"Moldova:373",@"Monaco:377",@"Mongolia:976",@"Monserrate:1664",@"Montenegro:382",@"Morocco:212",@"Mozambique:258",@"Myanmar:95"],@[@"N",@"Namibia:264",@"Nauru:674",@"Nepal:977",@"Netherlands:31",@"New Caledonia:687",@"New Zealand:64",@"Nicaragua:505",@"Niger:227",@"Nigeria:234",@"Niue:683",@"Norfolk Island:6723",@"Northern Mariana Islands:1",@"Norway:47"],@[@"O",@"Oman:968"],@[@"P",@"Pakistan:92",@"Palau:680",@"Palestine:970",@"Panama:507",@"Papua New Guinea:675",@"Paraguay:595",@"Peru:51",@"Philippines:63",@"Poland:48",@"Portugal:351",@"Puerto Rico:1787"],@[@"Q",@"Qatar:974"],@[@"R",@"Reunion:262",@"Romania:40",@"Russia:7",@"Rwanda:250"],@[@"S",@"Saint Barthelemy:590",@"Saint Kitts and Nevis:1869",@"Saint Martin:1721",@"Saint Pierre and Miquelon:508",@"Saint Vincent and the Grenadines:1784",@"Samoa:1684",@"Samoa:685",@"San Marino:378",@"Sao Tome and Principe:239",@"Saudi Arabia:966",@"Senegal:221",@"Serbia:381",@"Seychelles:248",@"Sierra Leone:232",@"Singapore:65",@"Slovakia:421",@"Slovenia:386",@"Solomon Islands:677",@"Somalia:252",@"South Africa:27",@"South Sudan:211",@"Spain:34",@"Sri Lanka:94",@"St. Helena:290",@"St. Lucia:1758",@"Sudan:249",@"Surinam:597",@"Svalbard and Jan Mayen:47",@"Swaziland:268",@"Sweden:46",@"Switzerland:41",@"Syria:963"],@[@"T",@"Taiwan:886",@"Tajikistan:992",@"Tanzania:255",@"Thailand:66",@"The Marshall Islands:692",@"The Vatican:379",@"Togo:228",@"Tokelau:690",@"Tonga:676",@"Trinidad and Tobago:1868",@"Tristan - da Cunha:290",@"Tunisia:216",@"Turkey:90",@"Turkmenistan:993",@"Turks and Caicos Islands:1649",@"Tuvalu:688"],@[@"U",@"U.S. Virgin Islands:1340",@"Uganda:256",@"Ukraine:380",@"United Arab Emirates:971",@"Uruguay:598",@"Uzbekistan:998"],@[@"V",@"Vanuatu:678",@"Venezuela:58",@"Vietnam:84"],@[@"W",@"Wallis and Futuna:681",@"Western Sahara:212"],@[@"Y",@"Yemen:967"],@[@"Z",@"Zambia:260",@"Zimbabwe:263"]];
    
    
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    DLog("%@",language);
    if([language hasPrefix:@"zh"]){
        self.datas = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"J",@"K",@"L",@"M",@"N",@"P",@"R",@"S",@"T",@"W",@"X",@"Y",@"Z"];
        self.countrys = [NSArray arrayWithArray:self.countrys_zh];
    }else{
        self.datas = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"Y",@"Z"];
        self.countrys = [NSArray arrayWithArray:self.countrys_en];
    }
    
    [super viewDidLoad];
    [self initComponent];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define ITEM_HEIGHT 46
#define HEADER_HEIGHT 30
#define SORT_BAR_WIDTH 36
#define PROMPT_VIEW_WIDTH_HEIGHT 50
-(void)initComponent{
    
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    [self.view setBackgroundColor:XBgColor];
    
    /*
     *topBar 自定义一个导航栏
     */
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar setTitle:NSLocalizedString(@"choose_country",nil)];
    [self.view addSubview:topBar];
    [topBar release];
    
    /*
     *tableView表格视图
     *功能：显示国家信息
     */
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    [tableView setBackgroundColor:XBGAlpha];
    tableView.backgroundView = nil;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
    if(CURRENT_VERSION>=7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
   /*
    *sortBar表示右边的索引
    *功能：快速选择国家
    *操作：点击选中或者移动松开后选中
    */
    SortBar *sortBar = [[SortBar alloc] initWithDatas:self.datas frame:CGRectMake(width-SORT_BAR_WIDTH, NAVIGATION_BAR_HEIGHT, SORT_BAR_WIDTH, height-NAVIGATION_BAR_HEIGHT)];
    sortBar.delegate = self;
    [self.view addSubview:sortBar];
    [sortBar release];
    
    UILabel *promptView = [[UILabel alloc] initWithFrame:CGRectMake((width-PROMPT_VIEW_WIDTH_HEIGHT)/2, (height-PROMPT_VIEW_WIDTH_HEIGHT)/2, PROMPT_VIEW_WIDTH_HEIGHT, PROMPT_VIEW_WIDTH_HEIGHT)];
    promptView.layer.cornerRadius = 3.0;
    promptView.layer.borderWidth = 2.0;
    promptView.layer.borderColor = [XBlack CGColor];
    promptView.backgroundColor = XBlue;
    
    promptView.textAlignment = NSTextAlignmentCenter;
    promptView.textColor = XWhite;
    promptView.font = XFontBold_18;
    [promptView setHidden:YES];
    [self.view addSubview:promptView];
    self.promptView = promptView;
    [promptView release];
}

-(void)onBackPress{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.countrys count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self.countrys objectAtIndex:section] count]-1;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ITEM_HEIGHT;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"ChooseCountryCell";
    ChooseCountryCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(cell==nil){
        cell = [[ChooseCountryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    int section = indexPath.section;
    int row = indexPath.row;
   
    
    NSString *data = [[self.countrys objectAtIndex:section] objectAtIndex:row+1];
    NSArray *dataArray = [data componentsSeparatedByString:@":"];
    [cell setLeftLabelText:[dataArray objectAtIndex:0]];
    [cell setRightLabelText:[dataArray objectAtIndex:1]];
    
    
    
    UIImage *backImg = [UIImage imageNamed:@"bg_normal_cell.png"];
    UIImage *backImg_p = [UIImage imageNamed:@"bg_normal_cell_p.png"];

    
    UIImageView *backImageView = [[UIImageView alloc] init];
    backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.5 topCapHeight:backImg.size.height*0.5];
    backImageView.image = backImg;
    [cell setBackgroundView:backImageView];
    [backImageView release];
    
    UIImageView *backImageView_p = [[UIImageView alloc] init];
    
    backImg_p = [backImg_p stretchableImageWithLeftCapWidth:backImg_p.size.width*0.5 topCapHeight:backImg_p.size.height*0.5];
    backImageView_p.image = backImg_p;
    [cell setSelectedBackgroundView:backImageView_p];
    [backImageView_p release];
    
    
    
    
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HEADER_HEIGHT;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, HEADER_HEIGHT)] autorelease];
    view.backgroundColor = [UIColor grayColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, width-30, HEADER_HEIGHT)];
    
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = XBlue;
    label.backgroundColor = XBGAlpha;
    label.font = XFontBold_18;
    label.text = [[self.countrys objectAtIndex:section] objectAtIndex:0];
    [view addSubview:label];
    [label release];
    return view;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *data = [[self.countrys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row+1];
    NSArray *dataArray = [data componentsSeparatedByString:@":"];
    
    if(self.bindPhoneController){
        self.bindPhoneController.countryName = [dataArray objectAtIndex:0];
        self.bindPhoneController.countryCode = [dataArray objectAtIndex:1];
    
        self.bindPhoneController.leftLabel.text = [NSString stringWithFormat:@"+%@",self.bindPhoneController.countryCode];
        self.bindPhoneController.rightLabel.text = self.bindPhoneController.countryName;
    }
    
    if(self.loginController){
        self.loginController.countryName = [dataArray objectAtIndex:0];
        self.loginController.countryCode = [dataArray objectAtIndex:1];
        
        self.loginController.leftLabel.text = [NSString stringWithFormat:@"+%@",self.loginController.countryCode];
        self.loginController.rightLabel.text = self.loginController.countryName;
    }
    
    if(self.registerController){
        self.registerController.countryName = [dataArray objectAtIndex:0];
        self.registerController.countryCode = [dataArray objectAtIndex:1];
        
        self.registerController.leftLabel.text = [NSString stringWithFormat:@"+%@",self.registerController.countryCode];
        self.registerController.rightLabel.text = self.registerController.countryName;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)onSortBarChange:(SortBar *)sortBar index:(NSInteger)index{
    NSIndexPath *toPath = [NSIndexPath indexPathForRow:0 inSection:index];
    [self.tableView scrollToRowAtIndexPath:toPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    self.promptView.text = [[self.countrys objectAtIndex:index] objectAtIndex:0];
    [self.promptView setHidden:NO];
}

-(void)onSortBarTouchEnd:(SortBar *)sortBar{
    [self.promptView setHidden:YES];
}

-(BOOL)shouldAutorotate{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interface {
    return (interface == UIInterfaceOrientationPortrait );
}

#ifdef IOS6

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
#endif

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
@end
