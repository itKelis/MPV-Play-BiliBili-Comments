# 使用mpv自动下载弹幕并加载

- 配合https://github.com/LuckyPuppy514/Play-With-MPV  油猴脚本
- 仅需一键即可将bilibili弹幕加载到mpv上
- 本项目同时支持 Windows, Linux, Macos(也许) 
-（仍在测试）

## 内容列表

- [使用 MPV 播放网页中的视频](#使用-mpv-播放网页中的视频)
  - [内容列表](#内容列表)
  - [背景](#背景)
    - [配合油猴脚本](#配合油猴脚本)
  - [加载原理](#加载原理)
  - [安装](#安装)
    - [1. 安装 Play-With-MPV油猴脚本](#1-安装-Play-With-MPV油猴脚本)
    - [2. 安装油猴插件](#2-安装油猴插件)
    - [3. 安装 Play-With-MPV 油猴脚本](#3-安装-play-with-mpv-油猴脚本)
    - [4. 添加注册表信息](#4-添加注册表信息)
  - [效果展示](#效果展示)
  - [徽章](#徽章)
  - [相关仓库](#相关仓库)
  - [维护者](#维护者)
  - [如何贡献](#如何贡献)
  - [使用许可](#使用许可)

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

``` text

- Windows 的配置目录默认为: "C:/Users/<你的用户名>/AppData/Roaming/mpv"
-  Linux 的配置目录默认为: "/home/<yourname>/.config/mpv"
 
 ```
### 3.
### 4

### 2

  

 ### 3.将

 ### 1. 安装 mpv 或 mpv-lazy

- 选项一：[🌟 mpv](https://github.com/mpv-player/mpv) + [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- 选项二（推荐）：[🌟🌟mpv-lazy](https://www.lckp.top/archives/mpv-lazy)

### 2. 安装油猴插件

- [Microsoft Edge](https://microsoftedge.microsoft.com/addons/detail/tampermonkey/iikmkjmpaadaobahmlepeloendndfphd)  
- [Google Chrome](https://chrome.google.com/extensions/detail/dhdgffkkebhmkfjojejmpbldmpobfkfo)  
- [Firefox](https://addons.mozilla.org/en-US/firefox/addon/tampermonkey/)  
- [360极速浏览器X](https://chrome.google.com/webstore/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo)  
- [其他 Chromium 内核浏览器](https://chrome.google.com/webstore/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo)

### 3. 安装 Play-With-MPV 油猴脚本

- [Play-With-MPV](https://greasyfork.org/zh-CN/scripts/444056-play-with-mpv)

### 4. 添加注册表信息

```text
Windows Registry Editor Version 5.00  
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome]
"ExternalProtocolDialogShowAlwaysOpenCheckbox"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge]
"ExternalProtocolDialogShowAlwaysOpenCheckbox"=dword:00000001

[HKEY_CLASSES_ROOT\PlayWithMPV]
@="PlayWithMPV Protocol"
"URL Protocol"=""

[HKEY_CLASSES_ROOT\PlayWithMPV\DefaultIcon]
@=""

[HKEY_CLASSES_ROOT\PlayWithMPV\shell]
@=""

[HKEY_CLASSES_ROOT\PlayWithMPV\shell\open]
@=""

[HKEY_CLASSES_ROOT\PlayWithMPV\shell\open\command]
@="cmd /min /V:ON /C \"SET param=\"%1\" & SET param=!param:%%20= ! & SET param=!param:%%22=^\"! & SET param=!param:^\"playwithmpv://=! & D:\\daily\\mpv-lazy\\mpv.com !param:^\"^\"=^\"!\""
```

复制上面的注册表信息，粘贴到记事本，修改最后一行中的

```text
D:\\daily\\mpv-lazy\\mpv.com
```

为你的 mpv 路径，保存为 playwithmpv.reg，双击 playwithmpv.reg 添加到注册表即可

> 🔥 注意：如果你是用 v2rayn 或者 clash 客户端科学上网，则需要把代理加上才可以，例如

```text
D:\\daily\\mpv-lazy\\mpv.com --http-proxy=http://127.0.0.1:10809 --ytdl-raw-options=proxy=[http://127.0.0.1:10809]
```

## 效果展示

![work_on_bilibili_video_tuya](https://cdn.jsdelivr.net/gh/LuckyPuppy514/pic-bed/common/work_on_bilibili_video_tuya.jpg)

![work_on_bilibili_bangumi_tuya](https://cdn.jsdelivr.net/gh/LuckyPuppy514/pic-bed/common/work_on_bilibili_bangumi_tuya.jpg)

![work_on_ddrk_tuya](https://cdn.jsdelivr.net/gh/LuckyPuppy514/pic-bed/common/work_on_ddrk_tuya.jpg)

![work_on_youtube_tuya](https://cdn.jsdelivr.net/gh/LuckyPuppy514/pic-bed/common/work_on_youtube_tuya.jpg)

![work_on_plex_tuya](https://cdn.jsdelivr.net/gh/LuckyPuppy514/pic-bed/common/work_on_plex_tuya.jpg)

![work_on_6dmcc_tuya](https://cdn.jsdelivr.net/gh/LuckyPuppy514/pic-bed/common/work_on_6dmcc_tuya.jpg)

![work_on_dm233_tuya](https://cdn.jsdelivr.net/gh/LuckyPuppy514/pic-bed/common/work_on_dm233_tuya.jpg)

## 徽章

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

## 相关仓库

- [mpv](https://github.com/mpv-player/mpv) — mpv播放器。
- [mpv-lazy](https://github.com/hooke007/MPV_lazy) — mpv播放器懒人版。
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) — 视频下载。
- [ff2mpv](https://github.com/woodruffw/ff2mpv) — 谷歌 MPV 插件。
- [Bilibili-Evolved](https://github.com/the1812/Bilibili-Evolved) - B站增强脚本
- [playwithmpv](https://github.com/videoanywhere/playwithmpv) — B站增强脚本 MPV 播放插件
- [Anime4K](https://github.com/bloc97/Anime4K) — 动漫画质增强
- [Glsl_Running_Mode_Cache](https://github.com/LuckyPuppy514/MPV_Glsl_Running_Mode_Cache) — MPV 着色器运行模式缓存

## 维护者

[@LuckyPuppy514](https://github.com/LuckyPuppy514)

## 如何贡献

非常欢迎你的加入！[提一个 Issue](https://github.com/LuckyPuppy514/Play-With-MPV/issues/new) 或者提交一个 Pull Request。

## 使用许可

[MIT](https://github.com/LuckyPuppy514/Play-With-MPV/blob/main/LICENSE) © LuckyPuppy514
