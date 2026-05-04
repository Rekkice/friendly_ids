import friendly_id/words
import gleam/function
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
/// let generator = friendly_id.new_generator()
/// echo friendly_id.generate(generator)
/// ```
pub fn generate(generator: Generator) -> String {
  [take_random_element(generator.objects)]
  |> prepend_predicates(
    0,
    generator.predicate_count,
    generator.predicates,
  )
  |> list.map(generator.transform_fn)
  |> string.join(generator.separator)
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

// encoding
const offset: Int = 1337

pub type EncodingError {
  OutOfBounds
}

/// Encodes an int to a Friendly ID. This is a deterministic operation, which means an int will always return the same ID, and guarantees no collisions.
///
/// # Examples
///
/// ## Create a generator with defaults, then generate an ID by encoding an int
///
/// ```gleam
/// let generator = friendly_id.new_generator()
/// echo friendly_id.encode_int(generator, 23)
/// ```
pub fn encode_int(
  generator: Generator,
  id: Int,
) -> Result(String, EncodingError) {
  let max_id = encoder_max_int(generator)

  case id < 0 || id > max_id {
    True -> Error(OutOfBounds)
    False -> {
      let objects = generator.objects
      let predicates = generator.predicates

      let obj_count = glearray.length(objects)
      let pred_count = glearray.length(predicates)

      let raw_obj = id % obj_count
      let remaining_id = id / obj_count

      let raw_preds =
        extract_raw_indices(
          remaining_id,
          pred_count,
          generator.predicate_count,
          [],
        )

      let scrambled_obj =
        { raw_obj * generator.obj_multiplier + offset }
        % obj_count

      let #(_cascade, scrambled_preds) =
        list.map_fold(
          over: raw_preds,
          from: scrambled_obj,
          with: fn(cascade, raw_pred) {
            let scrambled_pred =
              {
                raw_pred
                * generator.pred_multiplier
                + offset
                + cascade
              }
              % pred_count

            #(scrambled_pred, scrambled_pred)
          },
        )

      let assert Ok(object_word) = glearray.get(objects, scrambled_obj)

      let pred_words =
        list.map(list.reverse(scrambled_preds), fn(idx) {
          let assert Ok(pred_word) = glearray.get(predicates, idx)
          pred_word
        })

      let parts = list.append(pred_words, [object_word])
      let transformed_parts =
        list.map(parts, generator.transform_fn)

      Ok(string.join(transformed_parts, generator.separator))
    }
  }
}

pub fn encoder_max_int(generator: Generator) -> Int {
  let obj_count = glearray.length(generator.objects)
  let pred_count = glearray.length(generator.predicates)

  let total_combinations =
    obj_count * int_power(pred_count, generator.predicate_count)

  total_combinations - 1
}

fn extract_raw_indices(
  remaining_id: Int,
  pred_count: Int,
  count_left: Int,
  acc: List(Int),
) -> List(Int) {
  case count_left <= 0 {
    True -> list.reverse(acc)
    False -> {
      let pred_index = remaining_id % pred_count
      let next_remaining = remaining_id / pred_count

      extract_raw_indices(next_remaining, pred_count, count_left - 1, [
        pred_index,
        ..acc
      ])
    }
  }
}

fn int_power(base: Int, exponent: Int) -> Int {
  int_power_loop(base, exponent, 1)
}

fn int_power_loop(base: Int, exponent: Int, acc: Int) -> Int {
  case exponent <= 0 {
    True -> acc
    False -> int_power_loop(base, exponent - 1, acc * base)
  }
}

// generator

/// This record contains the objects and predicates arrays, needed to generate a friendly ID.
/// Should only be initialized once, then passed as a dependency.
pub opaque type Generator {
  Generator(
    objects: glearray.Array(String),
    predicates: glearray.Array(String),
    predicate_count: Int,
    transform_fn: fn(String) -> String,
    separator: String,
    obj_multiplier: Int,
    pred_multiplier: Int,
  )
}

pub type GeneratorError {
  NegativePredicateCount
}

/// Create a `Generator` record with the following defaults:
/// - Predicate count: 1
/// - No separator
/// - No transformation
/// - Provided word lists
/// 
/// # Examples
/// 
/// ```gleam
/// let generator = friendly_id.new_generator()
/// ```
pub fn new_generator() -> Generator {
  let objects = words.get_objects()
  let predicates = words.get_predicates()
  let obj_multiplier = find_coprime(glearray.length(objects), 859)
  let pred_multiplier = find_coprime(glearray.length(predicates), 859)
  Generator(
    objects:,
    predicates:,
    predicate_count: 1,
    transform_fn: function.identity,
    separator: "",
    obj_multiplier:,
    pred_multiplier:,
  )
}

/// Create a `Generator` record with the word lists passed to it and the following defaults:
/// - Predicate count: 1
/// - No separator
/// - No transformation
/// 
/// # Examples
/// 
/// ```gleam
/// let objects = glearray.from_list(["apple, potato"])
/// let predicates = glearray.from_list(["brave, insightful"])
/// let generator = friendly_id.new_generator_with_words(objects:, predicates:)
/// ```
pub fn new_generator_with_words(
  objects objects: glearray.Array(String),
  predicates predicates: glearray.Array(String),
) -> Generator {
  let obj_multiplier = find_coprime(glearray.length(objects), 859)
  let pred_multiplier = find_coprime(glearray.length(predicates), 859)
  Generator(
    objects:,
    predicates:,
    predicate_count: 1,
    transform_fn: function.identity,
    separator: "",
    obj_multiplier:,
    pred_multiplier:,
  )
}

pub fn set_generator_predicate_count(
  generator: Generator,
  predicate_count: Int,
) -> Result(Generator, GeneratorError) {
  case predicate_count >= 0 {
    True -> Ok(Generator(..generator, predicate_count:))
    False -> Error(NegativePredicateCount)
  }
}

pub fn set_generator_transform_fn(
  generator: Generator,
  transform_fn: fn(String) -> String,
) -> Generator {
  Generator(..generator, transform_fn:)
}

pub fn set_generator_separator(generator: Generator, separator: String) -> Generator {
  Generator(..generator, separator:)
}

fn gcd(a: Int, b: Int) -> Int {
  case b == 0 {
    True -> a
    False -> gcd(b, a % b)
  }
}

fn find_coprime(length: Int, candidate: Int) -> Int {
  case gcd(length, candidate) == 1 {
    True -> candidate
    False -> find_coprime(length, candidate + 1)
  }
}
