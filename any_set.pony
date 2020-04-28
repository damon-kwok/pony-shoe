/*
any_set.pony ---  I love pony 🐎.
Date: 2020-04-28

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

type AnySet[A: Any #read] is HashAnySet[A]
  """
  A set, built on top of a HashMap. This is implemented as map of an alias of
  a type to itself

  ````pony
  let a = AnySet[U8]
    a.set(1)
    a.set(2)

  let b = AnySet[U8]({(k: CustomType): Usize => ... hash k})
    a.set(1)
    a.set(2)

  let c = AnyMap[CustomType](object is HashFunction[CustomType]
    fun hash(x: CustomType): USize => ...
    fun eq(x: CustomType, y: CustomType): Bool => ...
  end)
  ````
  """

type AnySetIs[A: Any #read] is HashAnySet[A]

class HashAnySet[A: Any #read]
  """
  A set, built on top of a HashMap. This is implemented as map of an alias of
  a type to itself
  """
  embed _map: HashAnyMap[A!, A]
  let _f_hash: ({(box->A!): USize} val | HashFunction[box->A!] val)

  new create(f: ({(box->A!): USize} val | HashFunction[box->A!] val)
    = {(key: box->A!): USize =>
    match key
      | let key': HashFunction[box->A!] val => key'.hash(key)
      | let key': Hashable val => key'.hash()
    end; 0},
    prealloc: USize = 8) =>
    """
    Defaults to a prealloc of 8.
    """
    _f_hash = f
    _map = _map.create(f, prealloc)

  fun size(): USize =>
    """
    The number of items in the set.
    """
    _map.size()

  fun space(): USize =>
    """
    The available space in the set.
    """
    _map.space()

  fun apply(value: box->A!): this->A ? =>
    """
    Return the value if its in the set, otherwise raise an error.
    """
    _map(value)?

  fun contains(value: box->A!): Bool =>
    """
    Checks whether the set contains the value.
    """
    _map.contains(value)

  fun ref clear() =>
    """
    Remove all elements from the set.
    """
    _map.clear()

  fun ref set(value: A) =>
    """
    Add a value to the set.
    """
    _map(value) = consume value

  fun ref unset(value: box->A!) =>
    """
    Remove a value from the set.
    """
    try _map.remove(value)? end

  fun ref extract(value: box->A!): A^ ? =>
    """
    Remove a value from the set and return it. Raises an error if the value
    wasn't in the set.
    """
    _map.remove(value)?._2

  fun ref union(that: Iterator[A^]) =>
    """
    Add everything in that to the set.
    """
    for value in that do
      set(consume value)
    end

  fun ref intersect/*[K: HashFunction[box->A!] val = H]*/(
    that: HashAnySet[box->A!/*, K*/])
  =>
    """
    Remove everything that isn't in that.
    """
    let start_size = _map.size()
    var seen: USize = 0
    var i: USize = -1

    while seen < start_size do
      try
        i = next_index(i)?
        if not that.contains(index(i)?) then
          unset(index(i)?)
        end
      end
      seen = seen + 1
    end

  fun ref difference(that: Iterator[A^]) =>
    """
    Remove elements in this which are also in that. Add elements in that which
    are not in this.
    """
    for value in that do
      try
        extract(value)?
      else
        set(consume value)
      end
    end

  fun ref remove(that: Iterator[box->A!]) =>
    """
    Remove everything that is in that.
    """
    for value in that do
      unset(value)
    end

  fun add(
    value: this->A!)
    : HashAnySet[this->A!]^
  =>
    """
    Add a value to the set.
    """
    clone() .> set(value)

  fun sub(
    value: box->this->A!)
    : HashAnySet[this->A!]^
  =>
    """
    Remove a value from the set.
    """
    clone() .> unset(value)

  fun op_or(
    that: this->HashAnySet[A])
    : HashAnySet[this->A!]^
  =>
    """
    Create a set with the elements of both this and that.
    """
    let r = clone()

    for value in that.values() do
      r.set(value)
    end
    r

  fun op_and(
    that: this->HashAnySet[A])
    : HashAnySet[this->A!]^
  =>
    """
    Create a set with the elements that are in both this and that.
    """
    let r = HashAnySet[this->A!](_f_hash, size().min(that.size()))

    for value in values() do
      try
        that(value)?
        r.set(value)
      end
    end
    r

  fun op_xor(
    that: this->HashAnySet[A])
    : HashAnySet[this->A!]^
  =>
    """
    Create a set with the elements that are in either set but not both.
    """
    let r = HashAnySet[this->A!](_f_hash, size().max(that.size()))

    for value in values() do
      try
        that(value)?
      else
        r.set(value)
      end
    end

    for value in that.values() do
      try
        this(value)?
      else
        r.set(value)
      end
    end
    r

  fun without(
    that: this->HashAnySet[A])
    : HashAnySet[this->A!]^
  =>
    """
    Create a set with the elements of this that are not in that.
    """
    let r = HashAnySet[this->A!](_f_hash, size())

    for value in values() do
      try
        that(value)?
      else
        r.set(value)
      end
    end
    r

  fun clone(): HashAnySet[this->A!]^ =>
    """
    Create a clone. The element type may be different due to aliasing and
    viewpoint adaptation.
    """
    let r = HashAnySet[this->A!](_f_hash, size())

    for value in values() do
      r.set(value)
    end
    r

  fun eq(that: HashAnySet[A] box): Bool =>
    """
    Returns true if the sets contain the same elements.
    """
    (size() == that.size()) and (this <= that)

  fun ne(that: HashAnySet[A] box): Bool =>
    """
    Returns false if the sets contain the same elements.
    """
    not (this == that)

  fun lt(that: HashAnySet[A] box): Bool =>
    """
    Returns true if every element in this is also in that, and this has fewer
    elements than that.
    """
    (size() < that.size()) and (this <= that)

  fun le(that: HashAnySet[A] box): Bool =>
    """
    Returns true if every element in this is also in that.
    """
    try
      for value in values() do
        that(value)?
      end
      true
    else
      false
    end

  fun gt(that: HashAnySet[A] box): Bool =>
    """
    Returns true if every element in that is also in this, and this has more
    elements than that.
    """
    (size() > that.size()) and (that <= this)

  fun ge(that: HashAnySet[A] box): Bool =>
    """
    Returns true if every element in that is also in this.
    """
    that <= this

  fun next_index(prev: USize = -1): USize ? =>
    """
    Given an index, return the next index that has a populated value. Raise an
    error if there is no next populated index.
    """
    _map.next_index(prev)?

  fun index(i: USize): this->A ? =>
    """
    Returns the value at a given index. Raise an error if the index is not
    populated.
    """
    _map.index(i)?._2

  fun values(): AnySetValues[A, this->HashAnySet[A]]^ =>
    """
    Return an iterator over the values.
    """
    AnySetValues[A, this->HashAnySet[A]](this)

class AnySetValues[A: Any #read, S: HashAnySet[A] #read] is
  Iterator[S->A]
  """
  An iterator over the values in a set.
  """
  let _set: S
  var _i: USize = -1
  var _count: USize = 0

  new create(set: S) =>
    """
    Creates an iterator for the given set.
    """
    _set = set

  fun has_next(): Bool =>
    """
    True if it believes there are remaining entries. May not be right if values
    were added or removed from the set.
    """
    _count < _set.size()

  fun ref next(): S->A ? =>
    """
    Returns the next value, or raises an error if there isn't one. If values
    are added during iteration, this may not return all values.
    """
    _i = _set.next_index(_i)?
    _count = _count + 1
    _set.index(_i)?
