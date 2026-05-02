import friendly_id/generator
import gleam/int
import gleam/list
import gleam/string
import glearray

/// Generates a friendly ID from a Generator record.
///
/// # Examples
///
/// ## Create a generator with defaults, then generate an ID
///
/// ```gleam
/// let generator = generator.new()
/// echo friendly_id.generate(generator)
/// ```
pub fn generate(generator: generator.Generator) -> String {
  [take_random_element(generator.get_objects(generator))]
  |> prepend_predicates(
    0,
    generator.get_predicate_count(generator),
    generator.get_predicates(generator),
  )
  |> list.map(generator.get_transform_fn(generator))
  |> string.join(generator.get_separator(generator))
}

fn take_random_element(array: glearray.Array(value)) -> value {
  let index =
    glearray.length(array)
    |> int.random()

  let assert Ok(element) = glearray.get(in: array, at: index)
  element
}

fn prepend_predicates(
  acc: List(String),
  count: Int,
  max: Int,
  predicates: glearray.Array(String),
) -> List(String) {
  case count == max {
    True -> acc
    False -> {
      prepend_predicates(
        [take_random_element(predicates), ..acc],
        count + 1,
        max,
        predicates,
      )
    }
  }
}
