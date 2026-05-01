import friendly_id
import gleam/list
import gleam/string
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn generate_test() {
  let generator = friendly_id.new_default_generator("_")
  let id = friendly_id.generate(generator)

  assert string.length(id) > 3
  assert string.contains(id, "_")
}

pub fn generate_format_test() {
  let generator = friendly_id.new_default_generator("-")
  let id = friendly_id.generate(generator)
  let parts = string.split(id, "-")

  // exactly predicate + object, both non-empty
  assert list.length(parts) == 2
  assert list.all(parts, fn(p) { string.length(p) > 0 })
}

pub fn generate_transform_test() {
  let generator = friendly_id.new_generator(string.uppercase, "_")
  let id = friendly_id.generate(generator)

  assert id == string.uppercase(id)
}

pub fn generate_empty_separator_test() {
  let generator = friendly_id.new_default_generator("")
  let id = friendly_id.generate(generator)

  assert string.length(id) > 0
  assert !string.contains(id, "_")
}
