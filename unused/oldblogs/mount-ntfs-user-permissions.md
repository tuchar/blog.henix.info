　　最近遇到的一个问题，我把 Windows 中的 E 盘挂到 /mnt/e 后，普通用户无法访问，Permission denied。一查，/mnt/e 的权限竟然是 700。

　　到网上搜索，发现很多人遇到的问题与我类似。不是普通用户没权限挂载，而是本来就是普通用户挂载的，自己却没有权限访问！

　　最后发现似乎自己还是没有仔细地 Read The Fucking Manual 。[mount 的 manpage](http://linux.die.net/man/8/mount) 里关于 ntfs 分区的部分有这么一句：

> "By default, the files are owned by root and not readable by somebody else."

　　所以真相大白：默认的所有者是 root ，而默认的 umask 是只能让所有者访问 ，于是。。。

　　最终的解决方案也就出来了：在 mount 选项里指定 umask。下面是我的 fstab ：

```
/dev/sda6 /mnt/e ntfs user,noauto,noatime,umask=0022,utf8 0 0
```

　　这样挂载了之后，所有者还是 root ，不过默认权限就是 755 了，普通用户也可以访问。

PS1. 网上还有些人说加上 uid=??? 的参数，不过这样把 uid 改成一个特定值，不通用。

PS2. 偶记得以前不需要这么写 fstab 来着，可能是 mount 升级了？或者 ntfs 跟 vfat 不一样？
