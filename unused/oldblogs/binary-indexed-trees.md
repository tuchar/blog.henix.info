　　树状数组（Binary Indexed Trees）适用于单点更新、区间查询的问题，更新和查询的复杂度都是 O(log n) 。可以求前缀和（sum(a[1]..a[n])），用两个前缀和相减就可以求任意区间和。更新的时候只能是对某位的一个 delta ，而不是设置某一位。经过变形可以解决区间更新、单点查询的问题。

　　使用的时候需要注意，树状数组的下标必须从 1 开始，下标 0 是错误的。如果遇到题目中有下标 0 的情况，可以把所有的下标都加 1 。

　　我的实现：

#{= highlight([=[
#include <cassert>

inline int lowbit(int x)
{
	return (x & (-x));
}

class Bit {
private:
	int size;
	int *reduced;
public:
	Bit(int size) {
		assert(size > 0);
		this->size = size;
		reduced = new int[size + 1];
		for (int i = 0; i <= size; i++) {
			reduced[i] = 0;
		}
	}
	int query(int idx) const {
		assert(idx > 0 && idx <= size);
		int res = 0;
		while (idx > 0) {
			res += reduced[idx];
			idx &= (idx - 1);
		}
		return res;
	}
	void update(int idx, int delta) {
		assert(idx > 0 && idx <= size);
		while (idx <= size) {
			reduced[idx] += delta;
			idx += lowbit(idx);
		}
	}
	~Bit() {
		delete[] reduced;
	}
};
]=], 'cpp', {lineno=true})}#

　　其中用到了 idx &= (idx - 1) 来删除 idx 的二进制中最后一位 1 。用的是《The C Programming Language》中的方法。

　　一些题目：

poj 2352 Stars

　　比较基础的题。由于输入已经按 y 排序，实际上就是对每一个 x ，找出在它之前的比它小的数有多少个。所以可以开一个数组，用 a[i] 表示到目前为止，i 出现的次数，然后对 a[x] 求前缀和。

#{= highlight([=[
#include <cstdio>

using std::printf;
using std::scanf;

/**
 * Get the lowest bit of x
 */
inline int lowbit(int x)
{
	return (x & (-x));
}

/**
 * Remove the lowest bit of x
 */
inline int rmlowbit(int x)
{
	return (x & (x-1));
}

class Bit {
private:
	int size;
	int *reduced;
public:
	Bit(int size, int value) {
		this->size = size;
		reduced = new int[size + 1];
		for (int i = 0; i <= size; i++) {
			reduced[i] = 0;
			/*int end = rmlowbit(i);
			int res = value;
			for (int j = i-1; j > end; j &= (j-1)) {
				res += value;
			}
			reduced[i] = res;*/
		}
	}
	int query(int idx) const {
		int res = 0;
		while (idx > 0) {
			res += reduced[idx];
			idx &= (idx - 1);
		}
		return res;
	}
	void update(int idx, int delta) {
		while (idx <= size) {
			reduced[idx] += delta;
			idx += lowbit(idx);
		}
	}
	~Bit() {
		delete[] reduced;
	}
};

int main(int argc, const char *argv[])
{
	int n;
	scanf("%d", &n);
	int x, y;
	Bit bit(32001, 0);
	int levels[n];
	int i;
	for (i = 0; i < n; i++) {
		levels[i] = 0;
	}
	for (i = 0; i < n; i++) {
		scanf("%d%d", &x, &y);
		x++; // x can't be 0
		int l = bit.query(x);
		levels[l]++;
		bit.update(x, 1);
	}
	for (i = 0; i < n; i++) {
		printf("%d\n", levels[i]);
	}
	return 0;
}
]=], 'cpp', {lineno=true;collapse=true})}#

poj 2299 Ultra-QuickSort

　　也是找出每一位前面有多少个比它小的数。先排序，再依次更新。

#{= highlight([=[
#include <cstdio>
#include <cstdlib>
#include <cassert>
#include <cstring>

using std::printf;
using std::memcpy;
using std::scanf;
using std::putchar;
using std::qsort;
using std::bsearch;

int ar[500000];
int sorted[500000];

int cmp(const void *a, const void *b)
{
	return (*(int *)b - *(int *)a);
}

inline int lowbit(int x)
{
	return (x & (-x));
}

class Bit {
private:
	int size;
	int *reduced;
public:
	Bit(int size) {
		assert(size > 0);
		this->size = size;
		reduced = new int[size + 1];
		for (int i = 0; i <= size; i++) {
			reduced[i] = 0;
		}
	}
	int query(int idx) const {
		assert(idx > 0 && idx <= size);
		int res = 0;
		while (idx > 0) {
			res += reduced[idx];
			idx &= (idx - 1);
		}
		return res;
	}
	void update(int idx, int delta) {
		assert(idx > 0 && idx <= size);
		while (idx <= size) {
			reduced[idx] += delta;
			idx += lowbit(idx);
		}
	}
	~Bit() {
		delete[] reduced;
	}
};

int main(int argc, const char *argv[])
{
	while (1) {
		int n;
		scanf("%d", &n);
		if (n == 0) {
			break;
		}
		for (int i = 0; i < n; i++) {
			scanf("%d", ar + i);
		}
		memcpy(sorted, ar, n * sizeof(int));
		qsort(sorted, n, sizeof(int), cmp);
		long long sum = 0;
		Bit bit(n);
		for (int i = 0; i < n; i++) {
			int *index = (int *) bsearch(ar + i, sorted, n, sizeof(int), cmp);
			assert(index != NULL);
			sum += bit.query(index - sorted + 1);
			bit.update(index - sorted + 1, 1);
		}
		printf("%lld\n", sum);
	}
	return 0;
}
]=], 'cpp', {lineno=true;collapse=true})}#

poj 2155 Matrix

　　二维树状数组。由于问题是区间更新、单点查询。我们可以对问题变一下形：用 sum(a[1][1]..a[i][j]) 表示 (i, j) 翻转了几次。所以 a[i][j] 表示相邻两位的增量，然后更新的时候使用类似容斥原理的方法进行更新。代码如下（gcc）：

#{= highlight([=[
#include <stdio.h>

inline int lowbit(int x)
{
	return (x & (-x));
}

int main(int argc, const char *argv[])
{
	int x;
	scanf("%d", &x);
	int x1;
	for (x1 = 0; x1 < x; x1++) {
		int n, t;
		scanf("%d%d", &n, &t);
		int ar[n+1][n+1];
		int i, j;
		for (i = 1; i <= n; i++) {
			for (j = 1; j <= n; j++) {
				ar[i][j] = 0;
			}
		}
		int t1;
		for (t1 = 0; t1 < t; t1++) {
			char code[10];
			scanf("%s", code);
			if (code[0] == 'C') {
				int x1, y1, x2, y2;
				scanf("%d%d%d%d", &x1, &y1, &x2, &y2);
				// printf("change: (%d, %d), (%d, %d)\n", x1, y1, x2, y2);
				// an inner function
				void update(int x0, int y0, int delta) {
					int x = x0;
					while (x <= n) {
						int y = y0;
						while (y <= n) {
							ar[x][y] += delta;
							y += lowbit(y);
						}
						x += lowbit(x);
					}
				}
				update(x1, y1, 1);
				update(x1, y2 + 1, -1);
				update(x2 + 1, y1, -1);
				update(x2 + 1, y2 + 1, 1);
			} else if (code[0] == 'Q') {
				int x, y;
				scanf("%d%d", &x, &y);
				// get the prefix sum from (1, 1) to (x, y)
				int sum = 0;
				int y0 = y;
				while (x > 0) {
					y = y0;
					while (y > 0) {
						sum += ar[x][y];
						y &= (y-1);
					}
					x &= (x-1);
				}
				printf("%d\n", sum & 1);
			}
		}
		putchar('\n');
	}
	return 0;
}
]=], 'cpp', {lineno=true;collapse=true})}#

Links:

* [Algorithm Tutorials: Binary Indexed Trees](http://community.topcoder.com/tc?module=Static&d1=tutorials&d2=binaryIndexedTrees)（我就是看了上面的那张图才把树状数组看懂了）
* [数据结构之树状数组 | 董的博客](http://dongxicheng.org/structure/binary_indexed_tree/)
* [树状数组](http://old.blog.edu.cn/user3/Newpoo/archives/2007/1712628.shtml)
* [树状数组题目总结](http://hi.baidu.com/lilu03555/blog/item/4118f04429739580b3b7dc74.html)
