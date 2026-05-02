import friendly_id/words
import gleam/function
import glearray

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
/// let generator = generator.new()
/// ```
pub fn new() -> Generator {
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
/// let generator = generator.new_with_words(objects:, predicates:)
/// ```
pub fn new_with_words(
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

pub fn get_predicates(generator: Generator) -> glearray.Array(String) {
  generator.predicates
}

pub fn get_objects(generator: Generator) -> glearray.Array(String) {
  generator.objects
}

pub fn get_predicate_count(generator: Generator) -> Int {
  generator.predicate_count
}

pub fn get_obj_multiplier(generator: Generator) -> Int {
  generator.obj_multiplier
}

pub fn get_pred_multiplier(generator: Generator) -> Int {
  generator.pred_multiplier
}

pub fn get_transform_fn(generator: Generator) -> fn(String) -> String {
  generator.transform_fn
}

pub fn get_separator(generator: Generator) -> String {
  generator.separator
}

pub fn set_predicate_count(
  generator: Generator,
  predicate_count: Int,
) -> Result(Generator, GeneratorError) {
  case predicate_count >= 0 {
    True -> Ok(Generator(..generator, predicate_count:))
    False -> Error(NegativePredicateCount)
  }
}

pub fn set_transform_fn(
  generator: Generator,
  transform_fn: fn(String) -> String,
) -> Generator {
  Generator(..generator, transform_fn:)
}

pub fn set_separator(generator: Generator, separator: String) -> Generator {
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
