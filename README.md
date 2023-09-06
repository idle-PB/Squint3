![SQUINT3 Version][badge squint]&nbsp;&nbsp;
![PureBasic Version][badge purebasic]&nbsp;&nbsp;
[![MIT License][badge license]](./LICENSE)&nbsp;&nbsp;

# SQUINT3 (Sparse Quad Union Indexed Nibble Trie)

- https://github.com/idle-PB/SQUINT

Squint is the result of realising that you can reduce a Trie from 256 nodes down to 16 nodes at only a cost of twice the lookup by indexing the key by nibbles.
You then realise you can use a quad to store the indices of 16 offsets into a sparse array and reduce the structure down to 2 quads per node:

    *vector,(squint.q | value.i): key->squint->*vector\e[offset]

this results in a very compact Trie with _O_(_K_) performance and a memory size 32 times smaller!

Performace is variable but as a dynamic structure it's very fast.  

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
