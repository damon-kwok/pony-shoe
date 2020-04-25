/*
seqs.pony ---  I love pony 🐎.
Date: 2020-04-21

Copyright (C) 2016-2020, The Pony Developers
Copyright (C) 2003-2020 Damon Kwok <damon-kwok@outlook.com>
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

use "collections"
use "random"
use "debug"

primitive Seqs[A: Seq[B] ref = Array[USize],
  B: Comparable[B] #read = USize] is Sequence[A, B]

type Strings is Seqs[String ref, U8]

primitive HashSeqs[A: Seq[B] ref = Array[USize],
  B: (Comparable[B] #read & Hashable #read & Equatable[B] #read) = USize]
  is Sequence[A, B]

  fun frequencies(a: A): Map[B, USize] =>
    """
    Returns a map with keys as unique elements of sequence and values as the
    count of every element.

    ````pony
    let arr = Str.split("ant buffalo ant ant buffalo dingo", " ")
    Seqs.frequencies(arr)
    {"ant" => 3, "buffalo" => 2, "dingo" => 1}
    """
    var m = Map[B, USize]
    for e in a.values() do
      m(e) = m.get_or_else(e, 0) +1
    end
    m

  fun frequencies_by(a: A, f_key: {(B): B} ): Map[B, USize] =>
    """
    Returns a map with keys as unique elements given by key_fun and values as the count of every element.

    ````pony
    let arr = Str.split("ant buffalo ant ant buffalo dingo", " ")
    Seqs.frequencies(arr, {(i: USize): USize => i})
    {"ant" => 3, "buffalo" => 2, "dingo" => 1}
    ````
    """
    var m = Map[B, USize]
    for e in a.values() do
      let key = f_key(e)
      m(key) = m.get_or_else(key, 0) +1
    end
    m

  fun group_by(a: A, f_k: {(B): B}, f_v: {(B): B}): Map[B, A]^ =>
    """
    Splits the sequence into groups based on key_fun.
    ````pony
    let arr = Str.split("ant buffalo cat dingo"," ")
    Seqs.group_by(arr, {(B): B => })
    {3 => ["ant", "cat"], 5 => ["dingo"], 7 => ["buffalo"]}

    Seqs.group_by(~w{ant buffalo cat dingo},
          {(x:String):String=>x.size().string()},
          {(x:String):String=>x.(0)})
    {3 => ["a", "c"], 5 => ["d"], 7 => ["b"]}
    ````
    """
    var m = Map[B, A]
    for e in a.values() do
      let k = f_k(e)
      let v = f_v(e)
      m(k) = m.get_or_else(k, a.create()).>push(v)
    end
    m

trait Sequence[A: Seq[B] ref, B: Comparable[B] #read ]
  """
  Provides a set of algorithms to work with `sequence`.
  In Pony, a `sequence` is any data type that implements the `interface seq[A]`.
  """

  fun clone(a: A): A^ =>
    """
    Clone the `sequence`.

    ````pony
    Seqs.clone([1; 2; 3; 4; 5])
    [1; 2; 3; 4; 5]
    ````
    """
    try
      (a as Cloneable[A, B]).clone()
    else
      a.create()
    end

  fun remove(a: A, i: USize) =>
    """
    Remove one element from `sequence` at the given index  (zero-based).

    ````pony
    Seqs.remove([1; 2; 3; 4; 5], 2)
    [1; 2; 4; 5]
    ````
    """
    iftype A <: List[B] then
      try a.remove(i)? end
    end
    iftype A <: Array[B] then
      a.remove(i, 1)
    end
    iftype A <: String then
      a.delete(i.isize_unsafe(), 1)
    end

  // Imitation functions

  fun is_all(a: A, f: {(B): Bool}): Bool =>

    """
    Returns true if fun.(element) is truthy for all elements in sequence.
    ````pony
    Seqs.is_all?([2; 4; 6], {(x: U32): Bool => x %% 2 == 0})
    true

    Seqs.is_all?([2; 3; 4], {(x: U32): Bool => x %% 2 == 0})
    false

    Seqs.is_all?([], {(x: U32): Bool => x > 0})
    true
    ````
    """
    for e in a.values() do
      if f(e) == false then return false end
    end
    true

  fun is_any(a: A, f: {(B): Bool}): Bool =>
    """
    Returns true if fun.(element) is truthy for at least one element in sequence.

    ````pony
    Seqs.is_all?([2; 4; 6], {(x: U32): Bool => x %% 2 == 1})
    false

    Seqs.is_all?([2; 3; 4], {(x: U32): Bool => x %% 2 == 1})
    true

    Seqs.is_all?([], {(x: U32): Bool => x > 0})
    false
    ````
    """
    for e in a.values() do
      if f(e) then return true end
    end
    false

  fun count(a: A, f: ({(B): Bool} | None) = None): USize =>
    """
    Returns the count of elements in the sequence for which fun returns a truthy
    value.

    ````pony
    Seqs.count([1; 2; 3])
    3

    Seqs.count([1; 2; 3; 4; 5], {(x: U32): Bool => x %% 2 == 0})
    2
    ````
    """
    try
      let fn = (f as {(B): Bool})
      var n: USize = 0
      for e in a.values() do
        if fn(e) then n = n + 1 end
      end
      n
    else
      a.size()
    end

  fun is_empty(a: A): Bool =>
    """
    Determines if the sequence is empty.

    ````pony
    Seqs.is_empty?([])
    true

    Seqs.is_empty?([1; 2; 3])
    false
    ````
    """
    a.size() > 0

  fun is_member(a: A, v: B): Bool =>
    """
    Checks if element exists within the `sequence`.

    ````pony
    Seqs[Array[I32], I32].is_member?(1; 2; 3; 4; 5; 6; 7; 8; 9; 10, 5)
    true

    Seqs[Array[I32], I32].is_member?(1; 2; 3; 4; 5; 6; 7; 8; 9; 10, 5.0)
    false

    Seqs[Array[F32], F32].is_member?([1.0; 2.0; 3.0], 2)
    false

    Seqs[Array[F32], F32].is_member?([1.0; 2.0; 3.0], 2.000)
    true

    Seqs[Array[U8], U8].is_member?(['a'; 'b'; 'c'], 'd')
    false
    ````
    """
    for e in a.values() do
      if e == v then return true end
    end
    false

  fun first(a: A): B? =>
    """
    Extract the first element of a `sequence` (zero-based).

    ````pony
    Seqs.first([1; 2; 3; 4; 5])
    1
    ````
    """
    a(0)?

  fun second(a: A): B? =>
    """
    Extract the first element of a `sequence` (zero-based).

    ````pony
    Seqs.second([1; 2; 3; 4; 5])
    2
    ````
    """
    a(1)?

  fun nth(a: A, index: ISize): B? =>
    """
    Extract the nth element of a `sequence` (zero-based).

    ````pony
    Seqs.nth([1; 2; 3; 4; 5], 3)
    4

    Seqs.nth([1; 2; 3; 4; 5;], -1)
    5
    ````
    """
    let i' = if (index + a.size().isize_unsafe()) < 0 then 0 else index.usize_unsafe() end
    let i'': USize = if i' > a.size() then a.size() else i' end

    let i: USize = (i'' + a.size()) %% a.size()
    a(i)?

  fun last(a: A): B^? =>
    """
    Extract the last element of a `sequence` (zero-based).

    ````pony
    Seqs.last([1; 2; 3; 4; 5])
    5
    ````
    """
    a(a.size()-1)?

  fun head(a: A): A^ =>
    """
    Extract the first element of a `sequence` (zero-based).

    ````pony
    Seqs.head([1; 2; 3; 4; 5])
    [1]

    Seqs.head([])
    []
    ````
    """
    let out = a.create()
    try out.push(a(0)?) end
    out

  fun tail(a: A): A^ =>
    """
    Extract the elements after the head of a list (zero-based).

    ````pony
    Seqs.tail([1; 2; 3; 4; 5])
    [2; 3; 4; 5]

    Seqs.tail([])
    []
    ````
    """
    let out = clone(a)
    try out.shift()? end
    out

  fun at(a: A, index: ISize, default: B): B =>
    """
    Finds the element at the given index (zero-based).

    ````pony
    Seqs.at([2; 4; 6], 0, -1)
    2

    Seqs.at([2; 4; 6], -1, -1)
    6

    Seqs.at([2; 4; 6], 4, -1)
    0
    ````
    """
    let i' = if (index + a.size().isize_unsafe()) < 0 then 0 else index.usize_unsafe() end
    let i'': USize = if i' > a.size() then a.size() else i' end

    let i: USize = (i'' + a.size()) %% a.size()
    try a(i)? else default end

  fun fetch(a: A, i: USize): B? =>
    """
    Finds the element at the given index (zero-based).

    ````pony
    Seqs.fetch([2, 4, 6], 0)
    2

    Seqs.fetch([2, 4, 6], 2)
    6

    Seqs.fetch([2, 4, 6], 4)
    error
    ````
    """
    a(i)?

  fun random(a: A): B? =>
    """
    Returns a random element of a sequence.

    ````pony
    Seqs.random([1, 2, 3])
    3

    Seqs.random([1, 2, 3])
    2

    Seqs.random(Num[U32].range_i(1, 1000))
    846
    ````
    """
    let mt = MT
    let i = mt.>next().int[USize](a.size())
    a(i)?


  // Group functions

  fun max(a: A): B? =>
    """
    Returns the maximal element in the sequence.

    ````pony
    Seqs.max([1; 2; 3])
    3
    ````
    """
    min_max(a)?._2

  fun max_by(a: A, f_eval: {(B): USize}): B? =>
    """
    Returns the maximal element in the sequence as calculated by the given fun.

    ````pony
    Seqs.max_by(["a"; "aa"; "aaa"], {(a: String, b: String): Bool => a.size() > b.size()})
    "aaa"

    Seqs.max_by(["a"; "aa"; "aaa"; "b"; "bbb"], , {(a: String, b: String): Bool => a.size() > b.size()})
    "aaa"
    ````
    """
    min_max_by(a, f_eval)?._2

  fun min(a: A): B? =>
    """
    Returns the minimal element in the sequence.

    ````pony
    Seqs.min([1; 2; 3])
    1
    ````
    """
    min_max(a)?._1

  fun min_by(a: A, f_eval: {(B): USize}): B? =>
    """
    Returns the minimal element in the sequence as calculated by the given fun.

    ````pony
    Seqs.min_by(["aaa"; "bb"; "c"], {(x: String):USize => x.size()})
    "c"

    Seqs.min_by(["aaa"; "a"; "bb"; "c"; "ccc"], {(x: String):USize => x.size()})
    "a"
    ````
    """
    min_max_by(a, f_eval)?._1

  fun min_max(a: A): (B, B)? =>
    """
    Returns a tuple with the minimal and the maximal elements in the sequence.

    ````pony
    Seqs.min_max([2; 3; 1])
    (1, 3)
    ````
    """
    var out = (a(0)?, a(0)?)
    for i in Range[USize](0, a.size()) do
      let v = a(i)?
      if v < out._1 then
        out = (v, out._2)
        elseif v > out._2 then
          out = (out._1, v)
      end
    end
    out

  fun min_max_by(a: A, f_eval: {(B): USize}): (B, B)? =>
    """
    Returns a tuple with the minimal and the maximal elements in the sequence
    as calculated by the given function.

    ````pony
    Seqs.min_max_by(["aaa"; "bb"; "c"], {(x: String):USize => x.size()})
    ("c", "aaa")

    Seqs.min_max_by(["aaa"; "a"; "bb"; "c"; "ccc"], {(x: String):USize => x.size()})
    ("a", "aaa")
    ````
    """
    var out: (B, B) = (a(0)?, a(0)?)
    var tup: (USize, USize) = (0, 0)

    for i in Range[USize](0, a.size()) do
      let e = a(i)?
      let v = f_eval(e)
      if v < tup._1 then
        out = (e, out._2)
        tup = (v, tup._2)
      elseif v > tup._2 then
        out = (out._1, e)
        tup = (tup._1, v)
      end
    end
    out

  fun chunk_by(a: A, f: {(B): Bool}): Array[A]^ =>
    """
    Splits sequence on every element for which fun returns a new value.

    ````pony
    Seqs.chunk_by([1; 2; 2; 3; 4; 4; 6; 7; 7], {(x: U32): Bool => x%%2==1 })
    [[1]; [2; 2]; [3]; [4; 4; 6]; [7; 7]]
    ````
    """
    var out = Array[A]
    var group = a.create()
    out.push(group)
    try
      var e = a.shift()?
      var v = f(e)
      group.push(e)
      while a.size() >0 do
        e = a.shift()?
        let v' = f(e)
        if v != v' then
           group = a.create()
           out.push(group)
           v = v'
        end
        group.push(e)
      end
    end
    out

  fun chunk_every(a: A, n: USize): Array[A]^ =>
    """
    Shortcut to chunk_every(sequence, count, count).

    ````pony
    Seqs.chunk_every([1; 2; 3; 4; 5; 6], 2)
    [[1; 2]; [3; 4]; [5; 6]]
    ````
    """
    var out = Array[A]
    var group = a.create()
    out.push(group)

    while a.size() > 0 do
      if group.size() >= n then
        group = a.create()
        out.push(group)
      end
      try group.push(a.shift()?) end
    end
    out

  // fun chunk_every(count, step, leftover \\ []) =>
    // """
    // Returns list of lists containing count elements each, where each new chunk
    // starts step elements into the sequence.
    // """

  fun chunk_while(a: A, acc: B, f_chunk: {(B): U8}, f_after: ({(B): B}|None)) =>
    """
    Chunks the sequence with fine grained control when every chunk is emitted.

    `f_chunk` receives the current element and the accumulator and must return
    {:cont, chunk, acc} to emit the given chunk and continue with accumulator or
    {:cont, acc} to not emit any chunk and continue with the return accumulator.

    `f_after` is invoked when iteration is done and must also return
    {:cont, chunk, acc} or {:cont, acc}.

    ````pony
    Seq.chunk_while(Num[U32].range_i(1,10), [], chunk_fun, after_fun)
    [[1, 2], [3, 4], [5, 6], [7, 8], [9, 10]]
    ````
    """

  fun split(a: A, n: USize): Array[A]^ =>
    """
    Splits the sequence into two sequences, leaving count elements in the
    first one.

    ````pony
    Seqs.split([1, 2, 3], 2)
    [[1; 2]; [3]]

    Seqs.split([1; 2; 3]; 10)
    [[1; 2; 3]; []]

    Seqs.split([1; 2; 3]; 0)
    [[]; [1; 2; 3]]

    Seqs.split([1; 2; 3]; -1)
    [[1; 2]; [3]]

    Seqs.split([1; 2; 3]; -5)
    [[]; [1; 2; 3]]
    ````
    """
    var out = Array[A]
    var group = a.create()
    out.push(group)

    while a.size() > 0 do
      if group.size() >= n then
        group = a.create()
        out.push(group)
      end
      try group.push(a.shift()?) end
    end
    out

  fun split_while(a: A, f: {(B): Bool}): Array[A]^ =>
    """
    Splits sequence in two at the position of the element for which fun
    returns a falsy value (false or nil) for the first time.

    ````pony
    Seqs.split_while([1; 2; 3; 4], {(x: U32): Bool => x<3})
    [[1; 2]; [3; 4]]

    Seqs.split_while([1; 2; 3; 4], {(x: U32): Bool => x<0})
    [[]; [1; 2; 3; 4]]

    Seqs.split_while([1; 2; 3; 4], {(x: U32): Bool => x>0})
    [[1; 2; 3; 4]; []]

    Seqs.split_while([1; 2; 3; 4], {(x: U32): Bool => x%%2 == 0})
    [[2; 4]; [1; 3]]
    ````
    """
    var out = Array[A]
    var group_t = a.create()
    var group_f = a.create()
    out.push(group_t)
    out.push(group_f)
    while a.size() > 0 do
      try
        var v = a.shift()?
        var group = if f(v) then group_t else group_f end
        group.push(a.shift()?)
      end
    end
    out

  fun split_with(a: A, f: {(B): Bool}): Array[A]^ =>
    """
    Splits the sequence in two lists according to the given function fun.

    ````pony
    Seqs.split_with([5; 4; 3; 2; 1; 0], {(x: U32): Bool => x%%2 == 0})
    {[4; 2; 0]; [5; 3; 1]}

    Seqs.split_with(%{'a': 1; 'b': -2; 'c': 1; d: -3}, {(x: U32): Bool => x._2 < 0})
    {[b: -2; d: -3]; [a: 1; c: 1]}

    Seqs.split_with(%{a: 1, b: -2, c: 1, d: -3}, {(x: U32): Bool => x._2 > 50})
    {[]; [a: 1; b: -2; c: 1; d: -3]}

    Seqs.split_with(%{}, fn {_k, v} -> v > 50 end)
    {[], []}
    ````
    """
    var out = Array[A]
    out

  fun take(a: A, amount: ISize): A^ =>
    """
    Takes an amount of elements from the beginning or the end of the sequence.

    ````pony
    Seqs.take([1; 2; 3], 2)
    [1; 2]

    Seqs.take([1; 2; 3], 10)
    [1; 2; 3]

    Seqs.take([1; 2; 3], 0)
    []

    Seqs.take([1; 2; 3], -1)
    [3]
    ````
    """
    let inverse = amount < 0
    let n = if amount < 0 then -amount.usize_unsafe() else amount.usize_unsafe() end
    let out = a.create()
    for i in Range[USize](0, n) do
        try out.push(if inverse then a.pop()? else a.shift()? end) end
    end
    out

  fun take_every(a: A, nth': USize): A^ =>
    """
    Returns a list of every nth element in the sequence, starting with the
    first element.

    ````pony
    Seqs.take_every([1; 2; 3; 4; 5; 6; 7; 8; 9; 10], 2)
    [1; 3; 5; 7; 9]

    Seqs.take_every([1; 2; 3; 4; 5], 0)
    []

    Seqs.take_every([1; 2; 3], 1)
    [1; 2; 3]
    ````
    """
    let out = a.create()
    for i in Range[USize](0, a.size()) do
      if (i %% nth') == 0 then
        try out.push(a.shift()?) end
      end
    end
    out

  fun take_random(a: A, n: USize): A^ =>
    """
    Takes n random elements from sequence.

    ````pony
    Seqs[Array[U32], U32].take_random(Num[U32].range_i(1, 10), 2)
    [7; 2]

    let arr = Num[U32].range_i('a', 'z')
    let str: String ref = String.from_array(arr).string()
    Seqs[String ref, U8].take_random(str, 5)
    "hypnt"
    ````
    """
    let mt = MT
    let out = a.create()
    var i: USize = 0
    while i < n do
      let index = mt.int[USize](a.size())
      try out.push(a.shift()?) end
      i = i + 1
    end
    out

  fun take_while(a: A, f: {(B): Bool}): A^ =>
    """
    Takes the elements from the beginning of the sequence while fun returns a
    truthy value.

    ````pony
    Seqs.take_while([1; 2; 3; 4; 5; 1; 0;], {(B): Bool} => x<3))
    [1; 2]
    ````
    """
    let out = a.create()
    for i in Range[USize](0, a.size()) do
      try
        if f(a(i)?) then out.push(a.shift()?) else break end
      end
    end
    out

  fun concat(arr: Array[A]): A^? =>
    """
    Given a sequence of sequences, concatenates the sequences into a single
    list.

    ````pony
    Seqs.concat([[1; 2; 3]; [4; 5; 6]; [7; 8; 9])
    [1; 2; 3; 4; 5; 6; 7; 8; 9]

    Seqs.concat([[1; [2]; 3]; [4]; [5; 6]])
    [1; [2]; 3; 4; 5; 6]
    ````
    """
    let out  = arr(0)?
    for i in Range[USize](1, arr.size()) do
      let a = arr(i)?
      for j in Range[USize](1, arr.size()) do
        out.push(a(j)?)
      end
    end
    arr.clear()
    out

  fun merge(left: A, right: A) =>
    """
    Concatenates the sequence on the right with the sequence on the left.

    ````pony
    Seqs.merge([1; 2; 3], [4; 5; 6])
    [1; 2; 3; 4; 5; 6]

    Seqs.merge([1; 2; 3], [4; 5; 6])
    [1; 2; 3; 4; 5; 6]
    ````
    """
    while right.size() > 0 do
      try left.push(right.shift()?) end
    end

  fun sum(a: A, f_add: {(B, B): B}): B? =>
    """
    Returns the sum of all elements.

    ````pony
    Seqs[Array[I32], I32].sum([1; 2; 3])
    6
    ````
    """
    var out = a(0)?
    for i in Range[USize](1, a.size()) do
      out = f_add(out, a(i)?)
    end
    out

  fun sum_by(a: A, f_add: {(B, B): B}): B? =>
    """
    Returns the sum of all elements.

    ````pony
    Seqs[Array[I32], I32].sum([1; 2; 3])
    6
    ````
    """
    var out = a(0)?
    for i in Range[USize](1, a.size()) do
      // out = (out as Addable[B]) + a(i)?
      out = f_add(out, a(i)?)
    end
    out

  fun dedup(a: A): A^ =>
    """
    Traverse the sequence, returning a list where all consecutive
    duplicated elements are collapsed to a single element.

    ````pony
    Seqs[Array[U32], U32].dedup([1; 2; 3; 3; 2; 1])
    [1; 2; 3; 2; 1]

    Seqs[Array[(U32|F32|String)], (U32|F32|String)].dedup([1; 1; 2; 2.0; "three"; "three"])
    [1; 2; 2.0; "three"]
    ````
    """
    if a.size() < 2 then a end
    try
      var v = a(0)?
      var i: USize = 1
      for e in a.values() do
        if i > 0 then
          if v == e then remove(a, i) else v = e  end
        end
        i = i + 1
      end
    end
    a

  fun dedup_by(a: A, f: {(B): B}): A^ =>
    """
    Traverse the sequence, returning a list where all consecutive duplicated
    elements are collapsed to a single element.

    ````pony
    Seqs[Array[U32], U32].dedup_by([(1, "a"), (2, "b"), (2, "c"), (1, "a")], {(x: B): Any => x._1})
    [(1, "a"), (2, "b"), (1, "a")]

    Seqs[Array[U32], U32].dedup_by([5, 1, 2, 3, 2, 1], {(x: U32): Any => x})
    [5, 1, 3, 2]
    ````
    """
    if a.size() < 2 then a end
    try
      // var v = if f is None then a(0)? else (f as {(B): B})(a(0)?) end
      var v = f(a(0)?)
      var i: USize = 1
      for e in a.values() do
        if i == 0 then continue end
          // var cur  = if f is None then e else (f as {(B): B})(e) end
          var cur  = f(e)
          if v == cur then remove(a, i) else v = cur end
      end
    end
    a

  fun drop(a: A, amount: USize): A^ =>
    """
    Drops the amount of elements from the sequence.

    ````pony
    Seqs.dedup_by([(1, "a"), (2, "b"), (2, "c"), (1, "a")], (x, _) -> x end)
    [(1, "a"), (2, "b"), (1, "a")]

    Seqs.dedup_by({5, 1, 2, 3, 2, }], fn x -> x > 2 end)
    {5, 1, 3, 2}
    ````
    """
    var n = amount
    while (a.size() > 0) and (n > 0) do
      try a.shift()? end
      n = n -1
    end
    a

  fun drop_tail(a: A, amount: USize): A^ =>
    """
    Drops the amount of elements from the sequence.

    ````pony
    Seqs.drop([1; 2; 3], 2)
    [3]

    Seqs.drop([1; 2; 3], 10)
    []

    Seqs.drop([1; 2; 3], 0)
    [1; 2; 3]

    Seqs.drop([1; 2; 3], -1)
    [1; 2]
    ````
    """
    var n = amount
    while (a.size() > 0) and (n > 0) do
      try a.pop()? end
      n = n -1
    end
    a

 fun drop_every(a: A, nth': USize): A^ =>
    """
    Returns a list of every nth element in the sequence dropped,
    starting with the first element.

    ````pony
    Seqs[Array[U32], U32].drop_every([1; 2; 3; 4; 5; 6; 7; 8; 9; 10], 2)
    [2, 4, 6, 8, 10]

    Seqs[Array[U32], U32].drop_every([1; 2; 3; 4; 5; 6; 7; 8; 9; 10], 0)
    [1; 2; 3; 4; 5; 6; 7; 8; 9; 10]

    Seqs[Array[U32], U32].drop_every([1; 2; 3], 1)
    []
    ````
    """
    for i in Range[USize](0, a.size()) do
      if (i %% nth') == 0 then remove(a, i) end
    end
    a

  fun drop_while(a: A, f: {(B): Bool}): A^ =>
    """
    Drops elements at the beginning of the sequence while fun returns a truthy value.

    ````pony
    Seqs.drop_while([1; 2; 3; 2; 1], {(x: B): Bool => x < 3})
    [3, 2, 1]
    ````
    """
    var i: USize = 0
    for e in a.values() do
      if f(e) then
        i = i + 1
        remove(a, i)
      else
        return a
      end
    end
    a

  fun each(a: A, f: {(B)}) =>
    """
    Invokes the given fun for each element in the sequence.

    ````pony
    Seqs.each(["some"; "example"], {(x: B) => env.out.print(x)})
    "some"
    "example"
    ````
    """
    for e in a.values() do
      f(e)
    end

  fun filter(a: A, f: {(B): Bool}): A^ =>
    """
    Filters the sequence, i.e. returns only those elements for which fun
    returns a truthy value.

    ````pony
    Seqs[Array[U32], U32].filter([1; 2; 3], {(x: B): Bool => x %% 2 == 0})
    [2]
    ````
    """
    let out = a.create()
    for e in a.values() do
      if f(e) then out.push(e) end
    end
    out

  fun find(a: A, f: {(B): Bool}, default: B): B^ =>
    """
    Returns the first element for which fun returns a truthy value.
    If no such element is found, returns default.

    ````pony
    Seqs[Array[U32], U32].find([2; 3; 4], {(x: B): Bool => x %% 2 == 1}, 9)
    3

    Seqs[List[U32], U32].find({2, 4, 6}, {(x: B): Bool => x %% 2 == 1}, 0)
    0
    ````
    """
    for e in a.values() do
      if f(e)  then return e end
    end
    default

  fun find_index(a: A, f: {(B): Bool}): ISize =>
    """
    Similar to find, but returns the index (zero-based) of the element instead
    of the element itself.

    ````pony
    Seqs[Array[U32], U32].find_index([2; 4; 6], {(x: B): Bool => x %% 2 == 1})
    -1

    Seqs[Array[U32], U32].find_index([2; 3; 4], {(x: B): Bool => x %% 2 == 1})
    1
    ````
    """
    var i: ISize = 0
    for e in a.values() do
      if f(e)  then return i end
      i = i + 1
    end
    -1

  fun find_value(a: A, f_value: {(B): Any}): Any^ =>
    """
    Similar to find, but returns the value of the function invocation instead
    of the element itself.

    ````pony
    Seqs.find_value([2; 3; 4], {(x: U32): U32 =>  if x > 2 then x * x})
    9

    Seqs.find_value([2; 4; 6], {(x): Bool => x %% 2 == 1 })
    None

    Seqs.find_value([2; 3; 4], {(x: U32): Bool => x %% 2 == 1 })
    true

    Seqs.find_value([1; 2; 3], "no bools!", &is_boolean/1)
    ````
    """
    var i: ISize = 0
    for e in a.values() do
      var v = f_value(e)
      if (v is None) == false then return v end
    end
    None

  fun flat_map(a: A, f: {(B): Array[Any]}) =>
    """
    Maps the given fun over sequence and flattens the result.

    ````pony
    Seqs.flat_map(['a', 'b', 'c'], {(x: U8): Array[Any] => [x; x]})
    ['a', 'a', 'b', 'b', 'c', 'c']

    Seqs.flat_map([{1, 3}, {4, 6}], {(x: (U32, U32)): Array[Any] => Num[U32].range_i(x._1, x._2)})
    [1, 2, 3, 4, 5, 6]

    Seqs.flat_map(['a', 'b', 'c'], {(x: U8): Array[Any] => [x]})
    [['a'], ['b'], ['c']]
    ````
    """
    var out= Array[Any]
    for e in a.values() do
      out.append(f(e))
    end
    out

  // fun flat_map_reduce(a: A, acc, fn) =>
    // """
    // Maps and reduces a sequence, flattening the given results (only one level deep).
    // """

  fun intersperse(a: A, x: B): A^ =>
    """
    Intersperses element between each element of the sequence.
    ````pony
    Seqs.intersperse([1; 2; 3], 0)
    [1; 0; 2; 0; 3]

    Seqs.intersperse([1], 0)
    [1]

    Seqs.intersperse([], 0)
    []

    Seqs.intersperse({1, 2, 3}, 0)
    {1, 0, 2, 0, 3)
    ````
    """
    var s = clone(a)
    a.clear()
    var i: USize = 0
    for e in s.values() do
      a.push(e)
      if (i %% 2) == 1 then
        a.push(x)
      end
      i = i + 1
    end
    a

    fun with_index(a: A, offset: USize = 0): Array[(B, USize)] =>
    """
    Returns the sequence with each element wrapped in a tuple alongside its
    index.
    ````pony
    Seqs[Array[String], String].with_index(["a"; "b"; "c"])
    [("a", 0); ("b", 1); ("c", 2)]

    Seqs[List[String], String].with_index({"a", "b", "c"}, 3)
    [("a", 3); ("b", 4); ("c", 5)]
    ````
    """
    let out = Array[(B, USize)]
    for i in Range[USize](0, a.size()) do
      try out.push((a(i)?, offset + i)) end
    end
    out

  // fun into(a: A, collectable) =>
    // """Inserts the given sequence into a collectable."""

  // fun into(a: A, collectable, transform) =>
  // """Inserts the given sequence into a collectable according to the transformation function."""

  fun join(a: A, joiner: String = "", f_str: ({(B): String} | None) = None): String =>
    """
    Joins the given sequence into a binary using joiner as a separator.
    ````pony
    Seqs.join([1; 2; 3])
    "123"

    Seqs.join([1; 2; 3], " = ")
    "1 = 2 = 3"
    ````
    See also: `map_join`
    ````pony
    Seqs.map_join([1; 2; 3], "", {(x: U32): U32 => x * 2})
    "246"

    Seqs.map_join([1; 2; 3], " = ", {(x: U32): U32 => x * 2})
    "2 = 4 = 6"
    ````
    """
    var s: String = ""
    var i: USize = 0
    for e in a.values() do
      if f_str is None then
        s = s + try (e as Stringable).string() else "*" end
      else
        s = s + try (f_str as {(B): String val})(e) else "*" end
      end
      if i < (a.size() - 1) then s = s.add(joiner) end
      i = i + 1
    end
    s

  fun map(a: A, f: {(B): B}): A^ =>
    """
    Returns a list where each element is the result of invoking fun on each
    corresponding element of sequence.
    ````pony
    Seqs.map([1; 2; 3], {(x: U32): U32 => x * 2})
    [2; 4; 6]

    Seqs.map([("a" 1); ("b" 2)], {(x: (String, U32)) => (x._1, -x._2)})
    [("a" -1); ("b" -2)]
    ````
    """
    var i: USize = 0
    for e in a.values() do
      try a(i)? = f(e) end
      i = i + 1
    end
    a

  fun map_every(a: A, nth': USize, f: {(B): B}): A^ =>
    """
    Returns a list of results of invoking fun on every nth' element of
    sequence, starting with the first element.
    ````pony
    Seqs.map_every([1..10], 2, {(x: U32): U32 => x + 1000})
    [1001, 2, 1003, 4, 1005, 6, 1007, 8, 1009, 10]

    Seqs.map_every([1..10], 3, {(x: U32): U32 => x + 1000})
    [1001, 2, 3, 1004, 5, 6, 1007, 8, 9, 1010]

    Seqs.map_every([1..5], 0, {(x: U32): U32 => x + 1000})
    [1, 2, 3, 4, 5]

    Seqs.map_every([1; 2; 3], 1, {(x: U32): U32 => x + 1000})
    [1001, 1002, 1003]
    ````
    """
    var i: USize = 0
    for e in a.values() do
      if (i %% nth') == 0 then
        try a(i)?= f(e) end
      end
      i = i + 1
    end
    a

  fun map_intersperse(a: A, sep: B, f_mapper: {(B): B}): A^ =>
    """
    Maps and intersperses the given sequence in one pass.
    ````pony
    Seqs[Array[(U32 | U8)], （(U32 | U8)].map_intersperse([1; 2; 3], 'a', {(x: U32): U32 => x * 2})
    [2; 'a'; 4; 'a'; 6]
    ````
    """
    var s = clone(a)
    a.clear()
    var i: USize = 0
    for e in s.values() do
      a.push(f_mapper(e))
      if i < (s.size() -1 ) then a.push(sep) end
      i = i + 1
    end
    a

  fun map_join(a: A, joiner: String, f_mapper: {(B): B}, f_str: ({(B): String} | None) = None): String =>
    """
    Maps and joins the given sequence in one pass.
    ````pony
    Seqs.map_join([1; 2; 3], "", {(x: U32): U32 => x * 2})
    "246"

    Seqs.map_join([1; 2; 3], " = ", {(x: U32): U32 => x * 2})
    "2 = 4 = 6"
    ````
    """
    var s: String = ""
    var i: USize = 0
    for e in a.values() do
      let e' = f_mapper(e)
      if f_str is None then
        s = s + try (e' as Stringable).string() else "*" end
      else
        s = s + try (f_str as {(B): String val})(e') else "*" end
      end
      if i < (a.size() - 1) then s = s.add(joiner) end
      i = i + 1
    end
    s

  // ({(B, B): B} | None) = None
  fun map_reduce(a: A, acc': B, f_mapper:{(B, B): (B, B)}, f_add: {(B, B): B}): (A, B) =>
    """
    Invokes the given function to each element in the sequence to reduce
    it to a single element, while keeping an accumulator.
    ````pony
    map_reduce([1; 2; 3], 0, {(x: U32, acc: U32): U32 => (x * 2, x + acc)} end)
    ([2; 4; 6], 6)
    ````
    """
    var acc = acc'
    for i in Range[USize](0, a.size()) do
      try
        let e = a(i)?
        let e_tuple = f_mapper(e, acc)
        // acc = (f_add as {(B, B): B})(acc, e_v)
        a(i)? = e_tuple._1
        acc = f_add(acc, e_tuple._2)
      end
    end
    (a, acc)

  fun reduce(a: A, acc': B, f: {(B, B): B}): B =>
    """
    Invokes fun for each element in the sequence with the accumulator.
    ````pony
    Seqs.reduce([1; 2; 3], 0, {(x: U32, acc: U32):U32 => x + acc})
    6
    ````
    """
    var acc = acc'
    try
      for i in Range[USize](0, a.size()) do
        let e = a(i)?
        let e_v = f(e, acc)
        // acc = (f_add as {(B, B): B})(acc, e_v)
        acc = f(acc, e_v)
      end
    end
    acc

  fun reduce_while(a: A, acc: B, f: {(B, B): B}) =>
    """
    Reduces sequence until fun returns {:halt, term}.
    ````pony
    Seqs.reduce_while([1..100], 0, fn x, acc => if x < 5 then acc + x else acc})
    10

    Seqs.reduce_while([1..100], 0, {(x: U32, acc: U32): U32 => if x > 0 then acc + x else acc})
    5050
    ````
    """

  fun reject(a: A, f: {(B): Bool}) =>
    """
    Returns a list of elements in sequence excluding those for which the
    function fun returns a truthy value.
    ````pony
    Seqs.reject([1; 2; 3], {(x:U32): U32 => x%%2 == 0})
    [1; 3]
    ````
    """

  fun reverse(a: A): A^ =>
    """
    Returns a list of elements in sequence in reverse order.
    ````pony
    Seqs.reverse([1; 2; 3])
    [3; 2; 1]
    ````
    """
    for i in Range[USize](0, a.size()/2) do
      swap(a, i, a.size()-1-i)
    end
    a

  fun reverse_slice(a: A, start_index: USize, amount: USize) =>
    """
    Reverses the sequence in the range from initial start_index through count
    elements.

    ````pony
    let arr = Num[U32].range_i(1, 10)
    Seqs.reverse_slice(arr, 5, 5)
    [1; 2; 3; 4; 5; 10; 9; 8; 7; 6]
    """
    for i in Range[USize](0, amount/2) do
      swap(a, start_index+i,  (start_index+amount) -1 -i)
    end
    a

  fun swap(a: A, i: USize, j: USize): A^ =>
    try
      let tmp = a(i)?
      a(i)? =  a(j)?
      a(j)? = tmp
    end
    a

  fun scan(a: A, f: {(B, B): B}): A^ =>
    """
    Applies the given function to each element in the sequence, storing the
    result in a list and passing it as the accumulator for the next computation.
    Uses the first element in the sequence as the starting value.
    ````pony
    Seqs.scan([1; 2; 3; 4; 5], {(x: U32, y: U32): U32 => x+y })
    [1; 3; 6; 10; 15]
    ````
    """
    for i in Range[USize](1, a.size()) do
      try a(i)? = f(a(i-1)?, a(i)?) end
    end
    a

  // fun scan(a: A, acc, fn) =>
  // """Applies the given function to each element in the sequence, storing the result in a list and passing it as the accumulator for the next computation. Uses the given acc as the starting value."""

  // fun slice(a: A, index_range) =>
  // """Returns a subset list of the given sequence by index_range."""

  fun slice(a: A, index: ISize, n: USize): A^ =>
    """
    Returns a subset list of the given sequence, from index (zero-based)
    with amount number of elements if available.
    ````pony
    Seqs.slice([0; 1; 2; 3; 4; 5; 6; 7; 8; 9], 5, 20)
    [5; 6; 7; 8; 9; 10]

    Seqs.slice([0; 1; 2; 3; 4; 5; 6; 7; 8; 9], -3, 2)
    [7; 8]
    ````
    """
    let start' = if (index + a.size().isize_unsafe()) < 0 then 0 else index.usize_unsafe() end
    let start'': USize = if start' > a.size() then a.size() else start' end

    let start: USize = (start'' + a.size()) %% a.size()
    let out = a.create()
    for i in Range[USize](start, start + n + 1) do
      try out.push(a(i)?) end
    end
    out

  fun sort(a: A): A^ =>
    """
    Sorts the sequence.
    ````pony
    Seqs.sort([2; 3; 1])
    [1; 2; 3]
    ````
    """
    Sort[A, B](a)
    a

  fun sort_by(a: A, f: {(B): USize}): A^ =>
    """
    Sorts the sequence by the given function.
    ````pony
    Seqs.sort_by(["some"; "kind"; "of"; "monster"], {(a: String, b: String): Bool => a.size() > b.size()})
    ["of"; "some"; "kind"; "monster"]
    ````
    """
    SortBy[A, B](a, f)
    a

  fun shuffle(a: A): A^ =>
    """
    Returns a list with the elements of sequence shuffled.
    ````pony
    Seqs.shuffle([1; 2; 3; 4; 5])
    [3; 1; 4; 2; 5]
    ````
    """
    let mt = MT
    var i: USize = a.size() - 1

    while i > 1 do
      let ceil = i = i - 1
        swap(a,i, mt.int[USize](ceil))
    end
    a

  fun rotation(a: A, n: USize): A^ =>
    """
    Returns a list with the elements of sequence shuffled.
    ````pony
    Seqs.rotation([1; 2; 3; 4; 5; 6; 7], 1)
    [7; 1; 2; 3; 4; 5; 6]

    Seqs.rotation({1, 2, 3, 4, 5, 6, 7}, 2)
    {6, 7, 1, 2, 3, 4, 5}
    ````
    """
    var i: USize = a.size() - 1

    while i > 1 do
      let ceil = i = i - 1
      swap(a, i, ceil)
    end
    a

  fun to_list(a: A): List[B]^ =>
    """
    Converts sequence to a list.

    ````pony
    Seqs.to_list([1; 2; 3])
    {1, 2, 3}
    ````
    """
    try
      (a as List[B])
    else
      let out = List[B](a.size())
      for e in a.values() do out.push(e) end
      out
    end

  fun to_array(a: A): Array[B]^ =>
    """
    Converts sequence to a list.

    ````pony
    Seqs.to_array({1, 2, 3})
    [1; 2; 3]
    ````
    """
    try
      (a as Array[B])
    else
      let out = Array[B](a.size())
      for e in a.values() do out.push(e) end
      out
    end

  fun uniq(a: A) =>
    """
    Traverse the sequence, removing all duplicated elements.

    ````pony
    Seqs.uniq([1, 5, 3, 3, 2, 3, 1, 5, 4])
    [1, 5, 3, 2, 4]
    ````
    """

  fun uniq_by(a: A, f: {(B, B): B}) =>
    """
    Traverse the sequence, by removing the elements for which function fun
    returned duplicate elements.

    ````pony
    Seqs[Array[(U32, String)], (U32, String)]
    .uniq_by([(1, "x"); (2, "y"); (1, "z")], {(x, _) =-> x })
    [{1, "x}, {2, "y}]

    Seqs[Array[(String, List[(String | U32)])], (String, List[(String | U32)])]
    .uniq_by([("a", {"tea", 2}); ("b", {"tea", 2}); ("c", {"coffee", 1})], fn {_, y} -> y end)
    ["a" {"tea", 2}, "c" {"coffee", 1}]
    ````
    """

  fun unzip(a: A): Array[B] =>
    """
    Opposite of zip2. Extracts two-element tuples from the given sequence and
    groups them together.

    ````pony
    Seqs[Array[List[(String | U32)]], List[(String | U32)]].unzip([("a", 1), ("b", 2), ("c", 3)])
    [("a", "b", "c"), (1, 2, 3)]

    Seqs[Array[Array[(String | U32)]], Array[(String | U32)]].unzip([["a", 1]; ["b", 2]; ["c", 3}]])
    [["a"; "b"; "c"], [1; 2; 3]]
    ````
    """
    let out = Array[B]
    out

  fun zip(sequences: Seq[A]) =>
    """
    Zips corresponding elements from a finite collection of sequences into one
    list of tuples.

    ````pony
    Seqs.zip([[1, 2, 3], ['a', 'b', 'c'], ["foo", "bar", "baz"]])
    [(1, 'a', "foo"), (2, 'b', "bar"), (3, 'c', "baz")]

    Seqs.zip([[1, 2, 3, 4, 5], ['a', 'b', 'c']])
    [(1, 'a'), (2, 'b'), (3, 'c')]
    ````
    """

  fun zip2(a: A, b: A) =>
    """
    Zips corresponding elements from two sequences into one list of tuples.

    ````pony
    Seqs.zip([1, 2, 3], ['a', 'b', 'c'])
    [(1, 'a'), (2, 'b'), (3, 'c')]
    ````
    """

  // Debug
  fun typeof(a: A): SeqType =>
    """
    Return `sequence` type enum value.
    """
    // try
      // (a as List[B])
      // return ListType
    // else
      // try
        // (a as Array[B])
        // return ArrayType
      // else
        // try
          // (a as StringDelete)
          // return StringType
        // else
          // return UnknowType
        // end
      // end
    // end
    iftype A <: List[B] then
      return ListType
    end
    iftype A <: Array[B] then
      return ArrayType
    end
    iftype A <: String then
      return StringType
    end
    UnknowType

  fun trace(a: A, f: ({(B): String val} | None) = None) =>
    """
    Print `sequence` debug info.
    """
    let t = typeof(a)
    var out = "[Trace] "
    var joiner = ","
    match t
      | ListType =>
      joiner = ","
      out = out + "List => size:"+a.size().string() + " {"
      | ArrayType =>
      joiner = ";"
      out = out + "Array => size:"+a.size().string() + " ["
      | StringType =>
      joiner = ""
      out = out + "String => size:"+a.size().string() + " \""
      | UnknowType => out = out + "<Unknow type!> $ size:"+a.size().string()
    end
    out = out + join(a, joiner, f)
    match t
      | ListType => out = out + "}"
      | ArrayType => out = out + "]"
      | StringType => out = out +"\""
    end
    Debug.out(out)

interface Cloneable[A: Seq[B] ref, B: Comparable[B] #read]
  fun clone(): A^

primitive ArrayType
primitive ListType
primitive StringType
primitive UnknowType
type SeqType is (ArrayType | ListType | StringType | UnknowType)
