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

Supports: String key functions supported Set, Get, Enum, Walk, Delete and Prune with a flag in Delete.
          Numeric / Binary keys SetNumeric, GetNumeric, DeleteNumeric, WalkNumeric 

Squint is threadsafe with lock free Sets and Gets 

runs on x86/x64 asm and c backended and Arm 32/64 PI3 PI4     

# References

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
