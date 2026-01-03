import gleam/list
import gleam/string
import iv
import simplifile

pub fn get_objects() -> Result(iv.Array(String), simplifile.FileError) {
  get_words("priv/objects.txt")
}

pub fn get_predicates() -> Result(iv.Array(String), simplifile.FileError) {
  get_words("priv/predicates.txt")
}

fn get_words(path: String) -> Result(iv.Array(String), simplifile.FileError) {
  case simplifile.read(path) {
    Ok(content) ->
      content
      |> string.split("\n")
      |> list.map(string.trim)
      |> iv.from_list()
      |> Ok()

    Error(error) -> Error(error)
  }
}
