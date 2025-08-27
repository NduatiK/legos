import gleam/float
import gleam/int
import gleam/list
import gleam/string
import legos/element.{type Attr, type Attribute, type Color}
import legos/internal/flag
import legos/internal/model as internal
import lustre/attribute as attr

/// A background color attribute
pub fn color(clr: Color) -> Attr(decorative, msg) {
  internal.StyleClass(
    flag.bg_color(),
    internal.Colored(
      "bg-" <> internal.format_color_class(clr),
      "background-color",
      clr,
    ),
  )
}

/// Resize the image to fit the containing element while maintaining proportions and cropping the overflow.
pub fn image(src: String) -> Attribute(msg) {
  internal.Attr(attr.style(
    "background",
    "url(\"" <> src <> "\") center / cover no-repeat",
  ))
}

/// A centered background image that keeps its natural proportions, but scales to fit the space.
pub fn uncropped(src: String) -> Attribute(msg) {
  internal.Attr(attr.style(
    "background",
    "url(\"" <> src <> "\") center / contain no-repeat",
  ))
}

/// Tile an image in the x and y axes.
pub fn tiled(src: String) -> Attribute(msg) {
  internal.Attr(attr.style("background", "url(\"" <> src <> "\") repeat"))
}

/// Tile an image in the x axis.
pub fn tiled_x(src: String) -> Attribute(msg) {
  internal.Attr(attr.style("background", "url(\"" <> src <> "\") repeat-x"))
}

/// Tile an image in the y axis.
pub fn tiled_y(src: String) -> Attribute(msg) {
  internal.Attr(attr.style("background", "url(\"" <> src <> "\") repeat-y"))
}

pub type Direction {
  ToUp
  ToDown
  ToRight
  ToTopRight
  ToBottomRight
  ToLeft
  ToTopLeft
  ToBottomLeft
  ToRad(Float)
  ToDegrees(Int)
}

pub type Step {
  ColorStep(Color)
  PercentStep(Int, Color)
  PxStep(Int, Color)
}

/// Create a color step for gradients
pub fn step(color: Color) -> Step {
  ColorStep(color)
}

/// Create a percentage-based color step for gradients
pub fn percent(pct: Int, color: Color) -> Step {
  PercentStep(pct, color)
}

/// Create a pixel-based color step for gradients
pub fn px(pixels: Int, color: Color) -> Step {
  PxStep(pixels, color)
}

/// A linear gradient.
/// First you need to specify what direction the gradient is going by providing an angle in radians.
/// `0.0` is up and `pi` is down.
/// The colors will be evenly spaced.
pub fn gradient(
  direction: Direction,
  steps: List(Step),
) -> Attr(decorative, msg) {
  let to_bg_color = fn(clr) {
    internal.StyleClass(
      flag.bg_color(),
      internal.Colored(
        "bg-" <> internal.format_color_class(clr),
        "background-color",
        clr,
      ),
    )
  }
  case steps {
    [] -> internal.NoAttribute
    [ColorStep(clr)] -> to_bg_color(clr)
    [PercentStep(_, clr)] -> to_bg_color(clr)
    [PxStep(_, clr)] -> to_bg_color(clr)
    _ -> {
      let #(direction_class, direction_prop) = direction_class_prop(direction)
      let class_parts =
        [direction_class]
        |> list.append(
          list.map(steps, fn(step) {
            case step {
              ColorStep(clr) -> internal.format_color_class(clr)
              PercentStep(position, clr) ->
                internal.format_color_class(clr)
                <> "-"
                <> int.to_string(position)
                <> "-pct"
              PxStep(position, clr) ->
                internal.format_color_class(clr)
                <> "-"
                <> int.to_string(position)
                <> "-px"
            }
          }),
        )
        |> string.join("-")

      let color_parts =
        list.map(steps, fn(step) {
          case step {
            ColorStep(clr) -> internal.format_color(clr)
            PercentStep(position, clr) ->
              internal.format_color(clr)
              <> " "
              <> int.to_string(position)
              <> "%"
            PxStep(position, clr) ->
              internal.format_color(clr)
              <> " "
              <> int.to_string(position)
              <> "px"
          }
        })
        |> list.prepend(direction_prop)
        |> string.join(", ")

      internal.StyleClass(
        flag.bg_gradient(),
        internal.Single(
          "bg-grad-" <> class_parts,
          "background-image",
          "linear-gradient(" <> color_parts <> ")",
        ),
      )
    }
  }
}

fn direction_class_prop(direction) {
  case direction {
    ToUp -> #("to-up", "to up")
    ToDown -> #("to-down", "to down")
    ToRight -> #("to-right", "to right")
    ToTopRight -> #("to-top-right", "to top right")
    ToBottomRight -> #("to-bottom-right", "to bottom right")
    ToLeft -> #("to-left", "to left")
    ToTopLeft -> #("to-top-left", "to topleft")
    ToBottomLeft -> #("to-bottom-left", "to bottom left")
    ToRad(angle) -> #(
      internal.float_class(angle),
      float.to_string(angle) <> "rad",
    )
    ToDegrees(angle) -> #(
      internal.float_class(int.to_float(flip_angle(angle))),
      int.to_string(flip_angle(angle)) <> "deg",
    )
  }
}

fn flip_angle(angle) {
  case angle + 180 > 360 {
    True -> angle + 180 - 360
    False -> angle + 180
  }
}
