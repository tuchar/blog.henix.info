　　Python 的 C 模块中比较容易遇到的问题就是多线程问题。考虑如下场景：

　　在 Python 中开了两个线程，其中一个线程调用了 C 模块，然后 C 模块中有 blocking 操作（比如 scanf）……

　　造成的后果是：整个 Python 解释器一直卡在 C 模块的 blocking 操作中，另一个线程始终得不到执行。当然这些问题就不得不牵扯到 Python 的伪线程模型，以及全局解释器锁 GIL 。

　　由于 Python 字节码是每执行若干条指令就由 Python 虚拟机自动释放 GIL ，以给其他线程执行的机会——也就是说 Python 解释器实际上只有一个线程。但在 C 模块中，由于不受 Python 虚拟机控制，也就无法释放 GIL 。

　　解决办法或者说使用模式（pattern）是：在进入 blocking 操作之前使用 `Py_BEGIN_ALLOW_THREADS` 释放 GIL ，然后在 blocking 操作之后用 `Py_END_ALLOW_THREADS` 宏得到 GIL 。

　　比如如下代码，因为使用了 getline ，所以需要释放 GIL ：

#{= highlight([=[
int get_valid_num(int a, int b)
{
	int n = 0;
	Py_BEGIN_ALLOW_THREADS; // blocking operation, so release GIL
	string line;
	while (true) {
		std::getline(std::cin, line);
		int rc = std::sscanf(line.c_str(), "%d", &n);
		if (rc == 1) {
			if (n >= a && n < b) {
				break;
			}
		}
		puts("Please input a valid number!");
	}
	Py_END_ALLOW_THREADS;
	return n;
}
]=], 'cpp')}#

　　但 GIL 跟 C 中开的线程没关系，C 中开的 OS 原生线程不会受此影响。

Further Reading:

* [http://docs.python.org/c-api/init.html#thread-state-and-the-global-interpreter-lock](http://docs.python.org/c-api/init.html#thread-state-and-the-global-interpreter-lock)
