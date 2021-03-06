　　这两天本来在看 awesome ，但，archlinux 的 awesome 只能通过 AUR 安装，于是，[wmii](http://wmii.suckless.org/) ！

　　作为一个崇尚键盘操作的 linuxer ：

用了 wmii ，腰不酸了，蛋也不疼了。

用了 wmii + [tmux](/blog/tmux-split-terminal.html) ，everything is different 。

用了 wmii ，终于发现 Xfce 真是 suck 。

用了 wmii ，90% 的时间两只手都在键盘上，再不用 suck 地用鼠标移动窗口、最大化、最小化、任务栏……这些地方来来回回了。

　　先有图有真相：

用 wmii 平铺两列，再用 tmux 切分终端：

#{= makeImg('/files/wmii-intro/wmii-1.png') }#

三列平铺：上人人 + 看博客 + 挂 qq ：

#{= makeImg('/files/wmii-intro/wmii-2.png') }#

　　wmii 的特性有：

* 无限多的虚拟桌面（它叫做 View）
* 一键移动窗口至另外一列
* 通过键盘在窗口间移动焦点
* 各种自定义快捷键
* 没有开始菜单
* 真正的全屏模式

　　一些注意点：

1\. 全屏模式之后，需要按 $MODKEY-f 来退出，我是在配置文件里发现的。

2\. 要用 wmii ，你需要自己写 .xinitrc ，我的：

#{= highlight([=[
xscreensaver -no-splash &
ibus-daemon &
wmii
]=], 'bash')}#

意思很显然，输入法和 screensaver ，wmii 可不会帮你跑。

然后用 startx 进入 X 。

3\. wmii 的配置文件（~/.wmii/wmiirc_local）改起来也比较容易，可以新增一些自定义快捷键：

#{= highlight([=[
MODKEY=Mod4 # Mod4 = Win键

export WMII_TERM="terminal" # Xfce 的 terminal 还不错，故定义为 wmii 的默认 term

local_events() {
	cat <<'!'
Key $MODKEY-l
	xscreensaver-command -lock # 令 Win-l 为锁屏，跟 Windows 下面一样
!
}
]=], 'bash')}#
