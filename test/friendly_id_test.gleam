import friendly_id
import friendly_id/generator
import gleam/string
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn generate_test() {
  let generator = generator.new() |> generator.set_separator("_")
  let id = friendly_id.generate(generator)

  assert string.length(id) > 3
  assert string.contains(id, "_")
}
