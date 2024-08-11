# 使用mpv自动下载弹幕并加载

- 配合 yt-dlp 或 https://github.com/LuckyPuppy514/Play-With-MPV  油猴脚本
- 仅需一键即可将bilibili弹幕加载到mpv上
- 本项目同时支持 Windows, Linux, Macos(也许) 
- 弹幕体验与b站播放器几乎没有区别
- 核心代码由Danmu2Ass修改而来，并对性能进行优化，加载时间可以忽略不计
- python>=3.6即可运行，完全使用python内置库编写无需安装第三方库，并提供可执行文件，没有python也可以运行
- 脚本使用异步运行，对视频加载无影响



## 背景

mpv加载弹幕的过程太过于繁琐，需要手动寻找cid下载xml弹幕，随后将xml转换成ass文件之后再手动加载到视频当中，于是就诞生了这个小插件

## 运行效果

b站播放器：
![image](https://user-images.githubusercontent.com/14844805/188661589-3ace06fc-5f40-4a6e-adfb-a46c80fe01bf.png)

mpv使用插件后：
![image](https://user-images.githubusercontent.com/14844805/188661757-ff42a04c-60a6-4ab7-8bae-2bb260980751.png)


### （可选）配合脚本

搭配油猴脚本：https://greasyfork.org/en/scripts/444056-play-with-mpv

github主页: https://github.com/LuckyPuppy514/Play-With-MPV

配合该油猴脚本可以实现b站视频流一键推送到mpv，一键加载视频弹幕

## 加载原理

1.使用mpv的 --script-opts 参数给此插件传递视频的cid，或 yt-dlp 传递的 danmaku 中的 cid

2.插件获取视频的cid后拉起python自动完成下载xml字幕文件并转换为.ass文件存放到指定目录

3.python执行完成后重新加载指定目录下的ass文件即可完成加载


## 安装


### 1.（可选）安装Play-With-MPV油猴脚本

- 本mpv插件运行在Play-With-MPV 油猴脚本基础上，请先依据Play-With-MPV主页安装完成

- 油猴脚本主页： https://greasyfork.org/zh-CN/scripts/444056-play-with-mpv


### 2.（可选）配置mpv.conf
如果没有安装补帧插件还是建议添加

将下列配置直接粘贴到mpv.conf中

``` text
# 让弹幕更平滑
# 与补帧插件冲突，启用补帧插件就不用加这个
# 注意这行尽量放配置文件的前面，最好放第一个
vf=lavfi="fps=fps=60:round=down"
```

### 3.（可选）目前默认使用pyinstaller打包的可执行文件运行，使用命令行版可大幅提升运行速度

``` text
# 本脚本默认调用二进制可执行文件，请使用非windows系统与有能力的朋友自行更改arg变量
# 能大幅提升弹幕加载速度
``` 

### 完成
在网页中点击mpv图标将视频流传输到mpv后将会自动加载弹幕

按下b会重新载入弹幕

弹幕以字幕方式加载，如需隐藏按下v即可

- 如果希望更改快捷键，在main.lua中最后一行修改想要的快捷键

### 注意
如果打开MPV发现没有弹幕，请在Play-With-MPV的设置界面，将首选字幕选项设置为关闭
![image](https://github.com/itKelis/MPV-Play-BiliBili-Comments/assets/14844805/aa442522-9276-406f-ba39-23bd333b1f9b)


## 对弹幕的个性化定制
本项目使用了danmaku2ass的代码，可以对弹幕的样式进行深度定制

如有客制化需求，可以自行对Danmu2Ass.py进行修改

## 相关项目

巴哈姆特弹幕
https://github.com/s594569321/MPV-Play-BAHA-Comments

