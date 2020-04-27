/*
any_map.pony ---  I love pony 🐎.
Date: 2020-04-27

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

primitive _MapEmpty
primitive _MapDeleted

type AnyMap[K, V] is HashAnyMap[K, V]
  """
  This is a map that uses structural equality on the key.
  
  ````pony
  let map = AnyMap[U8, String]({(key: U8): USize => key.usize_unsafe()})
  map(1)="I"
  map(2)="love"
  map(3)="Pony"

  let map2 = AnyMap[U8, String](object is HashFunction[U8]
      fun hash(x: U8): USize => ...
      fun eq(x: U8, y: U8): Bool => ...
  end)
  ````
  """

type AnyMapIs[K, V] is HashAnyMap[K, V]
  """
  This is a map that uses identity comparison on the key.
  """

class HashAnyMap[K, V]
  """
  A quadratic probing hash map. Resize occurs at a load factor of 0.75. A
  resized map has 2 times the space. The hash function can be plugged in to the
  type to create different kinds of maps.
  """
  var _size: USize = 0
  var _array: Array[((K, V) | _MapEmpty | _MapDeleted)]
  let _f_hash: ({(box->K!): USize} val | HashFunction[box->K!] val)
  let _hash: HashFunction[box->K!] val
  
  new create(f: ({(box->K!): USize} val | HashFunction[box->K!] val),
    prealloc: USize = 6) =>
    """
    Create an array with space for prealloc elements without triggering a
    resize. Defaults to 6.
    """
    let len = (prealloc * 4) / 3
    let n = len.max(8).next_pow2()
    _array = _array.init(_MapEmpty, n)
    _f_hash = f
    _hash = object is HashFunction[box->K!]
      fun apply(x: box->K!): USize => hash(x)
      fun hash(x: box->K!): USize => 0
      fun eq(x: box->K!, y: box->K!): Bool => true
    end

  fun size(): USize =>
    """
    The number of items in the map.
    """
    _size

  fun space(): USize =>
    """
    The available space in the map. Resize will happen when
    size / space >= 0.75.
    """
    _array.space()

  fun apply(key: box->K!): this->V ? =>
    """
    Gets a value from the map. Raises an error if no such item exists.
    """
    (let i, let found) = _search(key)

    if found then
      _array(i)? as (_, this->V)
    else
      error
    end

  fun ref update(key: K, value: V): (V^ | None) =>
    """
    Sets a value in the map. Returns the old value if there was one, otherwise
    returns None. If there was no previous value, this may trigger a resize.
    """
    try
      (let i, let found) = _search(key)

      match _array(i)? = (consume key, consume value)
      | (_, let v: V) =>
        return consume v
      else
        _size = _size + 1

        if (_size * 4) > (_array.size() * 3) then
          _resize(_array.size() * 2)
        end
      end
    end

  fun ref upsert(key: K, value: V, f: {(V, V): V^} box): V =>
    """
    Combines a provided value with the current value for the provided key
    using the provided function. If the provided key has not been added to
    the map yet, it sets its value to the provided value and ignores the
    provided function.

    As a simple example, say we had a map with I64 values and we wanted to
    add 4 to the current value for key "test", which let's say is currently 2.
    We call

    m.upsert("test", 4, {(current, provided) => current + provided })

    This changes the value associated with "test" to 6.

    If we have not yet added the key "new-key" to the map and we call

    m.upsert("new-key", 4, {(current, provided) => current + provided })

    then "new-key" is added to the map with a value of 4.

    Returns the value that we set the key to
    """

    (let i, let found) = _search(key)
    let value' = value

    try
      if found then
        (let pkey, let pvalue) = (_array(i)? = _MapEmpty) as (K^, V^)

        let new_value = f(consume pvalue, consume value)
        let new_value' = new_value

        _array(i)? = (consume pkey, consume new_value)

        return _array(i)? as (_, V)
      else
        let key' = key

        _array(i)? = (consume key, consume value)
        _size = _size + 1

        if (_size * 4) > (_array.size() * 3) then
          _resize(_array.size() * 2)
        end
      end

      value'
    else
      // This is unreachable, since index will never be out-of-bounds
      value'
    end

  fun ref insert(key: K, value: V): V! =>
    """
    Set a value in the map. Returns the new value, allowing reuse.
    """
    let value' = value
    try
      (let i, let found) = _search(key)
      let key' = key
      _array(i)? = (consume key, consume value)

      if not found then
        _size = _size + 1

        if (_size * 4) > (_array.size() * 3) then
          _resize(_array.size() * 2)
        end
      end

      value'
    else
      // This is unreachable, since index will never be out-of-bounds.
      value'
    end

  fun ref insert_if_absent(key: K, value: V): V =>
    """
    Set a value in the map if the key doesn't already exist in the Map.
    Saves an extra lookup when doing a pattern like:

    ```pony
    if not my_map.contains(my_key) then
      my_map(my_key) = my_value
    end
    ```

    Returns the value, the same as `insert`, allowing 'insert_if_absent'
    to be used as a drop-in replacement for `insert`.
    """
    let value' = value

    try
      (let i, let found) = _search(key)
      let key' = key

      if not found then
        _array(i)? = (consume key, consume value)

        _size = _size + 1

        if (_size * 4) > (_array.size() * 3) then
          _resize(_array.size() * 2)
        end
      end

      _array(i)? as (_, V)
    else
      // This is unreachable, since index will never be out-of-bounds.
      value'
    end

  fun ref remove(key: box->K!): (K^, V^) ? =>
    """
    Delete a value from the map and return it. Raises an error if there was no
    value for the given key.
    """
    try
      (let i, let found) = _search(key)

      if found then
        _size = _size - 1

        match _array(i)? = _MapDeleted
        | (let k: K, let v: V) =>
          return (consume k, consume v)
        end
      end
    end
    error

  fun get_or_else(key: box->K!, alt: this->V): this->V =>
    """
    Get the value associated with provided key if present. Otherwise,
    return the provided alternate value.
    """
    (let i, let found) = _search(key)

    if found then
      try
        _array(i)? as (_, this->V)
      else
        // This should never happen as we have already
        // proven that _array(i) exists
        consume alt
      end
    else
      consume alt
    end

  fun contains(k: box->K!): Bool =>
    """
    Checks whether the map contains the key k
    """
    (_, let found) = _search(k)
    found

  fun ref concat(iter: Iterator[(K^, V^)]) =>
    """
    Add K, V pairs from the iterator to the map.
    """
    for (k, v) in iter do
      this(consume k) = consume v
    end

  fun add(
    key: this->K!,
    value: this->V!)
    : HashAnyMap[this->K!, this->V!]^
  =>
    """
    This with the new (key, value) mapping.
    """
    let r = clone()
    r(key) = value
    r

  fun sub(key: this->K!)
    : HashAnyMap[this->K!, this->V!]^
  =>
    """
    This without the given key.
    """
    let r = clone()
    try r.remove(key)? end
    r

  fun next_index(prev: USize = -1): USize ? =>
    """
    Given an index, return the next index that has a populated key and value.
    Raise an error if there is no next populated index.
    """
    for i in Range(prev + 1, _array.size()) do
      match _array(i)?
      | (_, _) => return i
      end
    end
    error

  fun index(i: USize): (this->K, this->V) ? =>
    """
    Returns the key and value at a given index.
    Raise an error if the index is not populated.
    """
    _array(i)? as (this->K, this->V)

  fun ref compact() =>
    """
    Minimise the memory used for the map.
    """
    _resize(((_size * 4) / 3).next_pow2().max(8))

  fun clone()
    : HashAnyMap[this->K!, this->V!]^
  =>
    """
    Create a clone. The key and value types may be different due to aliasing
    and viewpoint adaptation.
    """
    let r = HashAnyMap[this->K!, this->V!](_f_hash, _size)

    for (k, v) in pairs() do
      r(k) = v
    end
    r

  fun ref clear() =>
    """
    Remove all entries.
    """
    _size = 0
    // Our default prealloc of 6 corresponds to an array alloc size of 8.
    let n: USize = 8
    _array = _array.init(_MapEmpty, n)

  fun _search(key: box->K!): (USize, Bool) =>
    """
    Return a slot number and whether or not it's currently occupied.
    """
    var idx_del = _array.size()
    let mask = idx_del - 1
    let h = match _f_hash
    | let hash': {(box->K!): USize} val => hash'(key)
    | let hash': HashFunction[box->K!] val => hash'.hash(key)
    end
    var idx = h and mask

    try
      for i in Range(0, _array.size()) do
        let entry = _array(idx)?

        match entry
        | (let k: this->K!, _) =>
          let eq' = match _f_hash
          | let hash': {(box->K!): USize} val => hash'(k) == hash'(key)
          | let hash': HashFunction[box->K!] val => hash'.eq(k, key)
          end
          if eq' then
            return (idx, true)
        end
        | _MapEmpty =>
          if idx_del <= mask then
            return (idx_del, false)
          else
            return (idx, false)
          end
        | _MapDeleted =>
          if idx_del > mask then
            idx_del = idx
          end
        end

        idx = (h + ((i + (i * i)) / 2)) and mask
      end
    end

    (idx_del, false)

  fun ref _resize(len: USize) =>
    """
    Change the available space.
    """
    let old = _array
    let old_len = old.size()

    _array = _array.init(_MapEmpty, len)
    _size = 0

    try
      for i in Range(0, old_len) do
        match old(i)? = _MapDeleted
        | (let k: K, let v: V) =>
          this(consume k) = consume v
        end
      end
    end

  fun keys(): AnyMapKeys[K, V, this->HashAnyMap[K, V]]^ =>
    """
    Return an iterator over the keys.
    """
    AnyMapKeys[K, V, this->HashAnyMap[K, V]](this)

  fun values(): AnyMapValues[K, V, this->HashAnyMap[K, V]]^ =>
    """
    Return an iterator over the values.
    """
    AnyMapValues[K, V, this->HashAnyMap[K, V]](this)

  fun pairs(): AnyMapPairs[K, V, this->HashAnyMap[K, V]]^ =>
    """
    Return an iterator over the keys and values.
    """
    AnyMapPairs[K, V, this->HashAnyMap[K, V]](this)

class AnyMapKeys[K, V, M: HashAnyMap[K, V] #read] is
  Iterator[M->K]
  """
  An iterator over the keys in a map.
  """
  let _map: M
  var _i: USize = -1
  var _count: USize = 0

  new create(map: M) =>
    """
    Creates an iterator for the given map.
    """
    _map = map

  fun has_next(): Bool =>
    """
    True if it believes there are remaining entries. May not be right if values
    were added or removed from the map.
    """
    _count < _map.size()

  fun ref next(): M->K ? =>
    """
    Returns the next key, or raises an error if there isn't one. If keys are
    added during iteration, this may not return all keys.
    """
    _i = _map.next_index(_i)?
    _count = _count + 1
    _map.index(_i)?._1

class AnyMapValues[K, V, M: HashAnyMap[K, V] #read] is
  Iterator[M->V]
  """
  An iterator over the values in a map.
  """
  let _map: M
  var _i: USize = -1
  var _count: USize = 0

  new create(map: M) =>
    """
    Creates an iterator for the given map.
    """
    _map = map

  fun has_next(): Bool =>
    """
    True if it believes there are remaining entries. May not be right if values
    were added or removed from the map.
    """
    _count < _map.size()

  fun ref next(): M->V ? =>
    """
    Returns the next value, or raises an error if there isn't one. If values
    are added during iteration, this may not return all values.
    """
    _i = _map.next_index(_i)?
    _count = _count + 1
    _map.index(_i)?._2

class AnyMapPairs[K, V, M: HashAnyMap[K, V] #read] is
  Iterator[(M->K, M->V)]
  """
  An iterator over the keys and values in a map.
  """
  let _map: M
  var _i: USize = -1
  var _count: USize = 0

  new create(map: M) =>
    """
    Creates an iterator for the given map.
    """
    _map = map

  fun has_next(): Bool =>
    """
    True if it believes there are remaining entries. May not be right if values
    were added or removed from the map.
    """
    _count < _map.size()

  fun ref next(): (M->K, M->V) ? =>
    """
    Returns the next entry, or raises an error if there isn't one. If entries
    are added during iteration, this may not return all entries.
    """
    _i = _map.next_index(_i)?
    _count = _count + 1
    _map.index(_i)?
