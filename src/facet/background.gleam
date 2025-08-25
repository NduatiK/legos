import facet/element.{type Attr, type Attribute, type Color}
import facet/internal/flag
import facet/internal/model as internal
import gleam/float
import gleam/list
import gleam/string
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
  ToAngle(Float)
}

pub type Step {
  ColorStep(Color)
  PercentStep(Float, Color)
  PxStep(Int, Color)
}

/// Create a color step for gradients
pub fn step(color: Color) -> Step {
  ColorStep(color)
}

/// Create a percentage-based color step for gradients
pub fn percent(pct: Float, color: Color) -> Step {
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
pub fn gradient(angle: Float, steps: List(Color)) -> Attr(decorative, msg) {
  case steps {
    [] -> internal.NoAttribute
    [clr] ->
      internal.StyleClass(
        flag.bg_color(),
        internal.Colored(
          "bg-" <> internal.format_color_class(clr),
          "background-color",
          clr,
        ),
      )
    _ -> {
      let class_parts =
        [internal.float_class(angle)]
        |> list.append(list.map(steps, internal.format_color_class))
        |> string.join("-")

      let color_parts =
        list.map(steps, internal.format_color)
        |> list.prepend(float.to_string(angle) <> "rad")
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
