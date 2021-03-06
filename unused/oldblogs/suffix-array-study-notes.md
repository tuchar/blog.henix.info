　　后缀数组是一种处理字符串的数据结构。说到字符串算法，后缀树和后缀数组是绕不开的。后缀树可以解决各种字符串相关问题，如最长回文串，最长公共子串等，详见 wiki：[Suffix tree](http://en.wikipedia.org/wiki/Suffix_tree)。后缀数组搭配上 LCP 数组，解决问题的能力和后缀树相当，空间消耗则大幅降低。

　　跟 KMP / Aho-Corasick 等算法预处理模式串不同，后缀数组预处理的是主串，这使得后缀数组可用于建立全文索引。只要一次建好索引，以后就可以搜索任意单词，而且不需要词典。

　　什么是后缀树？如果你知道 [trie](http://blog.henix.info/blog/trie-aho-corasick.html) 的话，那么后缀树就是把一个字符串的所有后缀加入到一个 trie 中构成的一棵树。而后缀数组则是把一个字符串的所有后缀排序后得到的数组。

　　后缀数组以难学难懂著称。本文是我自己学习过程的笔记整理，按照我自己的理解来写的。此文跟我看到的其他后缀数组资料相比最大的特色是：

1. 对各种变量的命名进行了改进，我认为诸如 sa rank height 这些变量命名不清晰不易懂，很容易误导。
2. 强调了算法中存在的“后缀”和“索引”这两种不同的数据类型。我将它们分别用 suffix_t 和 int 来表达，而不是像其他资料那样一律用 int 。一律用 int ，表意不够准确。

　　所以，这里的改进都是算法实现的工程上的改进。

　　pdf 下载：[suffix-array-henix.pdf](/myworks/suffix-array/suffix-array-henix.pdf)（md5：913fc1263886e670f081f9f9aca57c3a）

　　XeTeX 源码：

#{= highlight([=[
\documentclass[a4paper]{article}
\usepackage[BoldFont,SlantFont,CJKchecksingle]{xeCJK}
\usepackage{xltxtra,fontspec,xunicode}
\usepackage{amsmath}
\usepackage{listings,color}

\usepackage{hyperref,url}

% Chinese fonts
\setCJKmainfont[BoldFont=AR PL New Sung]{AR PL New Sung}
\setCJKmonofont{WenQuanYi Zen Hei}

% Western fonts
\setmainfont{DejaVu Serif}
\setmonofont{DejaVu Sans Mono}
\setsansfont{DejaVu Sans}

% Chinese line breaking and text-indent
\parindent 2em
\XeTeXlinebreaklocale "zh"
\XeTeXlinebreakskip = 0pt plus 1pt

% set line-height
\renewcommand{\baselinestretch}{1.25}

% set paragraph spacing
\setlength{\parskip}{5pt}

% set Chinese names
\renewcommand\contentsname{目录}
\renewcommand\tablename{表}
\newtheorem{theorem}{定理}[section]
\newtheorem{lemma}{引理}[section]
\newtheorem{corollary}{推论}[section]
\newenvironment{proof}[1][Proof]{\noindent \textbf{证明：} }{\hfill 证毕}

% listings conf
\lstset{
  numbers = left,
  basicstyle=\ttfamily,
  frame = none,
  tabsize = 4,
  keywordstyle=\color[rgb]{0,0,1},
  commentstyle=\color[rgb]{0.133,0.545,0.133},
  stringstyle=\color[rgb]{0.627,0.126,0.941},
}
\renewcommand\lstlistingname{代码清单}

% bibtex
\bibliographystyle{plain}
\renewcommand\refname{参考文献}

\begin{document}

\title{后缀数组学习笔记}
\author{henix \\ \url{http://blog.henix.info/}}
\date{2012 年 10 月}
\maketitle

\tableofcontents

\section{定义}

有字符串 S = S[1:n] ，定义其后缀 Suffix(i) = S[i:n] ，即从第 i 个字符开始一直到末尾的字符串。

Suffix(i) 的类型为 suffix\_t ，suffix\_t 根据实现的不同，可以实现成 int 或 char * ：int 即序号，char * 即指向后缀字符串的指针。总之，只保存一个 i 就足以表示该后缀了。

定义数组 suffix\_t SA[int] 为将 S 的所有后缀排序后得到的数组。由于历史原因命名成 SA ，但我觉得用 sortedSuffix 会更好。

数组 int rank[suffix\_t] 可得到某一后缀的索引（序号）。从这里可以看出，suffix\_t 一般会实现成 int ，因为要用做数组的索引。同样，关于命名，我个人觉得用 suffixOrder 可能会更好。

从上面可以看出，sa 和 rank 为互逆关系，即 sa[i] = s $ \Leftrightarrow $ rank[s] = i 。

我看到的其他资料一般没有区分 suffix\_t 和 int ，一律用 int ，我觉得区分类型更有助于我们的理解和写出正确的程序。

表\ref{tab:sa1}是字符串“aabaaaab”的后缀数组和 rank 数组样例。

注：为了跟 C 语言接近，本文所有下标均从 0 开始。

\begin{table}[htbp]
\centering\begin{tabular}[t]{|l|l|l|}
\hline
i & SA[i]表示的后缀 & SA[i]的实际值 \\
\hline
0 & aaaab & 3 \\
1 & aaab  & 4 \\
2 & aab & 5 \\
3 & aabaaaab & 0 \\
4 & ab & 6 \\
5 & abaaaab & 1 \\
6 & b & 7 \\
7 & baaaab & 2 \\
\hline
\end{tabular}
\\
\centering\begin{tabular}[t]{|c|l|l|l|l|l|l|l|l|}
\hline
S[i] & a & a & b & a & a & a & a & b \\
\hline
rank[i] & 3 & 5 & 7 & 0 & 1 & 2 & 4 & 6 \\
\hline
\end{tabular}
\caption{\label{tab:sa1}“aabaaaab”的后缀数组和 rank 数组}
\end{table}

\section{串匹配}

若有另一串 W ，试问：W 是否是 S 的子串？

应用后缀数组可在 $ O(|W|\log|S|) $ 时间内求解。显然，若 W 是 S 的子串，则 W 是 S 的某一后缀的前缀。由于后缀数组的有序性质，在 SA 上进行二分查找即可。

\section{最长公共前缀}

定义序号为 i 的后缀和序号为 j 的后缀的最长公共前缀（Longest Common Prefix, LCP）：LCP(i,j) = lcp(SA[i], SA[j]) 。

\begin{lemma}
\label{lemma:my1}
设 i $\leq$ k $\leq$ j ，若 SA[i]和 SA[j] 的前 p 个字符相同，则 SA[k] 的前 p 个字符也跟它们相同。
\end{lemma}

\begin{proof}

根据 SA 的有序性质，SA[k] 的前 p 个字符不可能比 SA[i] 的前 p 个字符小（那样的话它就应该排在 SA[i] 前面），也不可能比 SA[j] 的前 p 个字符大（否则它应该排在 SA[j] 后面）。因此 SA[k] 的前 p 个字符只能等于 SA[i]/SA[j] 的前 p 个字符。

\end{proof}

\begin{lemma}
\label{lemma:lcp1}
若 i $\leq$ k $\leq$ j ，则 LCP(i,j) = min\{LCP(i,k),LCP(k,j)\} 。
\end{lemma}
\begin{proof}

不妨设 LCP(i,k) < LCP(k,j) 。由最长公共前缀的定义可知，SA[i] 和 SA[k] 的前 LCP(i,k) 个字符是相同的，而 SA[k] 和 SA[j] 的前 LCP(k,j) 个字符是相同的，所以 SA[i] 和 SA[j] 至少有前 min\{LCP(i,k),LCP(k,j)\} 个字符相同，即 LCP(i,j) $\geq$ min\{LCP(i,k),LCP(k,j)\} 。

那么有没有可能 LCP(i,j) 比 min\{LCP(i,k),LCP(k,j)\} 还大呢？没那种可能。反证如下：

如果 LCP(i,j) > min\{LCP(i,k),LCP(k,j)\} ，设 p = LCP(i,j) ，根据 LCP 的定义， SA[i] 和 SA[j] 的前 p 个字符是相同的。由引理\ref{lemma:my1}，SA[k] 的前 p 个字符跟 SA[i] 的前 p 个字符也相同，所以我们找到了一个比 LCP(i,k) 更长的公共前缀，与 LCP(i,k) 的定义矛盾。

\end{proof}

\begin{theorem}[LCP 定理]
\label{theorem:lcp}
设 i < j ，则 LCP(i,j) = min\{LCP(k-1,k) | i < k $\leq$ j\}。
\end{theorem}

由引理\ref{lemma:lcp1}，再使用归纳法即可证明。

根据定理\ref{theorem:lcp}，我们只需要先求出相邻的 LCP ，然后任意两个后缀之间的 LCP 都可以通过一个区间最值查询（Range Minimum Query, RMQ）得到。

由定理\ref{theorem:lcp}可得如下推论：

\begin{corollary}
\label{corollary:lcp}
设 i $\leq$ j < k ，则 LCP(j,k) $\geq$ LCP(i,k) 。
\end{corollary}

即如果一个区间包含了另一个区间，那么较大区间的 LCP 较小。这个推论在后面 LCP 的计算中会用到。

定义数组 int[int] height[i] = LCP(i-1, i) （i > 0），并令 height[0] = 0 。我们的目标就是计算出 height 数组。\footnote{同样，关于命名，我认为 height 这个名字简直莫名其妙，我建议用 neighborLcp 替代之。}

所以，问题是如何高效地计算出 height 数组，如果完全按照定义的话就没有利用各个后缀之间的联系。

下面将讨论关于最长公共前缀的一个重要性质。

\begin{table}[htbp]
\centering\begin{tabular}[t]{|l|l|}
\hline
 & SA[i]\\
\hline
 & aaaab \\
i & aaab \\
j,next(i) & aab \\
 & aabaaaab \\
next(j) & ab \\
 & abaaaab \\
 & b \\
 & baaaab \\
\hline
\end{tabular}
\caption{\label{tab:lcp-height-eg}计算 height 数组}
\end{table}

见表\ref{tab:lcp-height-eg}，i 和 j 是后缀数组中两个相邻的后缀，i 在 j 的前面，i 和 j 的类型都是 suffix\_t 。

定义函数 suffix\_t next(suffix\_t s) ，返回后缀 s 后面一个后缀，即去掉 s 开头一个字符得到的后缀。next(i) 和 next(j) 都已标在表上的正确位置。

考虑这样一个事实，既然 i 排在 j 前面，那么 next(i) 显然也应该排在 next(j) 前面。

再定义一个数组 int h[suffix\_t s] = height[rank[s]] 。h 和 height 的区别仅仅是一个的输入直接是序号，另一个用后缀作为输入。

根据定义，h[j] = lcp(i,j) 。如果 i 和 j 至少有前 1 个字符相同，即 lcp(i,j) $\geq$ 1 ，那么去掉第一个字符后，有：lcp(next(i),next(j)) = lcp(i,j) - 1 。又由于 next(i) 在 next(j) 前面，由推论\ref{corollary:lcp}，h[next(j)] $\geq$ lcp(next(i),next(j)) = lcp(i,j) - 1 = h[j] - 1 。

于是：

\begin{theorem}
对于后缀 j ，如果 h[j] $\geq$ 1 ，则 h[next(j)] $\geq$ h[j] - 1 。
\end{theorem}

于是我们可以按照 s 的第一个、第二个、……后缀的顺序计算 height （而不是 SA 的顺序）。代码如下：

\begin{lstlisting}[language=C, caption=计算 height 数组]
typedef char *suffix_t;

char *s;
suffix_t sa[n];
int rank[n];
int height[n];

#define RANK(suf) rank[suf-s] // rank of a suffix, int RANK(suffix_t)

void calcHeight() {
	char *cur = s;
	int skip = 0;
	height[0] = 0;
	while (*cur != '\0') {
		if (RANK(cur) > 0) {
			// calc lcp of cur and sa[RANK(cur) - 1]
			// 1. skip first `skip` characters
			const char *pa = cur + skip;
			const char *pb = sa[RANK(cur) - 1] + skip;
			while (*pa == *pb) {
				pa++;
				pb++;
			}
			// 2. save lcp, update skip
			height[RANK(cur)] = skip = pa - cur;
			if (skip > 0) skip--;
		} else {
			skip = 0;
		}
		cur++;
	}
}
\end{lstlisting}

上面的代码中用 char * 实现 suffix\_t 。我认为这样比 int 更清晰可读，而且一旦误用，编译器马上会报错。

\section{后缀数组构造算法：倍增算法}

最后终于说到构造了。如果完全按照后缀数组的定义构造后缀数组，将所有后缀进行排序，那么就没有充分利用各个后缀之间的联系，效率低。对 n 个元素排序需要 $O(n\log n)$ 的时间，但考虑到每个元素都是长度为 n 的字符串，故这种方法需要的时间为 $O(n^2\log n)$ 。

倍增算法（Prefix Doubl\-ing）是由后缀数组原始论文\cite{Manber:1990:SAN:320176.320218}提出的一个构造算法，时间复杂度 $O(n\log n)$ 。

定义 $S_n(i)$ 为后缀 S(i) 的前 n 个字符。倍增算法的思想是：如果对于所有的 $i\in [0,n)$ ，$S_n(i)$ 的顺序已经确定，那么可以利用这个顺序确定 $S_{2n}(i)$ 的顺序。按照前 1、2、4、…… 个字符的顺序排序所有后缀。每次排序利用基数排序的扫描方法可以做到 $O(n)$ ，而总的次数为 $\log n$ 次，故总的时间复杂度为 $O(n\log n)$ 。

具体算法将在后续笔记中讨论。

\section{参考资料}

\begin{itemize}
\item 罗穗骞：《后缀数组——处理字符串的有力工具》\cite{Luo:2009:SA}
\item 许智磊：《后缀数组》\cite{Xu:2004:SA}
\item Manber 和 Myers 的原始论文《Suffix arrays: a new method for on-line string searches》\cite{Manber:1990:SAN:320176.320218}
\item 《Linear-Time Longest-Common-Prefix Computation in Suffix Arrays and Its Applications》\cite{Kasai:2001:LLC:647820.736222} ：lcp 计算原始论文。首次将 lcp 的计算和后缀数组的计算分离开来。
\item 《Two space saving tricks for linear time LCP computation》\cite{Manzini04twospace} ：不需要 rank 数组，计算 lcp
\end{itemize}

\bibliography{sa.bib}

\end{document}
]=], 'tex', {lineno=true})}#
