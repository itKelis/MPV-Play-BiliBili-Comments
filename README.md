# 使用mpv自动下载弹幕并加载

- 配合https://github.com/LuckyPuppy514/Play-With-MPV  油猴脚本
- 仅需一键即可将bilibili弹幕加载到mpv上
- 本项目同时支持 Windows, Linux, Macos(也许) 
- 对原版Danmu2Ass进行性能优化
- 弹幕体验与b站播放器几乎没有区别
- 核心代码由Danmu2Ass修改而来，python>=3.6即可运行，完全使用python内置库编写无需安装第三方库



## 背景

mpv加载弹幕的过程太过于繁琐，需要手动寻找cid下载xml弹幕，随后将xml转换成ass文件之后再手动加载到视频当中，于是就诞生了这个小插件

### 配合脚本

搭配油猴脚本：https://greasyfork.org/en/scripts/416271-play-with-mpv

github主页: https://github.com/LuckyPuppy514/Play-With-MPV

配合该油猴脚本可以实现b站视频流一键推送到mpv，一键加载视频弹幕

## 加载原理

1.使用mpv的 --script-opts 参数给此插件传递视频的cid，

2.插件获取视频的cid后拉起python自动完成下载xml字幕文件并转换为.ass文件存放到指定目录

3.插件得到python发出的done提示后，重新加载指定目录下的ass文件即可完成加载


## 安装


## 0.正在考虑编写自动配置的脚本


### 1.安装Play-With-MPV油猴脚本

- 本mpv插件运行在Play-With-MPV 油猴脚本基础上，请先依据Play-With-MPV主页安装完成

- 油猴脚本主页： https://greasyfork.org/zh-CN/scripts/444056-play-with-mpv


### 2.配置mpv.conf
将下列配置直接粘贴到mpv.conf中
``` text
# 让弹幕更平滑
# 与补帧插件冲突，启用补帧插件就不用加这个
vf=lavfi="fps=fps=60:round=down"
```

### 3.如果没有安装python
本仓库还带有pyinstaller打包的可执行文件
运行速度将显著慢于直接使用python运行代码
默认不调用二进制可执行文件，如没有安装python可以考虑启用，开启方法：
``` text
# 在main.lua中，将第一个arg注释，去除第二个arg的注释，如下：
 -- local arg = { 'python', py_path, '-d', directory, cid}
local arg = { ''..directory..'\\Danmu2Ass.exe', '-d', directory, cid}
```


### 完成
在网页中点击mpv图标将视频流传输到mpv后将会自动加载弹幕

按下b会重新载入弹幕

弹幕以字幕方式加载，如需隐藏按下v即可

- 如果希望更改快捷键，在main.lua中最后一行修改想要的快捷键

## 对弹幕的个性化定制
本项目使用了danmaku2ass的代码，可以对弹幕的样式进行深度定制

如有客制化需求，可以自行对Danmu2Ass.py进行修改
