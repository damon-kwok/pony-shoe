/*
seqs.pony --- I love pony 🐎.
Date: 2020-04-24

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
use "debug"

primitive Num[A: (Real[A] val & Number) = I32]
  fun inc(a: A): A =>
    if a == A.max_value() then a else a+1 end

  fun dec(a: A): A =>
    """
    """
    if a == A.min_value() then a else a-1 end

  fun range(from: A, to: A): Array[A]^ =>
    """
    """
    let out = Array[A]
    // for i in Range[A](from, to) do
    //   out.push(i)
    // end
    var i = from
    while i != to do
      out.push(i.create(i))
      if from < to then i = i+1 else i = i-1 end
    end
    out

  fun range_i(from: A, to: A): Array[A]^ =>
    """
    """
    if from <= to then
      range(from, inc(to))
    else
      range(from, dec(to))
    end

  fun range_n(from: A, n: A): Array[A]^ =>
    """
    """
    let out = Array[A]
    // for i in Range[A](from, from + n) do
    //   out.push(i)
    // end
    var i = from
    while i != (from+n) do
      if n > 0 then i = i+1 else i = i-1 end
      out.push(i)
    end
    out

  fun print2(a: A, stream: (OutStream | None) = None) =>
    match stream
      | let stream': OutStream => stream'.print(a.string())
      | None => Debug.out(a.string()+"\n")
    end

  fun print(a: A): A =>
    Debug.out(a.string()+"\n")
    a

  fun write(a: A, stream: (OutStream | None) = None)  =>
    match stream
      | let stream': OutStream => stream'.write(a.string())
      | None => Debug.out(a)
    end

  fun copy(x: USize, a: A): Array[A]^ =>
    let out = Array[A]
    out.push(a)
    for i in Range[USize](0, x) do
      out.push(a)
    end
    out

  fun is_even(a: A): Bool => (a%%2) == 0
  fun is_odd(a: A): Bool => (a%%2) == 1
  fun double(a: A): A => a*2
  fun half(a: A): A => a/2
  fun sqr(a: A): A => a*a
  fun pow(n: USize, a: A): A =>
    if n<2 then return a end
    var out: A = a
    for i in Range[USize](0, n-1) do
      out = out *a
    end
    out


  fun add(a: A, b: A): A => a+b
  fun sub(a: A, b: A): A => a-b
  fun mul(a: A, b: A): A => a*b
  fun div(a: A, b: A): A => a/b
  fun rem(a: A, b: A): A => a%b
  fun mod(a: A, b: A): A => a%%b

  fun eq(a: A, b: A): Bool => a==b
  fun ne(a: A, b: A): Bool => a!=b
  fun lt(a: A, b: A): Bool => a<b
  fun le(a: A, b: A): Bool => a<=b
  fun ge(a: A, b: A): Bool => a>=b
  fun gt(a: A, b: A): Bool => a>b
