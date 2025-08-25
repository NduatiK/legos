import facet/element.{type Color}
import facet/internal/flag
import facet/internal/model as internal
import facet/internal/style
import gleam/int
import gleam/pair

pub fn color(clr: Color) {
  internal.StyleClass(
    flag.border_color(),
    internal.Colored(
      "bc-" <> internal.format_color_class(clr),
      "border-color",
      clr,
    ),
  )
}

pub fn width(v) {
  internal.StyleClass(
    flag.border_width(),
    internal.BorderWidth("b-" <> int.to_string(v), v, v, v, v),
  )
}

pub fn width_xy(x: Int, y: Int) {
  internal.StyleClass(
    flag.border_width(),
    internal.BorderWidth(
      "b-" <> int.to_string(x) <> "-" <> int.to_string(y),
      y,
      x,
      y,
      x,
    ),
  )
}

pub type Widths {
  Widths(bottom: Int, left: Int, right: Int, top: Int)
}

pub fn width_each(w: Widths) {
  let Widths(bottom:, left:, right:, top:) = w
  case top == bottom && left == right {
    True ->
      case top == right {
        True -> width(top)
        False -> width_xy(left, top)
      }
    False ->
      internal.StyleClass(
        flag.border_width(),
        internal.BorderWidth(
          "b-"
            <> int.to_string(top)
            <> "-"
            <> int.to_string(right)
            <> "-"
            <> int.to_string(bottom)
            <> "-"
            <> int.to_string(left),
          top,
          right,
          bottom,
          left,
        ),
      )
  }
}

pub fn solid() {
  internal.Class(flag.border_style(), style.classes_border_solid)
}

pub fn dashed() {
  internal.Class(flag.border_style(), style.classes_border_dashed)
}

pub fn dotted() {
  internal.Class(flag.border_style(), style.classes_border_dotted)
}

pub fn rounded(radius: Int) {
  internal.StyleClass(
    flag.border_round(),
    internal.Single(
      "br-" <> int.to_string(radius),
      "border-radius",
      int.to_string(radius) <> "px",
    ),
  )
}

pub fn round_each(
  top_left: Int,
  top_right: Int,
  bottom_left: Int,
  bottom_right: Int,
) {
  internal.StyleClass(
    flag.border_round(),
    internal.Single(
      "br-"
        <> int.to_string(top_left)
        <> "-"
        <> int.to_string(top_right)
        <> "-"
        <> int.to_string(bottom_left)
        <> "-"
        <> int.to_string(bottom_right),
      "border-radius",
      int.to_string(top_left)
        <> "px "
        <> int.to_string(top_right)
        <> "px "
        <> int.to_string(bottom_right)
        <> "px "
        <> int.to_string(bottom_left)
        <> "px",
    ),
  )
}

pub fn shadow(almost_shade: internal.Shadow) {
  let shade =
    internal.InsetShadow(
      inset: False,
      offset: almost_shade.offset
        |> pair.map_first(int.to_float)
        |> pair.map_second(int.to_float),
      size: int.to_float(almost_shade.size),
      blur: int.to_float(almost_shade.blur),
      color: almost_shade.color,
    )

  internal.StyleClass(
    flag.shadows(),
    internal.Single(
      internal.box_shadow_class(shade),
      "box-shadow",
      internal.format_box_shadow(shade),
    ),
  )
}

pub fn inner_shadow(almost_shade: internal.Shadow) {
  let shade =
    internal.InsetShadow(
      inset: True,
      offset: almost_shade.offset
        |> pair.map_first(int.to_float)
        |> pair.map_second(int.to_float),
      size: int.to_float(almost_shade.size),
      blur: int.to_float(almost_shade.blur),
      color: almost_shade.color,
    )

  internal.StyleClass(
    flag.shadows(),
    internal.Single(
      internal.box_shadow_class(shade),
      "box-shadow",
      internal.format_box_shadow(shade),
    ),
  )
}
