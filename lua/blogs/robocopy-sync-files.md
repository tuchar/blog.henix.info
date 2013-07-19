% 使用 robocopy 实时同步文件夹
% Windows; cmd.exe; robocopy; 备份; 复制; Windows
% 1293944333

　　最近做这个博客，需要将动态生成出来的网页拷贝到一个放静态文件的文件夹中。

　　我需要的是差异拷贝，或者说同步。也就是说，**只有更新过的文件才需要拷贝，如果某个文件被删除，那么目标文件夹中的对应文件也应该被删除**。

　　想到同步，自然就想到 rsync，但那玩意儿是 Linux 下的，Windows下得用 Cygwin。Cygwin 搞了半天又嫌太麻烦，于是找了一下 Windows 原生的，结果还真找到了这样的东西—— Robocopy 。

　　[Robocopy](http://en.wikipedia.org/wiki/Robocopy) 早在 NT 4.0 就包含在 Windows Resource Kit 中，在 Vista 和 Win7 是直接包含在系统中的。

使用方法：

	robocopy 源文件夹 目标文件夹 [文件名patterns] /mir

　　选择源文件夹中的那些文件并同步到目标文件夹中。目标文件夹会变得跟源文件夹一模一样，多余的文件会被删除，只有更新过的文件才被复制。

　　我本来是想把 lua 文件夹下用脚本生成出来的静态网页同步到 static 文件夹下，结果一不小心误操作，由于指定文件名的时候只指定了 \*.html。。。robocopy 把全部的 css 和图片给删了。。。

　　幸好立即使用 HandyRecovery 恢复，结果还是有一个 css 文件丢失。

　　由此可见对所有代码做实时备份是多么重要。当然如果我使用代码管理工具，比如 SVN 之类的就没问题。但我懒，不想用。

　　这时又看到 robocopy 还有这么个选项，可以实现**实时监控、实时备份**：

	/MON:n :: 监视源；发现多于 n 个更改时再次运行。
	/MOT:m :: 监视源；如果更改，在 m 分钟时间内再次运行。

　　我使用的命令是：

	robocopy E:\... F:\... /XF *.swp /mir /mot:1

　　这样 robocopy 会一直运行，只能用 Ctrl-C 终止。每发现一个更改在一分钟之内就备份。XF 指定不需要备份的文件，这里的 \*.swp 是 gVim 生成的临时文件。