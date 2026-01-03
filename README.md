# friendly_id

[![Package Version](https://img.shields.io/hexpm/v/friendly_id)](https://hex.pm/packages/friendly_id)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/friendly_id/)

A port of [FriendlyID](https://github.com/Miserlou/FriendlyID) to Gleam! This package creates human-readable, friendly identifiers.

For example, instead of using:

`https://chat.room/r/7051d892-7d9d-4d38-b718-1f22f5b52d70`

You can create something like:

`https://chat.room/r/ShinyPenguin`

Which makes the URL easier to share.

Words come from the [Glitch Project](https://github.com/glitchdotcom/friendly-words) and are curated to be inoffensive, safe for work and safe for children.

There's 3064 objects and 1450 predicates, which means there's 4,442,800 possible combinations.

```sh
gleam add friendly_id@1
```

```gleam
import friendly_id
import gleam/string

pub fn main() {
  let generator = friendly_id.new_generator(string.capitalize, "_")
  echo generator.generate(generator)
}
```
```
"Recondite-Leader"
```

Further documentation can be found at <https://hexdocs.pm/friendly_id>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
