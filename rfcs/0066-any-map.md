- Feature Name: any-map
- Start Date: 2020-04-27
- RFC PR: (leave this empty)
- Pony Issue: (leave this empty)

# Summary

Add a `AnyMap` primitive to `collections` package.

# Motivation

`AnyMap` primitive like `Map`, but it use a `lambda` for hash calculation. it can use the any type for Key.

# Detailed design

Copy the sort.pony, Removed the need for dependency on the `Hashable` and `Equatable` interfaces, and added a Lambda parameter to accomplish the same thing.

# How We Teach This

```pony
use "collections"

actor Main
  new create(env:Env) =>
    let map = AnyMap[U8, String]({(key: U8): USize => key.usize_unsafe()})
    map(1)="I"
    map(2)="love"
    map(3)="Pony"
````

# How We Test This


All test cases for `Map` are also valid for `AnyMap`.

Its design and implementation are already complete and working.
Source : https://github.com/damon-kwok/pony-shoe/blob/master/any_map.pony

# Drawbacks

The users need to ensure the correctness of hash calculation by self.

* Breaks existing code
* Introduces instability into the compiler and or runtime which will result in bugs we are going to spend time tracking down
* Maintenance cost of added code

# Alternatives

What other designs have been considered? What is the impact of not doing this?
None is not an acceptable answer. There is always to option of not implementing the RFC.

# Unresolved questions

None.
