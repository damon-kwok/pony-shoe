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

primitive Num[A: (Real[A] val & Number) = ISize]
  fun inc(a: A, env: Env): A =>
    env.out.print("inc: ==> a:"+ a.string())
    if a == A.max_value() then a else a+1 end

  fun dec(a: A, env: Env): A =>
    env.out.print("dec: ==> a:"+ a.string())
    if a == A.min_value() then a else a-1 end

  fun range(from: A, to: A, env: Env): Array[A]^ =>
    env.out.print("range: ==> form:"+ from.string() +", to:"+to.string())
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

  fun range_i(from: A, to: A, env: Env): Array[A]^ =>
    env.out.print("range_i: ==> form:"+ from.string() +", to:"+to.string())
    if from <= to then
      range(from, inc(to, env), env)
    else
      range(from, dec(to, env), env)
    end

  fun range_n(from: A, n: A): Array[A]^ =>
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

//
//ints.pony ends here
