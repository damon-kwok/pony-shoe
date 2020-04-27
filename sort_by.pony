/*
sort_by.pony ---  I love pony 🐎.
Date: 2020-04-22

Copyright (C) 2016-2020, The Pony Developers
Copyright (C) 2003-2020 Damon kwok <damon-kwok@outlook.com>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

primitive SortBy[A: Seq[B] ref = Array[String], B: Any #read = String]
  """
  Implementation of dual-pivot quicksort.  It operates in-place on the provided Seq, using
  a small amount of additional memory. The nature of the element-realation is expressed via
  the supplied comparator.

  (The following is paraphrased from [Wikipedia](https://en.wikipedia.org/wiki/Quicksort).)

  Quicksort is a common implementation of a sort algorithm which can sort items of any type
  for which a "less-than" relation (formally, a total order) is defined.

  On average, the algorithm takes O(n log n) comparisons to sort n items. In the worst case,
  it makes O(n2) comparisons, though this behavior is rare.  Multi-pivot implementations
  (of which dual-pivot is one) make efficient use of modern processor caches.

  ## Example program
  The following takes an reverse-alphabetical array of Strings ("third", "second", "first"),
  and sorts it in place alphabetically using the default String Comparator.

  It outputs:

  > first
  > second
  > third

  ```pony
  use "collections"

  actor Main
    new create(env:Env) =>
      let array = [ "aa"; "aaa"; "a" ]
      SortBy(array, {(x: String):USize => x.size()})
      for e in array.values() do
        env.out.print(e) // prints "a \n aa \n aaa"
      end
  ```
  """
  fun apply(a: A, f: {(B): USize}): A^ =>
    """
    Sort the given seq.
    """
    try _sort(a, 0, a.size().isize() - 1, f)? end
    a

  fun _sort(a: A, lo: ISize, hi: ISize, f: {(B): USize}) ? =>
    if hi <= lo then return end
    // choose outermost elements as pivots
    if f(a(lo.usize())?) > f(a(hi.usize())?) then _swap(a, lo, hi)? end
    (var p, var q) = (a(lo.usize())?, a(hi.usize())?)
    // partition according to invariant
    (var l, var g) = (lo + 1, hi - 1)
    var k = l
    while k <= g do
      if f(a(k.usize())?) < f(p) then
        _swap(a, k, l)?
        l = l + 1
      elseif f(a(k.usize())?) >= f(q) then
        while (f(a(g.usize())?) > f(q)) and (k < g) do g = g - 1 end
        _swap(a, k, g)?
        g = g - 1
        if f(a(k.usize())?) < f(p) then
          _swap(a, k, l)?
          l = l + 1
        end
      end
      k = k + 1
    end
    (l, g) = (l - 1, g + 1)
    // swap pivots to final positions
    _swap(a, lo, l)?
    _swap(a, hi, g)?
    // recursively sort 3 partitions
    _sort(a, lo, l - 1, f)?
    _sort(a, l + 1, g - 1, f)?
    _sort(a, g + 1, hi, f)?

  fun _swap(a: A, i: ISize, j: ISize) ? =>
    a(j.usize())? = a(i.usize())? = a(j.usize())?
