/*
seqs.pony ---  I love pony 🐎.
Date: 2020-04-21

Copyright (C) 2016-2020, The Pony Developers
Copyright (C) 2009-2020 Damon Kwok <damon-kwok@outlook.com>
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

// use "collections"
// use "random"
// use "debug"

// type Str is Seqs[String ref, U8]
primitive Str
  // Lambda
  fun size(a: String): USize => a.size()
  fun merge(joiner: String, a: String, b: String): String => a+b

  // fun join(joiner: String =""): String =>
  // a+joiner+b

  fun copy(a: String): Array[String]^ => [a; a]


  // Tweak whitespace
  fun trim (s: String): String =>
    """
    """
    s.trim()

  fun trim_left (s: String): String =>
    """
    """

  fun trim_right (s: String): String =>
    """
    """

  fun chomp (s: String): String =>
    """
    """

  fun collapse_whitespace (s: String): String =>
    """
    """

  fun word_wrap (len: USize, s: String): String =>
    """
    """

  fun center (len: USize, s: String): String =>
    """
    """

  fun pad_left (len: USize, padding: String, s: String): String =>
    """
    """

  fun pad_right (len: USize, padding: String, s: String): String =>
    """
    """


  // To shorter string
  fun truncate (len: USize, s: String): String =>
    """
    """

  fun left (len: USize, s: String): String =>
    """
    """

  fun right (len: USize, s: String): String =>
    """
    """

  fun chop_suffix (suffix: String, s: String): String =>
    """
    """

  fun chop_suffixes (suffixes: String, s: String): String =>
    """
    """

  fun chop_prefix (prefix: String, s: String): String =>
    """
    """

  fun chop_prefixes (prefixes: String, s: String): String =>
    """
    """

  fun shared_start (s1: String, s2: String): String =>
    """
    """

  fun shared_end (s1: String, s2: String): String =>
    """
    """


  // To longer string
  fun repeats (num: USize, s: String): String =>
    """
    """
    ""

  fun concat (/*&rest*/strings: String): String =>
    """
    """
    ""

  fun prepend (prefix: String, s: String): String =>
    """
    """
    prefix + s

  fun append (suffix: String, s: String): String =>
    """
    """
    s +"." +suffix

  // To and from lists
  fun lines (s: String): Array[String] =>
    """
    """
    let out = Array[String]
    var s': String ref = String()
    for c in s.values() do
      if (c.eq('\r') or c.eq('\n')) and (s'.size()>0) then
        out.push(s'.clone())
        s'.clear()
      else
        s'.push(c)
      end
    end

    out

  fun matchs (regexp: String, s: String, /*&optional*/start: USize = 0): String =>
    """
    """
    ""

  fun match_strings_all (regex: String, s: String): String =>
    """
    """
    ""

  fun matched_positions_all (regexp: String, string: String, /*&optional*/subexp_depth: USize): String =>
    """
    """
    ""

  fun slice_at (regexp: String, s: String): String =>
    """
    """
    ""

  fun split (separator: String, s: String, /*&optional*/omit_nulls: String): String =>
    """
    """
    ""

  fun split_up_to (separator: String, s: String, n: USize, /*&optional*/omit_nulls: String): String =>
    """
    """
    ""

  fun join (separator: String, strings: Array[String]): String =>
    """
    """
    ""


  // Predicates
  fun equals (s1: String, s2: String): String =>
    """
    """
    ""

  fun is_less (s1: String, s2: String): String =>
    """
    """
    ""

  fun is_matches (regexp: String, s: String, /*&optional*/start: USize): String =>
    """
    """
    ""

  fun is_blank (s: String): String =>
    """
    """
    ""

  fun is_present (s: String): String =>
    """
    """
    ""

  fun is_ends_with (suffix: String, s: String, /*&optional*/ignore_case: Bool =false): String =>
    """
    """
    ""

  fun is_starts_with (prefix: String, s: String, /*&optional*/ignore_case: Bool =false): String =>
    """
    """
    ""

  fun contains (needle: String, s: String, /*&optional*/ignore_case: Bool =false): String =>
    """
    """
    ""

  fun is_lowercase (s: String): String =>
    """
    """
    ""

  fun is_uppercase (s: String): String =>
    """
    """
    ""

  fun is_mixedcase (s: String): String =>
    """
    """
    ""

  fun is_capitalized (s: String): String =>
    """
    """
    ""

  fun is_numeric (s: String): String =>
    """
    """
    ""

  // The misc bucket
  fun replace (old_s: String, new_s: String, s: String): String =>
    """
    """
    ""

  fun replace_all (replacements: String, s: String): String =>
    """
    """
    ""

  fun lowercase (s: String): String =>
    """
    """
    ""

  fun uppercase (s: String): String =>
    """
    """
    ""

  fun capitalize (s: String): String =>
    """
    """
    ""

  fun titleize (s: String): String =>
    """
    """
    ""

  fun with2 (s: String, form: USize, /*&rest*/more: String =""): String =>
    """
    """
    ""

  fun index_of (needle: String, s: String, /*&optional*/ignore_case: Bool =false): String =>
    """
    """
    ""

  fun reverse (s: String): String =>
    """
    """
    ""

  fun presence (s: String): String =>
    """
    """
    ""

  // fun format (template: String, replacer: String, /*&optional*/extra: String): String =>
  fun format (template: String, replacer: Array[Any]): String =>
    """
    """
    // template
    // |> Str~replace("%1", replacer[0])
    ""

  fun lex_format (format_str: String): String =>
    """
    """
    ""

  fun count_matches (regexp: String, s: String, /*&optional*/start: USize, end': USize): String =>
    """
    """
    ""

  fun wrap (s: String, prefix: String, /*&optional*/suffix: String =""): String =>
    """
    """
    ""

  // Pertaining to words
  fun split_words (s: String): String =>
    """
    """
    ""

  fun lower_camel_case (s: String): String =>
    """
    """
    ""

  fun upper_camel_case (s: String): String =>
    """
    """
    ""

  fun snake_case (s: String): String =>
    """
    """
    ""

  fun dashed_words (s: String): String =>
    """
    """
    ""

  fun capitalized_words (s: String): String =>
    """
    """
    ""

  fun titleized_words (s: String): String =>
    """
    """
    ""

  fun word_initials (s: String): String =>
    """
    """
    ""

  // Version Info
  // example: 20200311 / 1.19.2
