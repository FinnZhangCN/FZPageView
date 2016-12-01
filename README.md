# FZPageView
利用NSTIme以及ScrollView实现的图片轮播器,内置Pagecontrol

''objc

//使用initWithFrame进行创建
FZPageView *pageView = [[FZPageView alloc] initWithFrame:CGRectMake(30, 100, 300, 130)];
//以数组的方式为其传入轮播图片
pageView.images = @[image1,image2];
//设置轮播间隔时间(秒)并开启轮播(注意:必须传入大于0的参数)
[pageView startWithTimeInterval:2];
''objc
