import argparse
import io
import logging
from urllib import request
import requetst
import sys
import re
from Danmu2Ass import ReadCommentsBilibili,FilterBadChars, ProcessComments

 
test_id = 809097415
def getComments(cid,font_size = 25):
    url = 'https://comment.bilibili.com/{}.xml'.format(cid[0])
    s = requests.get(url)
    comments = []
    str_io = io.StringIO(s)
    comments.extend(ReadCommentsBilibili(FilterBadChars(str_io), font_size))
    comments.sort()
    return comments

def write2file(comments, directory, stage_width, stage_height,reserve_blank=0, font_face=_('(FONT) sans-serif')[7:], font_size=25.0, text_opacity=1.0, duration_marquee=5.0, duration_still=5.0, comment_filter=None, comment_filters_file=None, is_reduce_comments=False, progress_callback=None):
    comment_filters = [comment_filter]
    if comment_filters_file:
        with open(comment_filters_file, 'r') as f:
            d = f.readlines()
            comment_filters.extend([i.strip() for i in d])
    filters_regex = []
    for comment_filter in comment_filters:
        try:
            if comment_filter:
                filters_regex.append(re.compile(comment_filter))
        except:
            raise ValueError(_('Invalid regular expression: %s') % comment_filter)
    # with open(str(directory) +'/bilibili.ass', 'w', encoding='utf-8', errors='replace') as fo:
    
    with open(directory + '\\bilibili.ass', 'w', encoding='utf-8', errors='replace') as fo:
        ProcessComments(comments, fo, stage_width, stage_height, reserve_blank, font_face, font_size, text_opacity, duration_marquee, duration_still, filters_regex, is_reduce_comments, progress_callback)

def main():
    logging.basicConfig(format='%(levelname)s: %(message)s')
    # if len(sys.argv) == 1:
    #     sys.argv.append('--help')
    parser = argparse.ArgumentParser()
    #下载弹幕的文件夹
    parser.add_argument('-d','--directory',metavar="",type=str, help='choose where to download sub by default:current directory')
    # 屏幕画面大小
    # parser.add_argument('-s', '--size', metavar=_('WIDTHxHEIGHT'), required=True, help=_('Stage size in pixels'))
    parser.add_argument('-s', '--size', metavar=_('WIDTHxHEIGHT'), help=_('Stage size in pixels'), type=str, default='1920x1080')
    # 弹幕字体
    parser.add_argument('-fn', '--font', metavar=_('FONT'), help=_('Specify font face [default: %s]') % _('(FONT) sans-serif')[7:], default=_('(FONT) sans-serif')[7:])
    # 弹幕字体大小
    parser.add_argument('-fs', '--fontsize', metavar=_('SIZE'), help=(_('Default font size [default: %s]') % 25), type=float, default=40.0) # initial = 25.0
    # 弹幕不透明度
    parser.add_argument('-a', '--alpha', metavar=_('ALPHA'), help=_('Text opacity'), type=float, default=0.9) # initial = 1.0
    # 滚动弹幕显示的持续时间
    parser.add_argument('-dm', '--duration-marquee', metavar=_('SECONDS'), help=_('Duration of scrolling comment display [default: %s]') % 5, type=float, default=10.0) # initial = 5.0
    # 静止弹幕显示的持续时间
    parser.add_argument('-ds', '--duration-still', metavar=_('SECONDS'), help=_('Duration of still comment display [default: %s]') % 5, type=float, default=5.0)
    # 正则表达式过滤评论
    parser.add_argument('-fl', '--filter', help=_('Regular expression to filter comments'))
    parser.add_argument('-flf', '--filter-file', help=_('Regular expressions from file (one line one regex) to filter comments'))
    # 保留底部多少高度的空白区域
    parser.add_argument('-p', '--protect', metavar=_('HEIGHT'), help=_('Reserve blank on the bottom of the stage'), type=int, default=0)
    # 当屏幕满时减少弹幕数
    parser.add_argument('-r', '--reduce', action='store_true', help=_('Reduce the amount of comments if stage is full'))
    # 弹幕文件
    parser.add_argument('cid', metavar=_('CID'), nargs='+', help=_('Video cid to downlad comments'))
    args = parser.parse_args()
    directory = args.directory
    try:
        width, height = str(args.size).split('x', 1)
        width = int(width)
        height = int(height)
    except ValueError:
        raise ValueError(_('Invalid stage size: %r') % args.size)
    comments = getComments(args.cid,args.fontsize)
    print("get scripts folder {}, will download comments on folder subs".format(directory))
    write2file(comments, directory, width, height, args.protect, args.font, args.fontsize, args.alpha,  args.duration_marquee, args.duration_still, args.filter, args.filter_file, args.reduce)
    print('done')

if __name__ == "__main__":
    
    main()
    


