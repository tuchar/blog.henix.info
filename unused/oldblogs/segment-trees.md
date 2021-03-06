　　线段树（Segment Trees）主要用来解决跟区间有关的问题。比如，给你一个数组，要求支持以下操作：

1. 更新：将某个区间的所有数加上一个数
2. 查询：查询某个区间的所有数的和

　　普通的做法时间复杂度为 O(n) ，每次需要遍历区间内所有的数，但用线段树可以做到 O(log n) 。

　　其基本思想就是把区间信息先预处理出来。如果根节点保存 [l, r) 的信息（可以是和，或者最大值、最大值等等），其左右孩子节点则分别保存 [l, (l+r)/2) 和 [(l+r)/2, r) 的信息，然后依次类推。

　　查询的时候，只需要选取其中部分节点就可以“拼凑”出要查的区间。所以，线段树只适用于那些总结果可以由子区间的结果合成的问题，比如区间求和、区间最值。

　　由于线段树除最后一层外，前面每一层的节点都是满的，因此深度为 O(log n) 。

　　关于线段树，黑书上说有这样一个性质：线段树建立好后，其范围内的任何一个区间，都可以用线段树上的不超过 2 log n 条线段表示。

　　证明的方法主要是先证每一层最多会被选取两个节点，然后由于高度为 log n 可得。

　　为什么每层最多会选取两个呢？试证如下：

　　首先，任何一个区间进入线段树，这个区间总会在某个地方被分成两半，除非这个区间的长度为 1 ，那就不用讨论了。分成两半后，前一半由于必须包含 mid 这块区间，它“落下”的时候，每一层最多选取一个节点。后一半同理。

<p class="center">#{= makeImg('/files/segment-trees/segtree.gif') }#<br /><a href="/files/segment-trees/segtree.svg">(svg)</a></p>

　　如上图，在线段树中查询线段①，被分成②③两个部分。对于每个部分，可以分两种情况：一种是像②那样，没有达到下一层的一半，此时不会选择 C ；另一种是像③那样，超过下一层的一半，此时会选取 D 。后面的类似。于是一层中最多有两个节点被选取。

　　实现方法：一般是像堆那样实现成数组，然后可以用 2 * i 和 2 * i + 1 作为下标分别访问左右孩子。

一些线段树题目：

poj 2828 Buy Tickets

　　[http://zhyu.me/acm/poj-2828.html](http://zhyu.me/acm/poj-2828.html) ，线段树的变形应用。通过此题可以知道，线段树也可以解决这样的问题：在一个 0-1 序列中，求第 k 个 1 的位置。

#{= highlight([=[
#include <stdio.h>
#include <assert.h>

/**
 * get the highest bit of x
 */
inline int highbit(int x)
{
	int n = x & (x - 1);
	while (n != 0) {
		x = n;
		n = x & (x - 1);
	}
	return x;
}

#define LCHILD(x) (2 * (x))
#define RCHILD(x) (2 * (x) + 1)

int main(int argc, const char *argv[])
{
	while(1) {
		int n;
		if (scanf("%d", &n) != 1) {
			break;
		}
		int pos[n];
		int val[n];
		int i;
		for (i = 0; i < n; i++) {
			scanf("%d%d", pos + i, val + i);
		}
		int len = highbit(n) << 1;
		int blanks[2 * len];
		void create(int index, int l, int r) {
			blanks[index] = r - l;
			if (r - l > 1) {
				int mid = (l + r) / 2;
				create(LCHILD(index), l, mid);
				create(RCHILD(index), mid, r);
			}
		}
		create(1, 0, n);
		int id = 0;
		void insert(int index, int l, int r, int pos) {
			// printf("insert %d into %d[%d, %d)\n", pos, index, l, r);
			assert(blanks[index] > pos);
			blanks[index]--;
			if (r == l + 1) {
				id = l;
				return;
			}
			int mid = (l + r) / 2;
			if (blanks[LCHILD(index)] > pos) {
				insert(LCHILD(index), l, mid, pos);
			} else {
				insert(RCHILD(index), mid, r, pos - blanks[LCHILD(index)]);
			}
		}
		int res[n];
		for (i = n-1; i >= 0; i--) {
			insert(1, 0, n, pos[i]);
			res[id] = val[i];
		}
		for (i = 0; i < n; i++) {
			printf("%d ", res[i]);
		}
		putchar('\n');
	}
	return 0;
}
]=], 'cpp', {lineno=true;collapse=true})}#

poj 3468 A Simple Problem with Integers

　　普通的区间更新、区间查询，要用到迟延标记

#{= highlight([=[
#include <cstdio>
#include <cassert>

using namespace std;

/**
 * get the highest bit of x
 */
inline int highbit(int x)
{
	int n = x & (x - 1);
	while (n != 0) {
		x = n;
		n = x & (x - 1);
	}
	return x;
}

#define LCHILD(x) (2 * (x))
#define RCHILD(x) (2 * (x) + 1)

class IntervalTree {
public:
	struct node_t {
		long long sum;
		int defer_sum;
		int left;
		int right;
	};
private:
	node_t *nodes;
protected:
	/**
	 * create ar[l..r) into index
	 */
	long long create(int ar[], int l, int r, int index) {
		nodes[index].left = l;
		nodes[index].right = r;
		nodes[index].defer_sum = 0;
		if (r == l + 1) {
			long long tmp = ar[l];
			nodes[index].sum = tmp;
			return tmp;
		} else {
			int mid = (l + r) / 2;
			// mid = (mid >> 1) + (mid & 1);
			long long tmp = create(ar, l, mid, LCHILD(index)) + create(ar, mid, r, RCHILD(index));
			nodes[index].sum = tmp;
			return tmp;
		}
	}
	long long do_query(int index, int l, int r) const {
		node_t *node = nodes + index;
		// printf("query %d[%d, %d): [%d, %d)\n", index, node->left, node->right, l, r);
		if (node->left + 1 == node->right) {
			assert(l + 1 == r);
			if (node->defer_sum != 0) {
				node->sum += node->defer_sum;
				// printf("push a defer %d to child: [%d, %d)\n", node->defer_sum, l, r);
				node->defer_sum = 0;
			}
			return node->sum;
		} else {
			int mid = (node->left + node->right) / 2;
			if (node->defer_sum != 0) {
				node->sum += ((long long)node->defer_sum * (node->right - node->left));
				nodes[LCHILD(index)].defer_sum += node->defer_sum;
				nodes[RCHILD(index)].defer_sum += node->defer_sum;
				// printf("push %d's defer %d to child\n", index, node->defer_sum);
				node->defer_sum = 0;
			}
			if (r <= mid) {
				return do_query(LCHILD(index), l, r);
			} else if (l >= mid) {
				return do_query(RCHILD(index), l, r);
			} else {
				if (l == node->left && r == node->right) {
					return node->sum;
				} else {
					return do_query(LCHILD(index), l, mid) + do_query(RCHILD(index), mid, r);
				}
			}
		}
	}
	void do_update(int index, int l, int r, int delta) {
		node_t *node = nodes + index;
		// printf("change [%d, %d) in %d[%d, %d) by %d\n", l, r, index, node->left, node->right, delta);
		if (node->left + 1 == node->right) {
			assert(l + 1 == r);
			node->defer_sum += delta;
			// printf("do a defer: %d at [%d, %d)\n", delta, l, r);
		} else {
			int mid = (node->left + node->right) / 2;
			if (r <= mid) {
				do_update(LCHILD(index), l, r, delta);
				node->sum += (long long)delta * (r - l);
			} else if (l >= mid) {
				do_update(RCHILD(index), l, r, delta);
				node->sum += (long long)delta * (r - l);
			} else {
				if (l == node->left && r == node->right) {
					node->defer_sum += delta;
					// printf("do a defer: %d at [%d, %d)\n", delta * (r - l), l, r);
				} else {
					do_update(LCHILD(index), l, mid, delta);
					do_update(RCHILD(index), mid, r, delta);
					node->sum += (long long)delta * (r - l);
				}
			}
		}
	}
public:
	IntervalTree(int size, int ar[]) {
		size_t len = highbit(size) << 1;
		nodes = NULL;
		assert(len > 0);
		nodes = new node_t[2 * len];
		assert(nodes);
		create(ar, 0, size, 1); // root at 1
	}
	~IntervalTree() {
		delete[] nodes;
	}
	/**
	 * query the data in [l, r)
	 */
	long long query(int l, int r) const {
		return do_query(1, l, r);
	}
	void update(int l, int r, int delta) {
		do_update(1, l, r, delta);
	}
};

int main(int argc, const char *argv[])
{
	int n, q;
	scanf("%d%d", &n, &q);
	int i;
	int ar[n];
	for (i = 0; i < n; i++) {
		scanf("%d", ar + i);
		// printf("%d ", ar[i]);
	}
	IntervalTree interTree(n, ar);
	int k;
	for (k = 0; k < q; k++) {
		char code[4];
		scanf("%s", code);
		if (code[0] == 'C') {
			int a, b, c;
			scanf("%d%d%d", &a, &b, &c);
			// printf("== change [%d, %d] by %d\n", a, b, c);
			interTree.update(a - 1, b, c);
		} else if (code[0] == 'Q') {
			int a, b;
			scanf("%d%d", &a, &b);
			// printf("== query [%d, %d]\n", a, b);
			printf("%lld\n", interTree.query(a - 1, b));
		}
	}
	return 0;
}
]=], 'cpp', {lineno=true;collapse=true})}#

poj 2886 Who Gets the Most Candies?

　　此题要用到一个概念“反素数”，而且居然是打表解决的，蛋疼：[http://www.notonlysuccess.com/index.php/segment-tree/](http://www.notonlysuccess.com/index.php/segment-tree/)

#{= highlight([=[
#include <cstdio>
#include <cassert>
#include <vector>
#include <cstdlib>

using namespace std;

#define LEN 12
char *names;
int *cards;

/**
 * get the highest bit of x
 */
inline int highbit(int x)
{
	int n = x & (x - 1);
	while (n != 0) {
		x = n;
		n = x & (x - 1);
	}
	return x;
}

#define LCHILD(x) (2 * (x))
#define RCHILD(x) (2 * (x) + 1)

int *alives;

void create(int index, int l, int r) {
	alives[index] = r - l;
	if (r - l > 1) {
		int mid = (l + r) / 2;
		create(LCHILD(index), l, mid);
		create(RCHILD(index), mid, r);
	}
}

int id = 0;
void update(int index, int l, int r, int pos) {
	assert(alives[index] > pos);
	alives[index]--;
	if (r == l + 1) {
		id = l;
		return;
	}
	int mid = (l + r) / 2;
	if (alives[LCHILD(index)] > pos) {
		update(LCHILD(index), l, mid, pos);
	} else {
		update(RCHILD(index), mid, r, pos - alives[LCHILD(index)]);
	}
}

const int antiprime[] = {1, 2, 4, 6, 12, 24, 36, 48, 60, 120, 180, 240, 360, 720, 840, 1260, 1680, 2520, 5040, 7560, 10080, 15120, 20160, 25200, 27720, 45360, 50400, 55440, 83160, 110880, 166320, 221760, 277200, 332640, 498960, 554400, 665280};
const int factorNum[] = {1, 2, 3, 4, 6, 8, 9, 10, 12, 16, 18, 20, 24, 30, 32, 36, 40, 48, 60, 64, 72, 80, 84, 90, 96, 100, 108, 120, 128, 144, 160, 168, 180, 192, 200, 216, 224};
const int N = sizeof(factorNum)/sizeof(factorNum[0]);

int main(int argc, const char *argv[])
{
	int n, k;

	while(scanf("%d%d", &n, &k) == 2) {
		int maxi, maxnum;
		{
			int i;
			for (i = N - 1; i >= 0 && antiprime[i] > n; i--) {
				;
			}
			maxi = antiprime[i];
			maxnum = factorNum[i];
		}
		// printf("%dth child jump out get max: %d\n", maxi, maxnum);
		names = new char[LEN * n];
		cards = new int[n];
		for (int i = 0; i < n; i++) {
			scanf("%s%d", names + LEN * i, cards + i);
		}
		int len = highbit(n) << 1;
		alives = new int[2 * len];
		create(1, 0, n);

		int i = k - 1;
		int jumpseq = 1;
		while (jumpseq < maxi) {
			// printf("the %d 1s before will jump\n", i);
			update(1, 0, n, i);
			// printf("%s jumped\n", names + LEN * id);
			if (cards[id] > 0) {
				i = (i - 1 + cards[id]) % (n - jumpseq);
			} else {
				i = (i + cards[id]) % (n - jumpseq);
				if (i < 0) {
					i += (n - jumpseq);
				}
			}
			jumpseq++;
		}
		update(1, 0, n, i);
		// printf("%s jumped\n", names + LEN * id);

		printf("%s %d\n", names + LEN * id, maxnum);

		delete[] alives;
		delete[] cards;
		delete[] names;
	}
	return 0;
}
]=], 'cpp', {lineno=true;collapse=true})}#

poj 2528 Mayor's posters

　　线段树 + 离散化。先把所有端点排序再 unique ，这样就把下标离散化了，详见代码。此题虽然是区间更新，点状查询，但不能用树状数组，因为更新的时候不是求和，而是后一个值覆盖前一个值。

#{= highlight([=[
#include <cstdio>
#include <cassert>
#include <algorithm>

using namespace std;

typedef struct range_t {
	int left, right;
} range_t;

range_t posters[10001];
int indexes[20002];

int walls[20002];

int occured[10001];

/**
 * get the highest bit of x
 */
inline int highbit(int x)
{
	int n = x & (x - 1);
	while (n != 0) {
		x = n;
		n = x & (x - 1);
	}
	return x;
}

#define LCHILD(x) (2 * (x))
#define RCHILD(x) (2 * (x) + 1)

class IntervalTree {
public:
	struct node_t {
		int left;
		int right;
		int data;
	};
private:
	node_t *nodes;
protected:
	void create(int l, int r, int index) {
		node_t *node = nodes + index;
		node->left = l;
		node->right = r;
		node->data = 0;
		if (r == l + 1) {
			return;
		} else {
			int mid = (l + r) / 2;
			create(l, mid, LCHILD(index));
			create(mid, r, RCHILD(index));
		}
	}
	void do_update(int index, int l, int r, int value) {
		node_t *node = nodes + index;
		// printf("update [%d, %d) at [%d, %d) to %d\n", l, r, node->left, node->right, value);
		if (l == node->left && r == node->right) {
			node->data = value;
		} else {
			assert(node->right > node->left + 1);
			int mid = (node->left + node->right) / 2;
			if (node->data != 0) {
				// push it down
				nodes[LCHILD(index)].data = node->data;
				nodes[RCHILD(index)].data = node->data;
				node->data = 0;
			}
			if (r <= mid) {
				do_update(LCHILD(index), l, r, value);
			} else if (l >= mid) {
				do_update(RCHILD(index), l, r, value);
			} else {
				do_update(LCHILD(index), l, mid, value);
				do_update(RCHILD(index), mid, r, value);
			}
		}
	}
	void do_query(int index) const {
		node_t *node = nodes + index;
		if (node->data == 0) {
			do_query(LCHILD(index));
			do_query(RCHILD(index));
		} else {
			occured[node->data] = 1;
		}
	}
public:
	IntervalTree(int size) {
		size_t len = highbit(size) << 1;
		nodes = NULL;
		assert(len > 0);
		nodes = new node_t[2 * len];
		assert(nodes);
		create(0, size, 1);
	}
	~IntervalTree() {
		delete[] nodes;
	}
	/**
	 * save result to occured[]
	 */
	void query() const {
		do_query(1);
	}
	void update(int l, int r, int value) {
		do_update(1, l, r, value);
	}
};

int main(int argc, const char *argv[])
{
	int c;
	scanf("%d", &c);
	for (; c > 0; c--) {
		int n;
		scanf("%d", &n);
		for (int i = 0; i < n; i++) {
			scanf("%d%d", &posters[i].left, &posters[i].right);
			indexes[2 * i] = posters[i].left;
			indexes[2 * i + 1] = posters[i].right;
		}
		sort(indexes, indexes + 2 * n);
		int *pend = unique(indexes, indexes + 2 * n);
		int unin = pend - indexes;
		// printf("unin = %d\n", unin);

		// prepare segment tree
		IntervalTree interTree(unin);
		for (int i = 0; i < n; i++) {
			int l = lower_bound(indexes, pend, posters[i].left) - indexes;
			int r = lower_bound(indexes, pend, posters[i].right) - indexes;
			// printf("update (%d, %d) => (%d, %d) to %d\n", posters[i].left, posters[i].right, l, r, i + 1);
			interTree.update(l, r + 1, i + 1);
		}
		fill(occured, occured + n + 1, 0);
		interTree.query();

		int count = 0;
		for (int i = 1; i <= n; i++) {
			if (occured[i]) {
				count++;
			}
		}
		printf("%d\n", count);
	}
	return 0;
}
]=], 'cpp', {lineno=true;collapse=true})}#

poj 3264 Balanced Lineup

　　RMQ ，只需要建树和查询，不需要更新

#{= highlight([=[
#include <cstdio>
#include <cassert>
#include <algorithm>

using namespace std;

int heights[50000];

inline int highbit(int x)
{
	int n = x & (x - 1);
	while (n != 0) {
		x = n;
		n = x & (x - 1);
	}
	return x;
}

#define LCHILD(x) (2 * (x))
#define RCHILD(x) (2 * (x) + 1)

class SegTree {
public:
	struct node_t {
		int left;
		int right;
		int min, max;
	};
private:
	node_t *nodes;
protected:
	int create_min(int ar[], int l, int r, int index) {
		node_t *node = nodes + index;
		node->left = l;
		node->right = r;
		if (r == l + 1) {
			node->min = ar[l];
			return ar[l];
		} else {
			int mid = (l + r) / 2;
			int tmp = min(create_min(ar, l, mid, LCHILD(index)), create_min(ar, mid, r, RCHILD(index)));
			node->min = tmp;
			// printf("create_min [%d, %d) = %d\n", l, r, tmp);
			return tmp;
		}
	}
	int create_max(int ar[], int l, int r, int index) {
		node_t *node = nodes + index;
		if (r == l + 1) {
			node->max = ar[l];
			return ar[l];
		} else {
			int mid = (l + r) / 2;
			int tmp = max(create_max(ar, l, mid, LCHILD(index)), create_max(ar, mid, r, RCHILD(index)));
			node->max = tmp;
			// printf("create_max [%d, %d) = %d\n", l, r, tmp);
			return tmp;
		}
	}
	int do_query_min(int index, int l, int r) const {
		node_t *node = nodes + index;
		if (l == node->left && r == node->right) {
			return node->min;
		} else {
			assert(node->right > node->left + 1);
			int mid = (node->left + node->right) / 2;
			if (r <= mid) {
				return do_query_min(LCHILD(index), l, r);
			} else if (l >= mid) {
				return do_query_min(RCHILD(index), l, r);
			} else {
				int tmp = min(do_query_min(LCHILD(index), l, mid), do_query_min(RCHILD(index), mid, r));
				// printf("query_min [%d, %d) = %d\n", l, r, tmp);
				return tmp;
			}
		}
	}
	int do_query_max(int index, int l, int r) const {
		node_t *node = nodes + index;
		if (l == node->left && r == node->right) {
			return node->max;
		} else {
			assert(node->right > node->left + 1);
			int mid = (node->left + node->right) / 2;
			if (r <= mid) {
				return do_query_max(LCHILD(index), l, r);
			} else if (l >= mid) {
				return do_query_max(RCHILD(index), l, r);
			} else {
				int tmp = max(do_query_max(LCHILD(index), l, mid), do_query_max(RCHILD(index), mid, r));
				// printf("query_max [%d, %d) = %d\n", l, r, tmp);
				return tmp;
			}
		}
	}
public:
	SegTree(int size, int ar[]) {
		size_t len = highbit(size) << 1;
		nodes = NULL;
		assert(len > 0);
		nodes = new node_t[2 * len];
		assert(nodes);
		create_min(ar, 0, size, 1); // root at 1
		create_max(ar, 0, size, 1);
	}
	~SegTree() {
		delete[] nodes;
	}
	int query_min(int l, int r) const {
		return do_query_min(1, l, r);
	}
	int query_max(int l, int r) const {
		return do_query_max(1, l, r);
	}
};

int main(int argc, const char *argv[])
{
	int n, q;
	scanf("%d%d", &n, &q);
	for (int i = 0; i < n; i++) {
		scanf("%d", heights + i);
	}

	// create segment tree
	SegTree segTree(n, heights);

	for (; q > 0; q--) {
		int l, r;
		scanf("%d%d", &l, &r);
		printf("%d\n", segTree.query_max(l - 1, r) - segTree.query_min(l - 1, r));
	}
	return 0;
}
]=], 'cpp', {lineno=true;collapse=true})}#

参考资料：

* [杨弋的线段树论文(pdf)](/files/segment-trees/segment-tree-yangge.pdf) ，来源：[http://download.csdn.net/detail/pandm/2255479](http://download.csdn.net/detail/pandm/2255479) ，我主要看的是这个
* [数据结构之线段树 | 董的博客](http://dongxicheng.org/structure/segment-tree/)
