/*
test.pony ---  I love pony 🐎.
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

use "ponytest"
// use "debug"
// use "collections"
use "debug"

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)

  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestSeqs)?

class iso _TestSeqs is UnitTest
  fun name(): String => "Seqs"

  fun apply(h: TestHelper)? =>
    // h.assert_eq[String]("hi", "hi")
    // type TT is Seqs[Array[U32], U32]
    var arr: Array[U32] = [9; 0; 5; 4; 2; 1; 3; 6; 7; 8]
    h.assert_eq[Bool](true, Seqs[Array[U32], U32].is_member(arr, 3))

    (var min: U32, var max: U32) = Seqs[Array[U32], U32].min_max(arr)?
    h.assert_eq[U32](0, min)
    h.assert_eq[U32](9, max)

    for e in arr.values() do
      Debug.out(e)
    end
    //drop: 0 1
    Seqs[Array[U32], U32].drop(arr, 2)
    h.assert_eq[USize](8, arr.size())

    //drop_tail:9
    Seqs[Array[U32], U32].drop_tail(arr, 1)
    h.assert_eq[USize](7, arr.size())

    // member
    h.assert_eq[Bool](false, Seqs[Array[U32], U32].is_member(arr, 11))

    // min_max
    (min, max) = Seqs[Array[U32], U32].min_max(arr)?
    h.assert_eq[U32](2, min)
    h.assert_eq[U32](8, max)

    // chunk
    // let ss = Seqs[Array[U32], U32].chunk_by(arr, { (x: U32): Bool => x < 5 })
    // h.assert_eq[USize](2, ss.size())
    // h.assert_eq[U32](2, ss.apply(0)?.apply(0)?)
    // h.assert_eq[U32](5, ss.apply(1)?.apply(0)?)

    let ss = Seqs[Array[U32], U32].chunk_every(arr, 3)
    h.assert_eq[USize](3, ss.size())
    h.assert_eq[U32](2, ss.apply(0)?.apply(0)?)
    h.assert_eq[U32](5, ss.apply(1)?.apply(0)?)
    h.assert_eq[U32](8, ss.apply(2)?.apply(0)?)

    h.assert_eq[U32](8, Seqs[Array[U32], U32].random(arr)?)

     // h.assert_eq[(U32, U32)]( (1, 3), Seqs[Array[U32], U32].min_max(arr)?)
  //
  //test.pony ends here
