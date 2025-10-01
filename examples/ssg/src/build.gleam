import gleam/io
import gleam/list
import gleam/string
import ssg as ssg_example

import lustre/ssg

pub fn main() {
  let build =
    ssg.new("./priv")
    |> ssg.add_static_route("/", ssg_example.layout(ssg_example.init(Nil)))
    |> ssg.build

  case build {
    Ok(_) -> io.println("Build succeeded!")
    Error(e) -> {
      io.println_error(string.inspect(e))
      io.println_error("Build failed!")
    }
  }
}
