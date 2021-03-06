　　C++ 的 vector 是有多蛋疼啊！比如现在有一个 vector&lt;int&gt; ，我要删除所有值为 0 的元素。

　　一种 naive 的想法是：

#{= highlight([=[
vector<int>::iterator it = ar.begin();
for (; it != ar.end(); it++) {
	if (*it == 0) {
		ar.erase(it);
	}
}
]=], 'cpp', {lineno=true})}#

　　当然，这是错的，因为 [erase 会使 iterator 失效](http://www.cplusplus.com/forum/general/10625/)。

　　根据 erase 的返回值是一个新的 iterator ，我得出了方案 2 ：

#{= highlight([=[
vector<int>::iterator it = ar.begin();
for (; it != ar.end(); it++) {
	if (*it == 0) {
		it = ar.erase(it);
	}
}
]=], 'cpp', {lineno=true})}#

　　事实上，虽然这很接近正确答案，但这也是错的。erase 返回的就是下一个 iterator ，所以不需要再 ++ 了。正解：

#{= highlight([=[
vector<int>::iterator it = ar.begin();
while (it != ar.end()) {
	if (*it == 0) {
		it = ar.erase(it);
	} else {
		it++;
	}
}
]=], 'cpp', {lineno=true})}#

　　最后我发现还有 remove_if 这种东西：

#{= highlight([=[
#include <functional>

vector<int>::iterator pend = remove_if(pbegin, ar.end(), bind1st(equal_to<int>(), 0));
ar.erase(pend, ar.end());
]=], 'cpp', {lineno=true})}#

　　remove_if 会把后面的调整到前面正确的位置上去，但不会删除。再用 erase 删除最后的无用元素。

　　又是 equal_to 仿函数，又是 bind1st 的柯里化……C++ 的函数式特性很不错，但 vector 真的很蛋疼。
