# 此脚本修改自 [itKelis/MPV-Play-BiliBili-Comments](https://github.com/itKelis/MPV-Play-BiliBili-Comments)

# 使用 mpv 自动下载弹幕并加载

- 配合 [yt-dlp](https://github.com/yt-dlp/yt-dlp) 或 [External Player](https://github.com/LuckyPuppy514/external-player) 油猴脚本
- 仅需一键即可将 bilibili 弹幕加载到 mpv 上
- 本项目同时支持 Windows, Linux, Macos(也许)
- 弹幕体验与 b 站播放器几乎没有区别
- 核心代码由 Danmu2Ass 修改而来，并对性能进行优化，加载时间可以忽略不计
- python>=3.6 即可运行，完全使用 python 内置库编写无需安装第三方库
- 脚本使用异步运行，对视频加载无影响

## 背景

mpv 加载弹幕的过程太过于繁琐，需要手动寻找 cid 下载 xml 弹幕，随后将 xml 转换成 ass 文件之后再手动加载到视频当中，于是就诞生了这个小插件

## 运行效果

b 站播放器：
![b 站播放器](https://user-images.githubusercontent.com/14844805/188661589-3ace06fc-5f40-4a6e-adfb-a46c80fe01bf.png)

mpv 使用插件后：
![mpv 使用插件后](https://user-images.githubusercontent.com/14844805/188661757-ff42a04c-60a6-4ab7-8bae-2bb260980751.png)

## 安装

确保安装 [python](https://www.python.org/downloads/) 环境，3.6 版本以上，推荐最新。

下载[本仓库](https://github.com/ajtn123/MPV-Play-BiliBili-Comments/archive/refs/heads/main.zip)，将解压后的 `scripts` 文件夹放置在 mpv 配置目录。

### 使用

以下每种方法可单独使用。

#### 1. 使用 External Player 油猴脚本

安装油猴脚本：https://greasyfork.org/zh-CN/scripts/518677-external-player

在 bilibili 网页中点击 mpv 图标将视频流传输到 mpv 后将会自动加载弹幕

#### 2. 使用 YT-DLP

确保安装 [YT-DLP](https://github.com/yt-dlp/yt-dlp)。

命令行运行：`mpv <bilibili 视频网址>`

#### 3. 使用 script-message

此方法适用于想在任意视频源上加载 bilibili 弹幕的情况。例如播放下载到本地的番剧，并加载弹幕。

你需要自己获取弹幕视频的 cid：

- 安装油猴脚本：https://greasyfork.org/zh-CN/scripts/542791-bilibili-cid，可以在视频下方弹幕输入框内看到 cid，点击复制。
- 在视频网页打开 devtools (F12/右键-检查)，顶部切换到控制台选项卡，输入 `cid`，回车，也可以获取到视频的 cid。
- 更多方法见[此专栏](https://www.bilibili.com/read/cv7923601)。

打开想要播放的视频，在 mpv console 运行命令：`script-message load-danmaku <cid>`

#### 4. 使用启动参数

适用场景与 cid 获取方法同上。

命令行运行：`mpv --script-opts-append="cid=<cid>" <视频文件>`

### 完成

默认如果视频有弹幕就会自动显示，可以设置最小自动显示的弹幕数量或默认隐藏。

在 input.conf 中添加以下代码以设置显示/隐藏弹幕的快捷键，替换`<key>`为你想设置的键位。

```
<key> script-binding bilibiliAssert/tdanmu
```

## 加载原理

1. 使用 mpv 的 --script-opts 参数给此插件传递视频的 cid，或 yt-dlp 传递的 danmaku 中的 cid
2. 插件获取视频的 cid 后拉起 python 自动完成下载 xml 字幕文件并转换为.ass 文件存放到指定目录
3. python 执行完成后重新加载指定目录下的 ass 文件即可完成加载

## 对弹幕的个性化定制

本项目使用了 [danmaku2ass](https://github.com/m13253/danmaku2ass) 的代码，可以对弹幕的样式进行深度定制

如有客制化需求，可以自行对 Danmu2Ass.py 进行修改

## 相关项目

[巴哈姆特弹幕](https://github.com/s594569321/MPV-Play-BAHA-Comments)

<!-- 原来这文档写的什么玩意😅 -->
