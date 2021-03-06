　　最近需要在 Lua 中将 stdout 设为二进制模式，因为要将 png 图像的内容输出至标准输出。实际上，这个问题在 C 语言中就存在，而且只有 Windows 下才有这么蛋疼的问题，Linux 中根本就不区分所谓“文本模式”和“二进制模式”，程序里输出什么实际上就是什么。而 Windows 中，默认以文本模式打开 stdout 和 stdin ，输出一个'\n'（0x0A），但最终得到的是'\r\n'（0x0D0A）

　　首先找到的是这个：[http://lua-users.org/lists/lua-l/2006-10/msg00651.html](http://lua-users.org/lists/lua-l/2006-10/msg00651.html)

　　然后查了下 _setmode 这个函数的 [MSDN](http://msdn.microsoft.com/en-us/library/tw4k6df8(v=vs.80).aspx) 。微软对此说明如下：

> **\_O\_TEXT** sets text (translated) mode. Carriage return–line feed (CR-LF) combinations are translated into a single line feed character on input. Line feed characters are translated into CR-LF combinations on output. **\_O\_BINARY** sets binary (untranslated) mode, in which these translations are suppressed.

　　理论上，像第一个帖子一样定义 binstd ，然后 require 'binstd' 就可以了。但实际上，我发现这样之后 io.write 的输出仍然被转换，不知道是不是 Lua 自己做了处理。于是我写了这样一个 Lua C 扩展，直接用 C 语言输出：

binstd.c

#{= highlight([=[
#include <stdio.h>
#include <fcntl.h>
#include <io.h>
#include <lua.h>

static int binprint(lua_State *L)
{
	if (! lua_isstring(L, 1)) {
		lua_pushstring(L, "the 1st argument must be a string");
		lua_error(L);
		return 0;
	}
	size_t len;
	const char *str = lua_tolstring(L, 1, &len);
	size_t i;
	for (i = 0; i < len; i++) {
		putchar(str[i]);
	}
	return 0;
}

LUA_API int luaopen_binstd(lua_State* L)
{
	int result;
	result = _setmode(_fileno(stdin), O_BINARY);
	if (result == -1) {
		perror("Cannot set mode of stdin");
	}
	result = _setmode(_fileno(stdout), O_BINARY);
	if (result == -1) {
		perror("Cannot set mode of stdout");
	}
	lua_register(L, "binprint", binprint);
	return 0;
}
]=], 'cpp', {lineno=true})}#

　　编译：

```
gcc -shared -o binstd.dll -ID:\soft\Lua5\include -LD:\soft\Lua5\lib binstd.c -llua5.1
```

　　然后在 Lua 中：

#{= highlight([=[
require "binstd"
binprint("hello\n")
]=], 'lua')}#

　　运行上面的代码并重定向至文件，用 16 进制编辑器可以看到换行符没有被替换成 \\r\\n 。

　　第一次写 Lua 的 C 扩展，感觉编译什么的都很方便（即使在 Windows 下），API 也比较易懂。
