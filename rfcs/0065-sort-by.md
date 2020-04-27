- Feature Name: sort-by
- Start Date: 2020-04-27
- RFC PR: (leave this empty)
- Pony Issue: (leave this empty)

# Summary

Add a `SortBy` primitive to `collections` package.

# Motivation

`SortBy` primitive like `Sort`, but it use a `lambda` replaced `interface Comparable`. it can use the any type for Key.

# Detailed design

Copy the sort.pony, Removed the need for dependency on the `Comparable` interface, and added a Lambda parameter to accomplish the same thing.

# How We Teach This

```pony
use "collections"

actor Main
  new create(env:Env) =>
    let array = [ "aa"; "aaa"; "a" ]
    SortBy(array, {(x: String):USize => x.size()})
    for e in array.values() do
      env.out.print(e) // prints "a \n aa \n aaa"
    end
````

# How We Test This

All test cases for `Sort` are also valid for `SortBy`. Its design and implementation are already complete and working.
Source : https://github.com/damon-kwok/pony-shoe/blob/master/any_map.pony

# Drawbacks

The user must ensure that the lambda evaluation function is valid.

# Alternatives

It can be used as a third-party library, provided to users through the package manager.

# Unresolved questions

None.
