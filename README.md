# NHNewsBoardPro
news board Architecture for ios(objc) some like neteasy!

##### 前言
先看看demo效果：

![image](https://raw.githubusercontent.com/iFindTA/screenshots/master/neteasy_0.png)


网易新闻的使用率这个大家有目共睹，一些新闻资讯类app的UED也仿照网易（新闻tab）的架构，向大公司看齐这个是好事情(不多说)，本公司也有产品类似的布局，有帅哥疑惑于网易怎么实现的，本人不才简单探索了一下（新闻tab）的布局，并写了个简单的demo效果如上

网上包括git上有各种仿网易的实现，这里使用了 [美团网](http://www.meituan.com/) [董铂然](https://github.com/dsxNiubility) 的catch的网易新闻接口（get接口),前人栽树，咱们拿来用（他的新闻tab实现是scrollView＋controller，这里是collectionView），向他致敬！

如有不对欢迎指正（[nanhujiaju@gmail.com](https://mail.google.com/)）
##### 网易新闻（新闻Tab）的UI层级分析：

######UI层次：
```
NTESNBNavigationController->NTESNBUIViewController->UIViewController
NTESNBTabBarController->NTESNBUIViewController->UIViewController
NTESNBNewsListPageController->NTESNBUIViewController->UIViewController
NTESNBChannelNaviView->UIScrollView
NTESNBPreventScrollingScrollView->UIScrollView
```
######UI分析：
1，UIApplication的根视图为NTESNBNavigationController（继承自NETESNBUIViewController，此Controller继承自UIViewController），此controller较重要，管理着push／pop操作（**而不是tabBar对应的controller去push／pop，原因见下）**，并且要注意：**此导航控制器的navigationBar是hidden的！**
2，NTESNBNavigationController的rootController为NTESNBTabBarController（同样为自定义）
3，NTESNBTabBarController第一个Tab（即新闻tab）为NTESNBNewsListPageController，此controller承载着大家的迷惑，子导航（NTESNBChannelNaviView）就是大家看到的:

![image](https://raw.githubusercontent.com/iFindTA/screenshots/master/neteasy_1.png)

4，再说说大家看到的最最最重要的page页面－－NTESNBPreventScrollingScrollView，此类继承自UIScrollView，高度自定义，加入读者现在订阅的栏目有26个，那么它的contentSize的宽度是26xSCreenWidth，但是每个时刻最多显示6个（最多6个，当栏目个数少于6个时不再讨论），里边的逻辑大家就仁者见仁智者见智吧，demo实现的是最多显示2个，每个page有不同的状态（将要显示时加载旧数据，松手显示时去判断是否加载新数据，不显示时置为低内存状态...）

5，在此不推荐每个page为controller的view（原因：创建的对象不要太重！），可以继承自UIView或直接继承UITableView，以各人喜好

##### 根视图为NavigationController原因猜测：
######1->方便接收通知：
```
	客户端接收到远程通知时，无论此时处于什么页面，均可push相关的通知页面
```
######2->NavigationBar忽隐忽现：
```
	假设：一个普通的NavigationController根视图为A，需要push页面B页面（A页面导航条显示，B页面导航hidden）
    通常的做法：在B页面viewWillAppear和viewWillDisappear控制即可
    问题：当B页面再次pushB页面时候（或多次pushB页面）后，此时手动触发ScreenEdgeGesture（系统自带）注意不要松开，滑动时可以看到前页面的导航条了么？
    手动触发ScreenEdgeGesture时不要出发pop，滑动一半时取消Gesture，最后pop到A页面，如果没有意外，你应该看到了A的导航条的效果
    如果有什么好的办法请告诉我！
```
######3->高度自定义：
```
	这个的好处就不再讨论。
```

###### 持续集成...