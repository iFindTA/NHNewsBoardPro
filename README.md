# NHNewsBoardPro
news board Architecture for ios(objc) some like neteasy!

##### 前言
support：iOS7.0+，如果觉得对你有所帮助请给个星星 star！
##### Version2.0先看看demo效果：

![gif](https://raw.githubusercontent.com/iFindTA/screenshots/master/neteasy_g0.gif)

#####版本2.0 看点总结：
```
1>.完全自定义NHPreventScrollview（模仿网易的NTESNBPreventScrollingScrollView类自己简易实现逻辑，同一时刻最多显示6个page）
2>.隐藏导航条类似网易布局导航
3>.栏目订阅、取消订阅、拖动排序（非基于手势）同步呈现
4>.黑夜、白天阅读模式怎么优雅地切换（包括在不修改MJRefresh源码情况下简易设置支持阅读模式切换）
5>.为什么滚动重用机制弃用UICollectionView实现方式（1.0版本方式）
6>.其他未提及到的小知识点可在demo中查看
```

#####UI结构：

![image](https://raw.githubusercontent.com/iFindTA/screenshots/master/neteasy_3.png)

#####重要看点简介：
1.NHViewController
```
该类继承于UIViewController，是视图控制器的基类，实现了一些诸如初始化导航条、注册导航按钮、预加载复杂类、统一页面布局等功能
```
2.NHPreventScroller
```
主视图中最重要的类之一，完全自定义模仿网易的NTESNBPreventScrollingScrollView来管理不同页面的切换，特性有：支持增加、取消订阅栏目、排序栏目位置、同一时刻最多显示6个页面，具体实现见demo代码
```
3.NHEditChannelVCR
```
该类实现了频道编辑功能：订阅、取消订阅、拖动排序等功能，具体见代码
```
4.NHWinAnimatorVCR
```
优雅的切换白天、黑夜阅读模式
```
5.为什么弃用UICollectionView实现方式
```
＊在栏目编辑状态下，拖动排序交换对应page不方便
＊使用到了CollectionView的willDisplay方法，该方法仅在iOS8.0+有效
＊最多只能支持2个重用page在同一时刻，不满足需求
＊其他未使用原因
```
6.在不修改MJRefresh源码情况下设置黑夜白天模式切换
```
很简单，keyPath for value！
```

#####未完待续点：
```
＊详情页的CSS＋JS布局实现
＊排序后的栏目顺序缓存到数据库（相对简单读者可自行尝试）
＊接收通知
＊广告启动图的加入
＊更好的适配夜间模式
＊其他作者能有能力添加的项
```
######Feedback: nanhujiaju@gmail.com
###### 持续集成...

* * *


##### Version1.0先看看demo效果：

![image](https://raw.githubusercontent.com/iFindTA/screenshots/master/neteasy_0.png)


网易新闻的使用率这个大家有目共睹，一些新闻资讯类app的UED也仿照网易（新闻tab）的架构，向大公司看齐这个是好事情(不多说)，本公司也有产品类似的布局，有帅哥疑惑于网易怎么实现的，本人不才简单探索了一下（新闻tab）的布局，并写了个简单的demo效果如上

网上包括git上有各种仿网易的实现，这里使用了 [美团网](http://www.meituan.com/) [董铂然](https://github.com/dsxNiubility) 的catch的网易新闻接口（get接口),前人栽树，咱们拿来用（他的新闻tab实现是scrollView＋controller，这里是collectionView），向他致敬！

如有不对欢迎指正（[nanhujiaju@gmail.com](https://mail.google.com/)）
##### 网易新闻（新闻Tab）的UI层级分析：

######UI层次：

![image](https://raw.githubusercontent.com/iFindTA/screenshots/master/neteasy_2.png)

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

#####Attention:此项目仅供学习交流参考，请勿用于商业目的!

###### 持续集成...