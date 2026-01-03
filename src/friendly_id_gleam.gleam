import gleam/function
import gleam/int
import gleam/list
import gleam/string
import iv
import words

pub type Generator {
  Generator(
    objects: iv.Array(String),
    predicates: iv.Array(String),
    generate: fn(Generator) -> String,
  )
}

pub type GeneratorError {
  FileError
}

pub fn new_default_generator(separator: String) {
  new_generator(function.identity, separator)
}

pub fn new_generator(
  transform_fn: fn(String) -> String,
  separator: String,
) -> Result(Generator, GeneratorError) {
  case words.get_objects(), words.get_predicates() {
    Ok(objects), Ok(predicates) ->
      Generator(objects:, predicates:, generate: fn(generator: Generator) {
        [
          take_random_element(generator.predicates),
          take_random_element(generator.objects),
        ]
        |> list.map(transform_fn)
        |> string.join(separator)
      })
      |> Ok()

    _, _ -> Error(FileError)
  }
}

fn take_random_element(array: iv.Array(value)) -> value {
  let index =
    iv.size(array)
    |> int.random()

  let assert Ok(element) = iv.get(from: array, at: index)
  element
}
