/*
╔═════════════════════════════════
║【BingBgZz】每日桌面Bing壁纸 v1.4
║ 联系：hui0.0713@gmail.com
║ 讨论QQ群：3222783、271105729、493194474
║ by Zz @2016.12.23
║ 最新版本：github.com/hui-Zz/BingBgZz
║═════════════════════════════════
║ 增加1.每次壁纸肯定不重复和2.运行后3秒内再次运行则删除当前壁纸的功能
╚═════════════════════════════════
*/
#NoEnv					;~;不检查空变量为环境变量
FileEncoding,UTF-8		;~;下载的XML以中文编码加载
SetBatchLines,-1		;~;脚本全速执行(默认10ms)
SetWorkingDir,%A_ScriptDir%	;~;脚本当前工作目录
#Include Gdip.ahk
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;~;【用户自定义变量】
global bgDay=0			;~;下载必应今天壁纸,1为昨天,以此类推可下载历史壁纸0
global bgNum=8			;~;下载bgDay至前1天壁纸数量,最大为前8天8
global bgMax=0			;~;下载后最多只保留前8天的壁纸,设置0为不限制数量(注:bgFlag不能为1)8
global bgFlag=2			;~;壁纸文件名称形式,0为日期YYYYMMDD,1为英文名称_分辨率,2为英文名称_日期2
global bgDir:=A_ScriptDir "\bing" ;~;壁纸图片保存路径,如bgMax不是0必须是单独文件夹,防止丢失其他图片
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;~;【初始化全局变量】
;~;默认自动根据分辨率获取,可固定为"1024x768"|"1366x768"|"1920x1080"|"1920x1200"(带上双引号)
global DPI:=BG_GetDPI()	
;~;必应壁纸XML地址
global bing:="http://cn.bing.com"
global bgImg:=bing "/HPImageArchive.aspx?idx=" bgDay "&n=" bgNum
global bgXML			;~;XML配置内容
global bgImgUrl			;~;壁纸下载地址
global bgPath			;~;壁纸保存路径

global LastTime
global Lastrool
global LastbgPath

IfNotExist, %bgDir%
	FileCreateDir, %bgDir%
XML_Download()
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
IfNotExist, A_ScriptDir \Timing.ini
	FileAppend, , A_ScriptDir \Timing.ini
IniRead, LastTime, Timing.ini, LastTime, LastTime
IniRead, LastbgPath, Timing.ini, LastbgPath, LastbgPath
IniRead, Lastrool, Timing.ini, Lastrool, Lastrool
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;~;【读取XML,下载图片,设置桌面背景,如已下载则随机更换壁纸】
;~ F1::
	FileRead, bgXML, %A_ScriptDir%\bingImg.xml
	RegExMatch(bgXML, "<url>(.*?)</url>", bgUrl)
	RegExMatch(bgXML, "<enddate>(.*?)</enddate>", bgDate)
	BG_GetImgUrlPath(bgUrl1,bgDate1)
	IfNotExist,%bgPath%
	{
		RegExMatch(bgXML, "<copyright>(.*?)</copyright>", bgCR)
		ToolTip,%bgCR1%,A_ScreenWidth,A_ScreenHeight
		;~ Sleep 3000
		BG_Download()
		BG_DownFail()
		BG_Wallpapers()
		;~ BG_DeleteBefore()		;——————————
	}else{
		FileCopy, %bgDir%, %bgDir%
		Loop 9
		{
			Random, roll, 1, %ErrorLevel%
			if roll!=%Lastrool%
				break
		}
		if (ErrorLevel=1)		;只有一张图片
		{
			ToolTip, 只有一张图片-显示2秒
			Sleep 2000
			ToolTip
			return
		}
		Loop, %bgDir%\*.jpg
		{
			if(A_Index=roll){
				bgPath:=A_LoopFileLongPath
				;~ Clipboard=%bgPath%
				;~ MsgBox, 0, , %bgPath%, 3
				Sleep 200
				BG_Wallpapers()
			}
		}
	}

if (A_TickCount-LastTime)<(3*1000)
{
	FileDelete, %LastbgPath%
}
LastTime := A_TickCount
IniWrite, %LastTime%, Timing.ini, LastTime, LastTime
IniWrite, %bgPath%, Timing.ini, LastbgPath, LastbgPath
IniWrite, %roll%, Timing.ini, Lastrool, Lastrool

Loop, 3
{
	count++
	durTime := 4 - count
	;~ ToolTip, %durTime%秒内再次运行删除当前壁纸！！！
	ToolTip, %Lastrool%——%roll%————%durTime%秒内再次运行删除当前壁纸！！！		;%Lastrool%——%roll%————
	sleep 1000
}
ToolTip

return
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;~;【批量下载历史壁纸,搭配bgDay和bgNum使用】
;~ F2::
	FileRead, bgXML, %A_ScriptDir%\bingImg.xml
	pos = 1
	While, pos := RegExMatch(bgXML, "<enddate>(.*?)</enddate>", bgDate, pos + 1)
	{
		DPI:=BG_GetDPI()
		RegExMatch(bgXML, "<url>(.*?)</url>", bgUrl, pos)
		BG_GetImgUrlPath(bgUrl1,bgDate1)
		BG_Download()
		BG_DownFail()
		bgPaths .= bgPath . "`n"
	}
	MsgBox,下载完成`n%bgPaths%
return
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;~;【获取壁纸下载地址和保存路径】
BG_GetImgUrlPath(bgUrl1,bgDate1){
	RegExMatch(bgUrl1, "[^/]+$", bgName)
	if(bgFlag=1){
		bgName:=RegExReplace(bgName, "i)[^_]+\.jpg$", DPI ".jpg")
	}else if(bgFlag=2){
		bgName:=RegExReplace(bgName, "i)[^_]+\.jpg$", bgDate1 ".jpg")
	}else{
		bgName:=bgDate1 . ".jpg"
	}
	bgImgUrl=%bing%%bgUrl1%
	bgImgUrl:=RegExReplace(bgImgUrl, "i)[^_]+\.jpg$", DPI ".jpg")
	bgPath=%bgDir%\%bgName%
}
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;~;【下载必应壁纸XML配置信息】
XML_Download(){
	URLDownloadToFile,%bgImg%,%A_ScriptDir%\bingImg.xml
}
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;~;【下载必应壁纸图片】
BG_Download(){
	SysGet, Mon, Monitor
	URLDownloadToFile, %bgImgUrl%, %bgPath%
	Value= %MonRight%|%MonBottom%
	convert_resize(bgPath,"C:/Convert.jpg","k_fixed_width_height",Value,"0xde000000")
	FileCopy, C:/Convert.jpg, %bgPath%, 1
	FileDelete, C:/Convert.jpg
}
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;~;【必应壁纸设置为桌面壁纸】
BG_Wallpapers(){
	DllCall("SystemParametersInfo", UInt, 0x14, UInt,0, Str,"" bgPath "", UInt, 2)
}
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;~;【获取屏幕的分辨率】
BG_GetDPI(){
	SysGet, Mon, Monitor
	ratio := MonRight/MonBottom
	if (ratio = 16/9)
		return "1920x1080"
	else if (ratio = 16/10)
		return "1920x1200"
	else if (ratio = 4/3)
		return "1024x768"
	else if (MonRight = 1366 && MonBottom = 768)
		return "1366x768"
	else
		return "1920x1080"
}
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;~;【壁纸数量超过设定删除最早一张】
BG_DeleteBefore(){
	if(bgFlag!=1 && bgMax>0){
		FileCopy, %bgDir%, %bgDir%
		if(bgMax<ErrorLevel){
			tMax := 1
			tPath := bgPath
			Loop,%bgDir%\*.jpg
			{
				t1 := A_Now
				t2 := A_LoopFileTimeCreated
				t1 -= %t2%, Days
				if(t1>tMax){
					tMax := t1
					tPath := A_LoopFileLongPath
				}
			}
			if(RegExMatch(tPath, "i)[0-9]{8}\.jpg$")){
				FileDelete, %tPath%
			}
		}
	}
}
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;~;【下载壁纸失败后用其它分辨率替代】
BG_DownFail(){
	FileGetSize, bgSize, %bgPath%
	if (!FileExist(bgPath) || bgSize=0){
		DPI:="1920x1080"
		BG_GetImgUrlPath(bgUrl1,bgDate1)
		BG_Download()
	}
}
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
RemoveWallpapers:
BG_Wallpapers()
MsgBox, 4, , %bgPath%&&&&%LastbgPath%, 3
return
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;~;【更换壁纸大小的函数】
convert_resize(source_file,out_file,function="",value=1,color="0xff000000"){
	;source_file 源文件路径
	;out_file 输转换图片输出路径
	;function 功能选择，k_ratio（固定比例）  k_width（只改宽） k_height（只改高） k_fixed_width_height（宽高同时修改）
	;value 图片宽高的数值
	;color 放大时填充的颜色像素
	if !pToken := Gdip_Startup()
	{
		MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
		ExitApp
	}

	if (source_file="clipboard")
		pBitmapFile :=Gdip_CreateBitmapFromClipboard()
	else
		pBitmapFile :=Gdip_CreateBitmapFromFile(source_file)

	Width := Gdip_GetImageWidth(pBitmapFile), Height := Gdip_GetImageHeight(pBitmapFile)
	ratio=1
	if (function = "k_ratio")
	{
		ratio:=value
		w:=width*ratio
		h:=height*ratio
	}
	if (function = "k_width")
	{
		ratio:=value/width
		w:=width*ratio
		h:=height*ratio
	}
	if (function = "k_height")
	{
		ratio:=value/height
		w:=width*ratio
		h:=height*ratio
	}

	if (function = "k_fixed_width_height")
	{
		StringSplit,out,value,|
		wf:=out1
		hf:=out2
		if !wf or ! hf
		{
			MsgBox error in value parameter for fixed width and height
			Gdip_Shutdown(pToken)
			return
		}

		if (width>wf)
		{
			r1:=wf/width

			w:=wf
			h:=height*r1

			if (h>hf)
			{
				r2:=hf/h
				w:=w*r2
				h:=hf
			}
		}
		else
		{
			if (width<wf) and (height<hf)
			{
				w:=width
				h:=height
			}
			else
			{
				r1:=hf/height

				h:=hf
				w:=width*r1

				if (w>wf)
				{
					r2:=wf/w
					w:=wf
					h:=hf*r2
				}
			}
		}
	}

	if (function = "k_fixed_width_height")
		pBitmap := Gdip_CreateBitmap(wf, hf)
	else
		pBitmap := Gdip_CreateBitmap(w,h)

	G := Gdip_GraphicsFromImage(pBitmap)

	if (function = "k_fixed_width_height")
	{
		pbrush:=Gdip_BrushCreateSolid(color)
		Gdip_FillRectangle(G, pBrush, 0, 0, wf, hf)

		x:=Floor((wf-w)/2)
		y:=Floor((hf-h)/2)
	}
	else
	{
		x=0
		y=0
	}



	Gdip_DrawImage(G, pBitmapFile, x, y, w, h, 0, 0, Width, Height)
	Gdip_SaveBitmapToFile(pBitmap, out_file)
	if (function = "k_fixed_width_height")
		Gdip_DeleteBrush(pBrush)
	Gdip_DisposeImage(pBitmapFile)
	Gdip_DisposeImage(pBitmap)
	Gdip_DeleteGraphics(G)
	Gdip_Shutdown(pToken)
}
