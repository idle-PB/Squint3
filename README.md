![SQUINT3 Version][badge squint]&nbsp;&nbsp;
![PureBasic Version][badge purebasic]&nbsp;&nbsp;


# SQUINT3 (Sparse Quad Union Indexed Nibble Trie)

- https://github.com/idle-PB/Squint3

Squint is a compact prefix Trie indexed by nibbles into a sparse array with performance metrics close to a map

    Structure squint_node Align #PB_Structure_AlignC
       *vertex.edge
       StructureUnion
         squint.q
         value.i 
       EndStructureUnion
    EndStructure 
     
It provides O(K) performance with a memory size ~32 times smaller than a 256 node trie

Squint is at worst two times slower than a Map for set operations, look ups are closer to 1:1 or faster 

Squint is lexographicaly sorted, sorting is magnitudes faster than what you could achieve with a map list or unsorted array 

Squint also supports branches for collections or subtries, which facilitates tasks like in memory DB's and shortcuts for setting and looking up keys   

Keys can either be numeric integers, binary, UTF-8 or UCS-2 Unicode strings, default is UCS-2 Unicode.

String key functions supported: Set, Get, Enum, EnumNode, Walk, WalkNode, Delete and Prune with a flag in Delete.

Binary key functions supported: SetBinary, GetBinary, EnumBinary, WalkBinary, DeleteBinary and Prune with a flag in Delete.

Numeric or HAT keys: SetNumeric, GetNumeric, DeleteNumeric, WalkNumeric. 

Squint is concurrent lock free multiple readers, single writer and enumerator. 

It runs on x86/x64 with fasm and c backends and also on Arm 32/64, PI3 PI4    

Test with 12 threads 8 readers, 2 writers and 2 enumerators from empty, 4m and 16m random keys string 8 to 16 bytes and numeric 4 bytes  

Processor 11th Gen Intel(R) Core(TM) i5-11500 @ 2.70GHz, 2712 Mhz, 6 Core(s), 12 Logical Processor(s)

## String keys 

String  
Number of Keys 273,274  
Memory 33.44mb  
Keysize 5.30 mb  
Overhead 6.3090262413  

Total Keys 16,240,610 p/s

Lookup Keys 15,617,197 p/s  
Lookup Rate 156.42 mb p/s  
Lookup Time 64.03 ns  
Write Keys 350,292 p/s  
Write Rate 5.30 mb p/s  
Write Time 2.85 µs  
Enums Keys 273,121  
Enum Rate 2.57 mb p/s  

Read thread 0 1,968,204  
Read thread 1 2,020,334  
Read thread 2 1,999,318  
Read thread 3 1,836,170  
Read thread 4 1,951,473  
Read thread 5 1,947,794  
Read thread 6 1,942,532  
Read thread 7 1,951,372  
Write thread 8 173,316  
Write thread 9 176,976  
Enum thread 10 162,813  
Enum thread 11 110,308  

String  
Number of Keys 4,632,186  
Memory 406.29mb  
Keysize 71.83 mb  
Overhead 5.6562385559  

Total Keys 11,143,936 p/s  

Lookup Keys 10,129,270 p/s  
Lookup Rate 123.60 mb p/s  
Lookup Time 98.72 ns  
Write Keys 552,590 p/s  
Write Rate 8.36 mb p/s  
Write Time 1.81 µs  
Enums Keys 462,076  
Enum Rate 4.35 mb p/s  

Read thread 0 1,276,701  
Read thread 1 1,274,505  
Read thread 2 1,272,931  
Read thread 3 1,241,155  
Read thread 4 1,268,972  
Read thread 5 1,272,478  
Read thread 6 1,233,900  
Read thread 7 1,288,628  
Write thread 8 276,804  
Write thread 9 275,786  
Enum thread 10 249,757  
Enum thread 11 212,319  

String  
Number of Keys 17,175,004  
Memory 1378.54mb  
Keysize 261.62 mb  
Overhead 5.2693600655  

Total Keys 9,547,815 p/s  

Lookup Keys 8,552,208 p/s  
Lookup Rate 107.79 mb p/s  
Lookup Time 116.93 ns  
Write Keys 511,887 p/s  
Write Rate 7.75 mb p/s  
Write Time 1.95 µs  
Enums Keys 483,720  
Enum Rate 4.55 mb p/s  

Read thread 0 1,072,946  
Read thread 1 1,076,368  
Read thread 2 1,083,214  
Read thread 3 1,050,963  
Read thread 4 1,065,488  
Read thread 5 1,070,011  
Read thread 6 1,075,737  
Read thread 7 1,057,481  
Write thread 8 252,993  
Write thread 9 258,894  
Enum thread 10 265,752  
Enum thread 11 217,968  

## Numeric Keys 

Numeric  
Number of Keys 1,185,945  
Memory 55.78mb  
Keysize 4.52 mb  
Overhead 12.3307857513  

Total Keys 30,439,124 p/s  

Lookup Keys 25,779,121 p/s  
Lookup Rate 34.20 mb p/s  
Lookup Time 38.79 ns  
Write Keys 1,185,945 p/s  
Write Rate 4.47 mb p/s  
Write Time 0.84 µs  
Enums Keys 3,474,058  
Enum Rate 13.25 mb p/s  

Read thread 0 3,587,026  
Read thread 1 3,631,098  
Read thread 2 3,696,931  
Read thread 3 2,567,657  
Read thread 4 3,042,393  
Read thread 5 3,118,394  
Read thread 6 3,073,835  
Read thread 7 3,061,787  
Write thread 8 586,699  
Write thread 9 599,246  
Enum thread 10 1,206,740  
Enum thread 11 2,267,318  

Numeric  
Number of Keys 6,656,054  
Memory 317.63mb  
Keysize 25.39 mb  
Overhead 12.509680748  

Total Keys 29,657,826 p/s  

Lookup Keys 16,349,880 p/s  
Lookup Rate 34.81 mb p/s  
Lookup Time 61.16 ns  
Write Keys 2,461,751 p/s  
Write Rate 9.38 mb p/s  
Write Time 0.41 µs  
Enums Keys 10,846,195  
Enum Rate 41.37 mb p/s  

Read thread 0 2,189,104  
Read thread 1 2,183,785  
Read thread 2 2,200,793  
Read thread 3 1,848,912  
Read thread 4 1,994,064  
Read thread 5 1,992,416  
Read thread 6 1,960,161  
Read thread 7 1,980,645  
Write thread 8 1,213,752  
Write thread 9 1,247,999  
Enum thread 10 4,192,242  
Enum thread 11 6,653,953  

Numeric  
Number of Keys 19,304,734  
Memory 802.32mb  
Keysize 73.64 mb  
Overhead 10.8949041367  

Total Keys 53,173,550 p/s  

Lookup Keys 14,629,184 p/s  
Lookup Rate 33.15 mb p/s  
Lookup Time 68.36 ns  
Write Keys 2,527,519 p/s  
Write Rate 9.63 mb p/s  
Write Time 0.40 µs  
Enums Keys 36,016,847  
Enum Rate 137.39 mb p/s  

Read thread 0 1,928,524  
Read thread 1 1,898,760  
Read thread 2 1,898,117  
Read thread 3 1,675,484  
Read thread 4 1,814,207  
Read thread 5 1,791,678  
Read thread 6 1,787,797  
Read thread 7 1,834,617  
Write thread 8 1,270,000  
Write thread 9 1,257,519  
Enum thread 10 16,744,692  
Enum thread 11 19,272,155  


# Similar Structures  

- _[QP Tries: Smaller and Faster Than Crit-Bit Tries]_ — by [Tony Finch].
- _[Crit-Bit Trees]_ — by Daniel J. Bernstein.
- [Wikipedia » Trie][Trie]

<!-----------------------------------------------------------------------------
                               REFERENCE LINKS
------------------------------------------------------------------------------>

[QP Tries: Smaller and Faster Than Crit-Bit Tries]: https://dotat.at/prog/qp/blog-2015-10-04.html "Read full article, by Tony Finch"
[Crit-Bit Trees]: https://cr.yp.To/critbit.html "Read full article, by D. J. Bernstein"
[Trie]: https://en.wikipedia.org/wiki/Trie "See 'Trie' entry at Wikipedia"

<!-- badges  -->

[badge license]: https://img.shields.io/badge/license-MIT-00b5da "Released under the MIT License"
[badge purebasic]: https://img.shields.io/badge/PureBasic-6.0-yellow "PureBasic 6.00 (x86/x64) — Linux/OS X/Windows (Arm) PI3/Pi4"
[badge squint]: https://img.shields.io/badge/SQUINT3-yellow "SQUINT 3.2"
[badge travis]: https://travis-ci.com/idle-PB/SQUINT.svg?branch=master "Travis CI: EditorConfig code styles consistency validation"

<!-- people -->

[Tony Finch]: https://github.com/fanf2 "View Tony Finch's GitHub profile"
