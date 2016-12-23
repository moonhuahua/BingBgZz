# BingBgZz 每日桌面Bing壁纸 v1.2

**每日开机运行后会下载当日bing壁纸并设置为桌面壁纸，用完即关**


```AutoHotkey
global DPI:=BG_GetDPI()					;~;默认自动获取;可改为"1024x768"|"1366x768"|"1920x1080"|"1920x1200"(带上双引号)
global bgDay=0							;~;获取必应今天壁纸,1为昨天,以此类推可下载历史壁纸
global bgNum=1							;~;下载bgDay至前1天壁纸数量,最大为前8天
global bgMax=8							;~;下载后最多只保留前8天的壁纸,设置0为不限制数量(注:bgFlag不能为1)
global bgFlag=2							;~;壁纸文件名称形式,0为日期YYYYMMDD,1为英文名称_分辨率,2为英文名称_日期
global bgDir:="D:\Users\Pictures\bing"	;~;壁纸图片下载保存路径
```

用户可自定义配置以上几项，不想看到xml可以设置下载到缓存目录：`SetWorkingDir,%A_Temp%`

---

v1.2更新内容：

+ 获取屏幕的分辨率，根据分辨率下载不同尺寸壁纸，感谢群友`因斯坦爱`提供
+ 壁纸数量超过设定删除最早一张


---

是的，顺带做了下载历史壁纸的隐藏功能：

设置`bgNum = 8`即获取前8天的壁纸;<br>
或者同时再设置`bgDay=8`就是前8天的再前8天壁纸;<br>
最后把 `;~ F2::` 改为 `F2::` 再按 <kbd>F2</kbd> 键开始下载<br>


联系：hui0.0713@gmail.com 讨论QQ群：3222783、271105729、493194474
