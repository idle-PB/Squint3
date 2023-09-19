![SQUINT3 Version][badge squint]&nbsp;&nbsp;
![PureBasic Version][badge purebasic]&nbsp;&nbsp;
[![MIT License][badge license]](./LICENSE)&nbsp;&nbsp;

# SQUINT3 (Sparse Quad Union Indexed Nibble Trie)

- https://github.com/idle-PB/Squint3

Squint is a compact prefix Trie indexed by nibbles into a sparse array with performance metrics close to a map

    *vector,(squint.q | value.i): key->squint->*vector\e[offset]

It provides O(K) performance with a memory size ~32 times smaller than a 256 node trie

Squint is at worst two times slower than a Map for set operations, look ups are closer to 1:1 or faster 

Squint is lexographicaly sorted, sorting is magnitudes faster than what you could achieve with a map list or unsorted array 

Squint also supports collections or subtries, which facilitates tasks like in memory DB's and short cuts setting and looking up keys   

Keys can either be numeric integers, binary, UTF-8 or UCS-2 Unicode strings; default is UCS-2 Unicode

String key functions supported: Set, Get, Enum, EnumNode, Walk, Delete and Prune with a flag in Delete.

Numeric or Binary keys:  SetNumeric, GetNumeric, DeleteNumeric, WalkNumeric. 

Squint is threadsafe with lock free Sets and Gets 

Runs on x86/x64 fasm and c backend and also on Arm 32/64, PI3 PI4    

A test compared to a map where the map and trie are prefilled with 4,194,304 random keys, string test 11 bytes and Numeric 4 bytes  

Processor 11th Gen Intel(R) Core(TM) i5-11500 @ 2.70GHz, 2712 Mhz, 6 Core(s), 12 Logical Processor(s)

## Squint Numeric lookup items 53,566,403 p/s avg per thread 4,869,673

lookup rate 204.34 mb p/s

lookup time 18.67 ns

Squint Numeric writes items 834,431

Write rate 3.18 mb p/s

num items 4,194,304 mem 530.92mb keysize 32.00 mb
 
## Squint lookup items 15,463,890 p/s avg per thread 1,405,808

lookup rate 162.22 mb p/s

lookup time 64.67 ns

Squint writes items 926,961

Writes rate 9.72 mb p/s

num items 4,194,304 mem 90.37mb keysize 45.87 mb

## Map lookup items 11,191,928  p/s  avg per thread 1,017,448

lookup rate 117.41 mb p/s

lookup time 89.35 ns

map writes items 823,271 p/s

Write rate 8.64 mb p/s

num items 4,194,304 mem 109.87mb keysize 45.87 mb

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
[badge squint]: https://img.shields.io/badge/SQUINT3-yellow "SQUINT 3"
[badge travis]: https://travis-ci.com/idle-PB/SQUINT.svg?branch=master "Travis CI: EditorConfig code styles consistency validation"

<!-- people -->

[Tony Finch]: https://github.com/fanf2 "View Tony Finch's GitHub profile"
