import friendly_id/generator
import gleam/list
import gleam/string
import glearray

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
/// let generator = generator.new()
/// echo encoding.encode_int(generator, 23)
/// ```
pub fn encode_int(
  generator: generator.Generator,
  id: Int,
) -> Result(String, EncodingError) {
  let max_id = encoder_max_int(generator)

  case id < 0 || id > max_id {
    True -> Error(OutOfBounds)
    False -> {
      let objects = generator.get_objects(generator)
      let predicates = generator.get_predicates(generator)

      let obj_count = glearray.length(objects)
      let pred_count = glearray.length(predicates)

      let raw_obj = id % obj_count
      let remaining_id = id / obj_count

      let raw_preds =
        extract_raw_indices(
          remaining_id,
          pred_count,
          generator.get_predicate_count(generator),
          [],
        )

      let scrambled_obj =
        { raw_obj * generator.get_obj_multiplier(generator) + offset }
        % obj_count

      let #(_cascade, scrambled_preds) =
        list.map_fold(
          over: raw_preds,
          from: scrambled_obj,
          with: fn(cascade, raw_pred) {
            let scrambled_pred =
              {
                raw_pred
                * generator.get_pred_multiplier(generator)
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
        list.map(parts, generator.get_transform_fn(generator))

      Ok(string.join(transformed_parts, generator.get_separator(generator)))
    }
  }
}

pub fn encoder_max_int(generator: generator.Generator) -> Int {
  let obj_count = glearray.length(generator.get_objects(generator))
  let pred_count = glearray.length(generator.get_predicates(generator))

  let total_combinations =
    obj_count * int_power(pred_count, generator.get_predicate_count(generator))

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
