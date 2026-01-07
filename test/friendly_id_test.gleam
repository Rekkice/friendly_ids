import friendly_id
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
