# NHNewsBoardPro
news board Architecture for ios(objc) some like neteasy!

##### 前言
先看效果：
![image](https://raw.githubusercontent.com/iFindTA/screenshots/master/neteasy_0.png)
网易新闻的使用率这个大家有目共睹，一些新闻资讯类app的UED也仿照网易（新闻tab）的架构，向大公司看齐这个是好事情(不多说)，本公司也有产品类似的布局，有帅哥疑惑于网易怎么实现的，本人不才简单探索了一下（新闻tab）的布局，并写了个简单的demo效果如上

网上包括git上有各种仿网易的实现，这里使用了 [美团网](http://www.meituan.com/) [董铂然](https://github.com/dsxNiubility) 的catch的网易新闻接口（get接口),前人栽树，咱们拿来用（他的新闻tab实现是scrollView＋controller，这里是collectionView），向他致敬！

如有不对欢迎指正（[nanhujiaju@gmail.com](https://mail.google.com/)）
##### 网易新闻（新闻Tab）的UI层级分析：

1，UIApplication的根视图为NTESNBNavigationController（继承自NETESNBUIViewController，此Controller继承自UIViewController），此controller较重要，管理着push／pop操作（**而不是tabBar对应的controller去push／pop，原因见下）**，并且要注意：**此导航控制器的navigationBar是hidden的！**
2，NTESNBNavigationController的rootController为NTESNBTabBarController（同样为自定义）
3，NTESNBTabBarController第一个Tab（即新闻tab）为NTESNBNewsListPageController，此controller承载着大家的迷惑，子导航（NTESNBChannelNaviView）就是大家看到的:

![image](https://raw.githubusercontent.com/iFindTA/screenshots/master/neteasy_1.png)

4，再说说大家看到的最最最重要的pageScrollView，此类继承自UIScrollView，高度自定义，加入读者现在订阅的栏目有26个，那么它的contentSize的宽度是26xSCreenWidth，但是每个时刻最多显示6个（最多6个，当栏目个数少于6个时不再讨论），里边的逻辑大家就仁者见仁智者见智吧，demo实现的是最多显示2个，每个page有不同的状态（将要显示时加载旧数据，松手显示时去判断是否加载新数据，不显示时置为低内存状态...）

5，在此不推荐每个page为controller的view（原因：创建的对象不要太重！），可以继承自UIView或直接继承UITableView，以各人喜好

6，其他的可在demo效果中找找（持续集成...）
