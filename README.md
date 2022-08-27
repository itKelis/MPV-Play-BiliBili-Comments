# 使用mpv自动下载弹幕并加载

- 配合https://github.com/LuckyPuppy514/Play-With-MPV  油猴脚本
- 仅需一键即可将bilibili弹幕加载到mpv上
- 本项目同时支持 Windows, Linux, Macos(也许) 
-（仍在测试）

windows系统使用windows文件夹下的代码

## 背景

mpv加载弹幕的过程太过于繁琐，需要手动寻找cid下载xml弹幕，随后将xml转换成ass文件之后再手动加载到视频当中，于是就诞生了这个小插件

### 配合脚本

搭配油猴脚本：https://greasyfork.org/en/scripts/416271-play-with-mpv

github主页: https://github.com/LuckyPuppy514/Play-With-MPV

配合该油猴脚本可以实现b站视频流一键推送到mpv，一键加载视频弹幕

> 目前仍需对该油猴脚本代码进行修改才能正常运行

## 加载原理

1.使用mpv的 --script-opts 参数给此插件传递视频的cid，

2.插件获取视频的cid后拉起python自动完成下载xml字幕文件并转换为.ass文件存放到指定目录

3.插件得到python发出的done提示后，重新加载指定目录下的ass文件即可完成加载


## 安装


### 1.安装Play-With-MPV油猴脚本

- 本mpv插件运行在Play-With-MPV 油猴脚本基础上，请先依据Play-With-MPV主页安装完成

- 油猴脚本主页： https://greasyfork.org/zh-CN/scripts/444056-play-with-mpv

### 2.将本仓库scripts文件夹下载到mpv配置目录

Windows 的配置目录默认为: 
``` text
"C:\Users\<你的用户名>\AppData\Roaming\mpv"
```
Linux 的配置目录默认为: 
``` text
"/home/<你的用户名>/.config/mpv"
 ```
### 3.配置mpv.conf
将下列配置直接粘贴到mpv.conf中
``` text
#让mpv自动搜索存放弹幕的文件夹(默认在插件文件夹的subs目录)
#Windows
##windows下sub字段使用分号;
--sub-file-paths=sub;subtitles;Subs;C:\\Users\\<你的用户名>\\AppData\\Roaming\\mpv\\scripts\\bilibiliAssert\\subs
#Linux
## 注意linux下sub字段使用冒号:
#--sub-file-paths=sub:subtitles:Subs:/home/<你的用户名>/.config/mpv/scripts/bilibiliAssert/subs/
#
#让弹幕更平滑
--sub-fps=60
```
### 4.配置main.lua
找到scripts/bilibiliAssert/main.lua
``` text
local python_path = "/usr/bin/python"  -- 修改为你的python程序位置注意windows要两个斜杠
local scripts_path = '/home/szjkelis/.config/mpv/scripts' -- 修改为mpv的scripts目录位置
```

### 6.修改油猴脚本


油猴脚本可以使用我的修改版，点击即可，与原版共存：https://github.com/itKelis/BiliBili-Play-With-MPV/raw/main/play-with-mpv.user.js

打开油猴脚本的代码
``` text
//在146行修添加全局变量 cid
var cid;
//在286行将let关键字去掉，变为
cid = res.data.cid;
//在344行将var关键字去掉，变为
cid = episode.cid;
//在179行变为(添加参数cid用于下载字幕)
protocolLink = protocolLink + '--http-header-fields=referer:"' + currentUrl + ',user-agent:' + navigator.userAgent + '" ' +' --script-opts="cid=' + cid + '" ';
```

### 完成
在网页中点击mpv图标将视频流传输到mpv后按下b键即可自动加载弹幕

- 如果希望更改快捷键，在main.lua中最后一行修改想要的快捷键

## 对弹幕的个性化定制
本项目使用了danmaku2ass的代码，可以对弹幕的样式进行深度定制

如有客制化需求，可以自行对convertAss.py进行修改
