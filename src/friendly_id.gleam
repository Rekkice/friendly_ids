import gleam/function
import gleam/int
import gleam/list
import gleam/string
import iv
import words

/// This record contains the objects and predicates arrays, needed to generate a friendly ID.
/// Should only be initialized once, then passed as a dependency.
pub type Generator {
  Generator(
    objects: iv.Array(String),
    predicates: iv.Array(String),
    generate: fn(Generator) -> String,
  )
}

/// Create a `Generator` record with no transform function.
///
/// # Examples
///
/// ## Create a generator with a "_" separator, then generate an ID
///
/// ```gleam
/// let generator = new_default_generator("_")
/// echo generator.generate(generator)
/// ```
pub fn new_default_generator(separator: String) {
  new_generator(function.identity, separator)
}

/// Create a `Generator` record with no transform function.
///
/// # Examples
///
/// ## Create a generator with an uppercase transform and a "_" separator, then generate an ID
///
/// ```gleam
/// let generator = new_generator(string.uppercase, "_")
/// echo generator.generate(generator)
/// ```
pub fn new_generator(
  transform_fn: fn(String) -> String,
  separator: String,
) -> Generator {
  Generator(
    objects: words.get_objects(),
    predicates: words.get_predicates(),
    generate: fn(generator: Generator) {
      [
        take_random_element(generator.predicates),
        take_random_element(generator.objects),
      ]
      |> list.map(transform_fn)
      |> string.join(separator)
    },
  )
}

fn take_random_element(array: iv.Array(value)) -> value {
  let index =
    iv.size(array)
    |> int.random()

  let assert Ok(element) = iv.get(from: array, at: index)
  element
}
