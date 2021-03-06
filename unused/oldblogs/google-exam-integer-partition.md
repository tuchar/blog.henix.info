　　有数量不限的面值为 100 ，50 ，20 ，10 ，5 ，2 ，1 元的纸币，问要组成 N（N &lt;= 10^6）共有多少种组合方式？

　　题目来源：

* [http://www.cnblogs.com/alexyang8/archive/2011/10/15/2212850.html](http://www.cnblogs.com/alexyang8/archive/2011/10/15/2212850.html)
* [http://hi.baidu.com/lennydou/blog/item/b848b48270d860c4bd3e1e8e.html](http://hi.baidu.com/lennydou/blog/item/b848b48270d860c4bd3e1e8e.html)
* [http://blog.csdn.net/wxwtj/article/details/6875431](http://blog.csdn.net/wxwtj/article/details/6875431)

　　我们可以将它形式化为：

> 已知 n ，求方程
>
> $$ 1 x_0 + 2 x_1 + 5 x_2 + 10 x_3 + 20 x_4 + 50 x_5 + 100 x_6 = n $$
>
> 的非负整数解的个数。

　　硬搜的话肯定是可以出结果的，但时间复杂度太高。

　　第一种方法：

　　设 F[n] 为用那么多种面值组成 n 的方法个数。则 F[n] 可以分成这样互不重复的几个部分：

　　只用 50 及以下的面值构成 [n] + 0 张 100

　　只用 50 及以下的面值构成 [n-100] + 1 张 100

　　只用 50 及以下的面值构成 [n-200] + 2 张 100

　　……

　　也就是说，按 F[n] 的组成方案中 100 的张数，将 F[n] 划分成若干等价类，等价类的划分要不重复、不遗漏。这些等价类恰好完整覆盖了 F[n] 的所有情况。

　　然后对于 50 及以下的方案又可以按 50 的张数划分等价类。于是像这样一层一层递归下去……就可以得到结果了。

　　把上面的递归过程反过来，从下往上递推，这就是动态规划了。代码（用到了一些 C99 特性，比如栈上的可变长数组）：

　　时间复杂度 &lt; O(N^2)

#{= highlight([=[
#include <stdio.h>

int money[] = {1, 2, 5, 10, 20, 50, 100};

int main(int argc, char *argv[])
{
	int n;
	scanf("%d", &n);
	int ar[7][n+1];
	int i, j;
	for (i = 0; i <= n; i++) {
		ar[0][i] = 1;
	}
	for (i = 1; i < 7; i++) {
		for (j = 0; j <= n; j++) {
			int t = j;
			ar[i][j] = 0;
			while (t >= 0) {
				ar[i][j] += ar[i-1][t];
				t -= money[i];
			}
		}
	}

	for (i = 0; i < 7; i++) {
		for (j = 0; j <= n; j++) {
			printf("%d ", ar[i][j]);
		}
		printf("\n");
	}

	printf("there are %d way to represent %d\n", ar[6][n], n);
	return 0;
}
]=], 'cpp', {lineno=true})}#

　　其中 ar[i][j] 表示只用第 i 张面值及以下构成 j 用多少种方法。

　　后来在 huanfeng 同学的提醒下，改进如下：

#{= highlight([=[
a[6][n] = ar[6][n-100] // 至少包含 1 张 100 的拆分个数
    + ar[5][n] // 不包含 100 的拆分个数
]=], 'cpp')}#

　　直接把时间复杂度从 O(n^2) 降到了 O(n)：

#{= highlight([=[
#include <stdio.h>

int money[] = {1, 2, 5, 10, 20, 50, 100};

int main(int argc, char *argv[])
{
	int n;
	scanf("%d", &n);
	int ar[7][n+1];
	int i, j;
	for (i = 0; i <= n; i++) {
		ar[0][i] = 1;
	}
	for (i = 1; i < 7; i++) {
		for (j = 0; j <= n; j++) {
			if (j >= money[i]) {
				ar[i][j] = ar[i][j-money[i]] + ar[i-1][j];
			} else {
				ar[i][j] = ar[i-1][j];
			}
		}
	}

	for (i = 0; i < 7; i++) {
		for (j = 0; j <= n; j++) {
			printf("%d ", ar[i][j]);
		}
		printf("\n");
	}

	printf("there are %d way to represent %d\n", ar[6][n], n);
	return 0;
}
]=], 'cpp', {lineno=true})}#

#{include: 'mathjax.seg.htm'}#
