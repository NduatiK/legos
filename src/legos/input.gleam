import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import legos/background
import legos/border
import legos/color.{rgb, rgba, white}
import legos/events
import legos/font
import legos/internal/flag
import legos/internal/model as internal
import legos/internal/style
import legos/region
import legos/ui.{
  type Attribute, type Element, fill, height, none, pointer, shrink, width,
}
import lustre/attribute
import lustre/element/html
import lustre/event

// PLACEHOLDER -----------------------------------------------------------------

pub type Placeholder(msg) {
  Placeholder(attrs: List(Attribute(msg)), content: Element(msg))
}

/// Create a placeholder for text inputs
pub fn placeholder(
  attrs: List(Attribute(msg)),
  content: Element(msg),
) -> Placeholder(msg) {
  Placeholder(attrs: attrs, content: content)
}

// LABELS ----------------------------------------------------------------------

pub type LabelLocation {
  OnRight
  OnLeft
  Above
  Below
}

pub type Label(msg) {
  Label(
    location: LabelLocation,
    attrs: List(Attribute(msg)),
    content: Element(msg),
  )
  HiddenLabel(text: String)
}

/// Create a label positioned to the right
pub fn label_right(
  attrs: List(Attribute(msg)),
  content: Element(msg),
) -> Label(msg) {
  Label(OnRight, attrs, content)
}

/// Create a label positioned to the left
pub fn label_left(
  attrs: List(Attribute(msg)),
  content: Element(msg),
) -> Label(msg) {
  Label(OnLeft, attrs, content)
}

/// Create a label positioned above
pub fn label_above(
  attrs: List(Attribute(msg)),
  content: Element(msg),
) -> Label(msg) {
  Label(Above, attrs, content)
}

/// Create a label positioned below
pub fn label_below(
  attrs: List(Attribute(msg)),
  content: Element(msg),
) -> Label(msg) {
  Label(Below, attrs, content)
}

/// Create a hidden label for accessibility (screen readers only)
pub fn label_hidden(text: String) -> Label(msg) {
  HiddenLabel(text)
}

fn is_stacked(label: Label(msg)) -> Bool {
  case label {
    Label(OnRight, _, _) -> False
    Label(OnLeft, _, _) -> False
    Label(Above, _, _) -> True
    Label(Below, _, _) -> True
    HiddenLabel(_) -> True
  }
}

fn hidden_label_attribute(label: Label(msg)) -> Attribute(msg) {
  case label {
    HiddenLabel(text_label) -> internal.Describe(internal.Label(text_label))
    Label(_, _, _) -> internal.NoAttribute
  }
}

// BUTTON ----------------------------------------------------------------------

/// Create a button element
pub fn button(
  attrs: List(Attribute(msg)),
  on_press on_press: Option(msg),
  label label: Element(msg),
) -> Element(msg) {
  internal.element(
    internal.AsEl,
    internal.div,
    [
      width(shrink()),
      height(shrink()),
      internal.html_class(
        style.classes_content_center_x
        <> " "
        <> style.classes_content_center_y
        <> " "
        <> style.classes_se_button
        <> " "
        <> style.classes_no_text_selection,
      ),
      pointer(),
      focus_default(attrs),
      internal.Describe(internal.Button),
      internal.Attr(attribute.tabindex(0)),
      ..case on_press {
        None -> [internal.Attr(attribute.disabled(True)), ..attrs]
        Some(msg) -> [
          events.on_click(msg),
          on_key_lookup(msg, fn(code) {
            case code {
              c if c == enter -> Some(msg)
              c if c == space -> Some(msg)
              _ -> None
            }
          }),
          ..attrs
        ]
      }
    ],
    internal.Unkeyed([label]),
  )
}

fn focus_default(attrs: List(Attribute(msg))) -> Attribute(msg) {
  case list.any(attrs, has_focus_style) {
    True -> internal.NoAttribute
    False -> internal.html_class("focusable")
  }
}

fn has_focus_style(attr: Attribute(msg)) -> Bool {
  case attr {
    internal.StyleClass(_, internal.PseudoSelector(internal.Focus, _)) -> True
    _ -> False
  }
}

// CHECKBOX --------------------------------------------------------------------

/// Create a checkbox input
pub fn checkbox(
  attrs: List(Attribute(msg)),
  on_change on_change: fn(Bool) -> msg,
  icon icon: fn(Bool) -> Element(msg),
  checked checked: Bool,
  label label: Label(msg),
) -> Element(msg) {
  let attributes = [
    case is_hidden_label(label) {
      True -> internal.NoAttribute
      False -> ui.spacing(6)
    },
    events.on_click(on_change(!checked)),
    region.announce(),
    on_key_lookup(on_change(True), fn(code) {
      case code {
        c if c == enter -> Some(on_change(!checked))
        c if c == space -> Some(on_change(!checked))
        _ -> None
      }
    }),
    tab_index(0),
    pointer(),
    ui.align_left(),
    width(fill()),
    ..attrs
  ]

  apply_label(
    [
      internal.Attr(attribute.role("checkbox")),
      internal.Attr(
        attribute.aria_checked(case checked {
          True -> "true"
          False -> "false"
        }),
      ),
      hidden_label_attribute(label),
      ..attributes
    ],
    label,
    internal.element(
      internal.AsEl,
      internal.div,
      [
        ui.center_y(),
        height(fill()),
        width(shrink()),
      ],
      internal.Unkeyed([icon(checked)]),
    ),
  )
}

/// Default checkbox icon
// pub fn default_checkbox(checked: Bool) -> Element(msg) {
//   ui.el(
//     [
//       internal.html_class("focusable"),
//       width(ui.px(14)),
//       height(ui.px(14)),
//       background.color(white()),
//       border.rounded(3),
//       ui.center_y(),
//       border.width(case checked {
//         True -> 5
//         False -> 1
//       }),
//       border.color(case checked {
//         True -> rgb(59.0 /. 255.0, 153.0 /. 255.0, 252.0 /. 255.0)
//         False -> rgb(208.0 /. 255.0, 208.0 /. 255.0, 208.0 /. 255.0)
//       }),
//     ],
//     none,
//   )
// }

pub fn default_checkbox(checked: Bool) -> Element(msg) {
  ui.el(
    [
      internal.html_class("focusable"),
      ui.width(ui.px(14)),
      ui.height(ui.px(14)),
      font.color(white()),
      ui.center_y(),
      font.size(9),
      font.center(),
      border.rounded(3),
      border.color(case checked {
        True -> color.rgb(59.0 /. 255.0, 153.0 /. 255.0, 252.0 /. 255.0)

        False -> color.rgb(211.0 /. 255.0, 211.0 /. 255.0, 211.0 /. 255.0)
      }),
      border.shadow(offset: #(0, 0), blur: 1, size: 1, color: case checked {
        True -> color.rgba(238.0 /. 255.0, 238.0 /. 255.0, 238.0 /. 255.0, 0.0)

        False -> color.rgb(238.0 /. 255.0, 238.0 /. 255.0, 238.0 /. 255.0)
      }),
      background.color(case checked {
        True -> color.rgb(59.0 /. 255.0, 153.0 /. 255.0, 252.0 /. 255.0)

        False -> white()
      }),
      border.width(case checked {
        True -> 0
        False -> 1
      }),
      ui.in_front(ui.el(
        [
          border.color(white()),
          ui.height(ui.px(6)),
          ui.width(ui.px(9)),
          ui.rotate(-45.0),
          ui.center_x(),
          ui.center_y(),
          ui.move_up(1.0),
          ui.transparent(!checked),
          border.width_each(top: 0, left: 2, bottom: 2, right: 0),
        ],
        none,
      )),
    ],
    none,
  )
}

// TEXT INPUTS -----------------------------------------------------------------
type TextKind {
  TextInputNode(String)
  TextArea
}

type TextInput {
  TextInput(type_: TextKind, spellchecked: Bool, autofill: Option(String))
}

pub type TextConfig(msg) {
  TextConfig(
    on_change: fn(String) -> msg,
    text: String,
    placeholder: Option(Placeholder(msg)),
    label: Label(msg),
  )
}

/// Create a basic text input
pub fn text_input(
  attrs: List(Attribute(msg)),
  on_change on_change: fn(String) -> msg,
  text text: String,
  placeholder placeholder: Option(Placeholder(msg)),
  label label: Label(msg),
) -> Element(msg) {
  text_helper(
    TextInput(type_: TextInputNode("text"), spellchecked: False, autofill: None),
    attrs,
    on_change:,
    text:,
    placeholder:,
    label:,
  )
}

/// Create a spell-checked text input
pub fn spell_checked(
  attrs: List(Attribute(msg)),
  on_change on_change: fn(String) -> msg,
  text text: String,
  placeholder placeholder: Option(Placeholder(msg)),
  label label: Label(msg),
) -> Element(msg) {
  text_helper(
    TextInput(type_: TextInputNode("text"), spellchecked: True, autofill: None),
    attrs,
    on_change:,
    text:,
    placeholder:,
    label:,
  )
}

/// Create a search input
pub fn search(
  attrs: List(Attribute(msg)),
  on_change on_change: fn(String) -> msg,
  text text: String,
  placeholder placeholder: Option(Placeholder(msg)),
  label label: Label(msg),
) -> Element(msg) {
  text_helper(
    TextInput(
      type_: TextInputNode("search"),
      spellchecked: False,
      autofill: None,
    ),
    attrs,
    on_change:,
    text:,
    placeholder:,
    label:,
  )
}

/// Create a username input
pub fn username(
  attrs: List(Attribute(msg)),
  on_change on_change: fn(String) -> msg,
  text text: String,
  placeholder placeholder: Option(Placeholder(msg)),
  label label: Label(msg),
) -> Element(msg) {
  text_helper(
    TextInput(
      type_: TextInputNode("text"),
      spellchecked: False,
      autofill: Some("username"),
    ),
    attrs,
    on_change:,
    text:,
    placeholder:,
    label:,
  )
}

/// Create an email input
pub fn email(
  attrs: List(Attribute(msg)),
  on_change on_change: fn(String) -> msg,
  text text: String,
  placeholder placeholder: Option(Placeholder(msg)),
  label label: Label(msg),
) -> Element(msg) {
  text_helper(
    TextInput(
      type_: TextInputNode("email"),
      spellchecked: False,
      autofill: Some("email"),
    ),
    attrs,
    on_change:,
    text:,
    placeholder:,
    label:,
  )
}

/// Create a new password input
pub fn new_password(
  attrs: List(Attribute(msg)),
  on_change on_change: fn(String) -> msg,
  text text_val: String,
  placeholder placeholder_val: Option(Placeholder(msg)),
  label label_val: Label(msg),
  show show: Bool,
) -> Element(msg) {
  text_helper(
    TextInput(
      type_: TextInputNode(case show {
        True -> "text"
        False -> "password"
      }),
      spellchecked: False,
      autofill: Some("new-password"),
    ),
    attrs,
    on_change:,
    text: text_val,
    placeholder: placeholder_val,
    label: label_val,
  )
}

/// Create a current password input
pub fn current_password(
  attrs: List(Attribute(msg)),
  on_change on_change: fn(String) -> msg,
  text text_val: String,
  placeholder placeholder_val: Option(Placeholder(msg)),
  label label_val: Label(msg),
  show show: Bool,
) -> Element(msg) {
  text_helper(
    TextInput(
      type_: TextInputNode(case show {
        True -> "text"
        False -> "password"
      }),
      spellchecked: False,
      autofill: Some("current-password"),
    ),
    attrs,
    on_change: on_change,
    text: text_val,
    placeholder: placeholder_val,
    label: label_val,
  )
}

/// Create a multiline text input (textarea)
pub fn multiline(
  attrs: List(Attribute(msg)),
  on_change on_change: fn(String) -> msg,
  text text_val: String,
  placeholder placeholder_val: Option(Placeholder(msg)),
  label label_val: Label(msg),
  spellcheck spellcheck_val: Bool,
) -> Element(msg) {
  text_helper(
    TextInput(type_: TextArea, spellchecked: spellcheck_val, autofill: None),
    attrs,
    on_change: on_change,
    text: text_val,
    placeholder: placeholder_val,
    label: label_val,
  )
}

// RADIO BUTTONS ---------------------------------------------------------------

pub type OptionState {
  Idle
  Focused
  Selected
}

pub type RadioOption(value, msg) {
  RadioOption(value: value, view: fn(OptionState) -> Element(msg))
}

/// Create a radio option with default styling
pub fn option(value: value, content: Element(msg)) -> RadioOption(value, msg) {
  RadioOption(value, default_radio_option(content))
}

/// Create a radio option with custom styling
pub fn option_with(
  value: value,
  view: fn(OptionState) -> Element(msg),
) -> RadioOption(value, msg) {
  RadioOption(value, view)
}

/// Create a radio button group (column layout)
pub fn radio(
  attrs: List(Attribute(msg)),
  on_change on_change: fn(option) -> msg,
  options options: List(RadioOption(option, msg)),
  selected selected: Option(option),
  label label: Label(msg),
) -> Element(msg) {
  radio_helper(Column, attrs, on_change:, options:, selected:, label:)
}

/// Create a radio button group (row layout)
pub fn radio_row(
  attrs: List(Attribute(msg)),
  on_change: fn(option) -> msg,
  options: List(RadioOption(option, msg)),
  selected: Option(option),
  label: Label(msg),
) -> Element(msg) {
  radio_helper(Row, attrs, on_change:, options:, selected:, label:)
}

// SLIDER ----------------------------------------------------------------------

pub type Thumb(a) {
  Thumb(attrs: List(Attribute(a)))
}

/// Create a slider thumb
pub fn thumb(attrs: List(Attribute(a))) -> Thumb(a) {
  Thumb(attrs)
}

/// Default slider thumb
pub fn default_thumb() -> Thumb(a) {
  Thumb([
    width(ui.px(16)),
    height(ui.px(16)),
    border.rounded(8),
    border.width(1),
    border.color(rgb(0.5, 0.5, 0.5)),
    background.color(white()),
  ])
}

/// A slider input, good for capturing float values.
///
/// Input.slider
/// [ Element.height (Element.px 30)
///
/// -- Here is where we're creating/styling the "track"
/// , Element.behindContent
///         (Element.el
/// [ Element.width Element.fill
/// , Element.height (Element.px 2)
/// , Element.centerY
/// , Background.color grey
/// , Border.rounded 2
/// ]
/// Element.none
///         )
/// ]
/// { on_change = AdjustValue
/// , label =
///         Input.labelAbove []
/// (text "My Slider Value")
/// , min = 0
/// , max = 75
/// , step = Nothing
/// , value = model.sliderValue
/// , thumb =
///         Input.defaultThumb
/// }
///
/// `Element.behindContent` is used to render the track of the slider. Without it, no track would be rendered. The `thumb` is the icon that you can move around.
///
/// The slider can be vertical or horizontal depending on the width/height of the slider.
///
/// - `height fill` and `width (px someWidth)` will cause the slider to be vertical.
/// - `height (px someHeight)` and `width (px someWidth)` where `someHeight` > `someWidth` will also do it.
/// - otherwise, the slider will be horizontal.
///
/// **Note** If you want a slider for an `Int` value:
///
/// - set `step` to be `Just 1`, or some other whole value
/// - `value = toFloat model.myInt`
/// - And finally, round the value before making a message `on_change = round >> AdjustValue`
///
pub fn slider(
  attributes: List(Attribute(msg)),
  on_change on_change: fn(Float) -> msg,
  label label_val: Label(msg),
  min min: Float,
  max max: Float,
  value value: Float,
  thumb thumb: Thumb(msg),
  step step: option.Option(Float),
) -> Element(msg) {
  let Thumb(thumb_attributes) = thumb

  let width = internal.get_width(thumb_attributes)

  let height = internal.get_height(thumb_attributes)

  let track_height = internal.get_height(attributes)

  let track_width = internal.get_width(attributes)

  let vertical = case track_width, track_height {
    None, None -> False

    Some(internal.Px(w)), Some(internal.Px(h)) -> h > w

    Some(internal.Px(_)), Some(internal.Fill(_)) -> True

    _, _ -> False
  }

  let spacing = internal.get_spacing(attributes, #(5, 5))
  let spacing_x = spacing.0
  let spacing_y = spacing.1

  let factor = { value -. min } /. { max -. min }

  let thumb_width_string = case width {
    None -> "20px"
    Some(internal.Px(px)) -> int.to_string(px) <> "px"
    _ -> "100%"
  }

  let thumb_height_string = case height {
    None -> "20px"
    Some(internal.Px(px)) -> int.to_string(px) <> "px"
    _ -> "100%"
  }

  let class_name = "thmb-" <> thumb_width_string <> "-" <> thumb_height_string

  let thumb_shadow_style = [
    internal.Property("width", thumb_width_string),
    internal.Property("height", thumb_height_string),
  ]

  let thumb = case vertical {
    True ->
      view_vertical_thumb(
        factor,
        list.append([internal.html_class("focusable-thumb")], thumb_attributes),
        track_width,
      )
    False ->
      view_horizontal_thumb(
        factor,
        [internal.html_class("focusable-thumb"), ..thumb_attributes],
        track_height,
      )
  }

  apply_label(
    list.flatten([
      case is_hidden_label(label_val) {
        True -> [internal.NoAttribute]
        False -> [ui.spacing_xy(spacing_x, spacing_y)]
      },
      [region.announce()],
      [
        ui.width(case track_width {
          None -> ui.fill()
          Some(internal.Px(_)) -> ui.shrink()
          Some(x) -> x
        }),
      ],
      [
        ui.height(case track_height {
          None -> ui.shrink()
          Some(internal.Px(_)) -> ui.shrink()
          Some(x) -> x
        }),
      ],
    ]),
    label_val,
    ui.row(
      [
        ui.width(option.unwrap(track_width, ui.fill())),
        ui.height(option.unwrap(track_height, ui.px(20))),
        ui.behind_content(ui.el([ui.alpha(0.0)], thumb)),
      ],
      [
        internal.element(
          internal.AsEl,
          internal.NodeName("input"),
          list.flatten([
            [hidden_label_attribute(label_val)],
            [
              internal.StyleClass(
                flag.active(),
                internal.Style(
                  "input[type=\"range\"]." <> class_name <> "::-moz-range-thumb",
                  thumb_shadow_style,
                ),
              ),
              internal.StyleClass(
                flag.hover(),
                internal.Style(
                  "input[type=\"range\"]."
                    <> class_name
                    <> "::-webkit-slider-thumb",
                  thumb_shadow_style,
                ),
              ),
              internal.StyleClass(
                flag.focus(),
                internal.Style(
                  "input[type=\"range\"]." <> class_name <> "::-ms-thumb",
                  thumb_shadow_style,
                ),
              ),
              internal.Attr(attribute.class(
                class_name <> " ui-slide-bar focusable-parent",
              )),
              events.on_input(fn(str) {
                case float.parse(str) {
                  Error(_) -> on_change(0.0)
                  Ok(val) -> on_change(val)
                }
              }),
              internal.Attr(attribute.type_("range")),
              internal.Attr(
                attribute.step(case step {
                  None -> "any"
                  Some(step) -> float.to_string(step)
                }),
              ),
              internal.Attr(attribute.min(float.to_string(min))),
              internal.Attr(attribute.max(float.to_string(max))),
              internal.Attr(attribute.value(float.to_string(value))),
              case vertical {
                True -> internal.Attr(attribute.attribute("orient", "vertical"))
                False -> internal.NoAttribute
              },
              ui.width(case vertical {
                True -> option.unwrap(track_height, ui.px(20))
                False -> option.unwrap(track_width, ui.fill())
              }),
              ui.height(case vertical {
                True -> option.unwrap(track_width, ui.fill())
                False -> option.unwrap(track_height, ui.px(20))
              }),
            ],
          ]),
          internal.Unkeyed([]),
        ),
        ui.el(
          list.flatten([
            [
              ui.width(option.unwrap(track_width, ui.fill())),
              ui.height(option.unwrap(track_height, ui.px(20))),
            ],
            attributes,
            [
              ui.behind_content(thumb),
            ],
          ]),
          ui.none,
        ),
      ],
    ),
  )
}

fn view_horizontal_thumb(
  factor: Float,
  thumb_attributes: List(Attribute(msg)),
  track_height: Option(internal.Length),
) -> Element(msg) {
  // track
  ui.row(
    [
      ui.height(option.unwrap(track_height, ui.fill())),
      ui.center_y(),
      ui.width(ui.fill()),
    ],
    [
      // leading_space
      ui.el(
        [
          ui.height(internal.Content),
          ui.width(ui.fill_portion(float.round(factor *. 10_000.0))),
        ],
        ui.none,
      ),
      // thumb
      ui.el([ui.center_y(), ..thumb_attributes], ui.none),
      // trailing_space
      ui.el(
        [
          ui.height(option.unwrap(track_height, ui.fill())),
          ui.width(
            ui.fill_portion(float.round(
              float.absolute_value(1.0 -. factor) *. 10_000.0,
            )),
          ),
        ],
        ui.none,
      ),
    ],
  )
}

fn view_vertical_thumb(
  factor: Float,
  thumb_attributes: List(Attribute(msg)),
  track_width: Option(internal.Length),
) -> Element(msg) {
  ui.column(
    [
      ui.height(ui.fill()),
      ui.width(option.unwrap(track_width, ui.fill())),
      ui.center_x(),
    ],
    [
      ui.el(
        [
          ui.height(
            ui.fill_portion(float.round(
              float.absolute_value(1.0 -. factor) *. 10_000.0,
            )),
          ),
        ],
        ui.none,
      ),
      ui.el([ui.center_x(), ..thumb_attributes], ui.none),
      ui.el(
        [ui.height(ui.fill_portion(float.round(factor *. 10_000.0)))],
        ui.none,
      ),
    ],
  )
}

// UTILITY FUNCTIONS -----------------------------------------------------------
pub type Box {
  Box(bottom: Int, left: Int, right: Int, top: Int)
}

fn text_helper(
  text_input: TextInput,
  attrs: List(Attribute(msg)),
  on_change on_change: fn(String) -> msg,
  text text_val: String,
  placeholder placeholder: Option(Placeholder(msg)),
  label label_val: Label(msg),
) -> Element(msg) {
  let with_defaults = list.append(default_text_box_style(), attrs)
  let redistributed =
    redistribute(
      text_input.type_ == TextArea,
      is_stacked(label_val),
      with_defaults,
    )

  // let only_spacing = fn(attr) {
  //   case attr {
  //     internal.StyleClass(_, internal.SpacingStyle(_, _, _)) -> True
  //     _ -> False
  //   }
  // }

  let get_padding = fn(attr) {
    case attr {
      internal.StyleClass(_cls, internal.PaddingStyle(_pad, t, r, b, l)) ->
        // -- The - 3 is here to prevent accidental triggering of scrollbars
        // -- when things are off by a pixel or two.
        // -- (or at least when the browser *thinks* it's off by a pixel or two)
        Ok(Box(
          top: int.max(0, float.round(float.floor(t -. 3.0))),
          right: int.max(0, float.round(float.floor(r -. 3.0))),
          bottom: int.max(0, float.round(float.floor(b -. 3.0))),
          left: int.max(0, float.round(float.floor(l -. 3.0))),
        ))

      _ -> Error(Nil)
    }
  }
  let height_constrained = case text_input.type_ {
    TextInputNode(_) -> False
    TextArea ->
      with_defaults
      |> list.filter_map(get_height)
      |> list.reverse
      |> list.first()
      |> result.map(is_constrained)
      |> result.unwrap(False)
  }
  let parent_padding =
    with_defaults
    |> list.filter_map(get_padding)
    |> list.reverse
    |> list.first
    |> result.unwrap(Box(top: 0, right: 0, bottom: 0, left: 0))

  let input_element =
    internal.element(
      internal.AsEl,
      case text_input.type_ {
        TextInputNode(_input_type) -> internal.NodeName("input")
        TextArea -> internal.NodeName("textarea")
      },
      list.flatten([
        case text_input.type_ {
          TextInputNode(input_type) ->
            // -- Note: Due to a weird edgecase in...Edge...
            // -- `type` needs to come _before_ `value`
            // -- More reading: https://github.com/mdgriffith/elm-ui/pull/94/commits/4f493a27001ccc3cf1f2baa82e092c35d3811876
            [
              internal.Attr(attribute.type_(input_type)),
              internal.html_class(style.classes_input_text),
            ]

          TextArea -> [
            ui.clip(),
            ui.height(ui.fill()),
            internal.html_class(style.classes_input_multiline),
            calc_move_to_compensate_for_padding(with_defaults),

            // -- The only reason we do this padding trick is so that when the user clicks in the padding,
            // -- that the cursor will reset correctly.
            // -- This could probably be combined with the above `calc_move_to_compensate_for_padding`
            ui.padding_each(
              top: parent_padding.top,
              left: parent_padding.left,
              bottom: parent_padding.bottom,
              right: parent_padding.right,
            ),
            internal.Attr(attribute.style(
              "margin",
              render_box(negate_box(parent_padding)),
            )),
            internal.Attr(attribute.style("box-sizing", "content-box")),
          ]
        },
        [
          internal.Attr(attribute.value(text_val)),
          internal.Attr(event.on_input(on_change)),
          hidden_label_attribute(label_val),
          internal.Attr(attribute.spellcheck(text_input.spellchecked)),
          case text_input.autofill {
            Some(value) -> internal.Attr(attribute.autocomplete(value))
            None -> internal.NoAttribute
          },
        ],
        redistributed.input,
      ]),
      internal.Unkeyed([]),
    )
  let wrapped_input = case text_input.type_ {
    TextArea ->
      // -- textarea with height-content means that
      // -- the input element is rendered `inFront` with a transparent background
      // -- Then the input text is rendered as the space filling ui.
      internal.element(
        internal.AsEl,
        internal.div,
        [
          ui.width(ui.fill()),
          case list.any(with_defaults, has_focus_style) {
            True -> internal.NoAttribute
            False -> internal.html_class(style.classes_focused_within)
          },

          internal.html_class(style.classes_input_multiline_wrapper),
          ..redistributed.parent
        ]
          |> fn(a) {
            case height_constrained {
              True -> [ui.scrollbar_y(), ..a]
              False -> a
            }
          },
        internal.Unkeyed([
          internal.element(
            internal.AsParagraph,
            internal.div,
            [
              ui.width(ui.fill()),
              ui.height(ui.fill()),
              ui.in_front(input_element),
              internal.html_class(style.classes_input_multiline_parent),
              ..redistributed.wrapper
            ],
            internal.Unkeyed(case text_val == "" {
              True ->
                case placeholder {
                  None ->
                    // -- Without this, firefox will make the text area lose focus
                    // -- if the input is empty and you mash the keyboard
                    [ui.text("\u{00A0}")]

                  Some(place) -> [render_placeholder(place, [], True)]
                }

              False -> [
                internal.unstyled(
                  html.span(
                    [attribute.class(style.classes_input_multiline_filler)],
                    [
                      html.text(text_val <> "\u{00A0}"),
                    ],
                  ),
                ),
              ]
            }),
          ),
        ]),
      )

    TextInputNode(_) ->
      internal.element(
        internal.AsEl,
        internal.div,
        [
          ui.width(ui.fill()),
          case list.any(with_defaults, has_focus_style) {
            True -> internal.NoAttribute
            False -> internal.html_class(style.classes_focused_within)
          },
          ..list.flatten([
            redistributed.parent,
            case placeholder {
              None -> []
              Some(place) -> [
                ui.behind_content(render_placeholder(
                  place,
                  redistributed.cover,
                  text_val == "",
                )),
              ]
            },
          ])
        ],
        internal.Unkeyed([input_element]),
      )
  }

  apply_label(
    [
      internal.Class(flag.cursor(), style.classes_cursor_text),
      case is_hidden_label(label_val) {
        True -> internal.NoAttribute
        False -> ui.spacing(5)
      },
      region.announce(),
      ..redistributed.full_parent
    ],
    label_val,
    wrapped_input,
  )
}

type Redistributed(msg) {
  Redistributed(
    full_parent: List(Attribute(msg)),
    parent: List(Attribute(msg)),
    wrapper: List(Attribute(msg)),
    input: List(Attribute(msg)),
    cover: List(Attribute(msg)),
  )
}

// {-| Given the list of attributes provided to `Input.multiline` or `Input.text`,
// redistribute them to the parent, the input, or the cover.

//   - fullParent -> Wrapper around label and input
//   - parent -> parent of wrapper
//   - wrapper -> the element that is here to take up space.
//   - cover -> things like placeholders or text areas which are layered on top of input.
//   - input -> actual input element

// -}
fn redistribute(
  is_multiline: Bool,
  stacked: Bool,
  attrs: List(Attribute(msg)),
) -> Redistributed(msg) {
  attrs
  |> list.fold(
    Redistributed(
      full_parent: [],
      parent: [],
      wrapper: [],
      input: [],
      cover: [],
    ),
    fn(attr, redist) { redistribute_over(is_multiline, stacked)(attr, redist) },
  )
  |> fn(redist: Redistributed(msg)) {
    Redistributed(
      parent: list.reverse(redist.parent),
      full_parent: list.reverse(redist.full_parent),
      wrapper: list.reverse(redist.wrapper),
      input: list.reverse(redist.input),
      cover: list.reverse(redist.cover),
    )
  }
}

// {-| isStacked means that the label is above or below
// -}
fn redistribute_over(
  is_multiline: Bool,
  stacked: Bool,
) -> fn(Redistributed(msg), Attribute(msg)) -> Redistributed(msg) {
  fn(els: Redistributed(msg), attr: Attribute(msg)) {
    case attr {
      internal.Nearby(_, _) ->
        Redistributed(
          full_parent: els.full_parent,
          parent: [attr, ..els.parent],
          wrapper: els.wrapper,
          input: els.input,
          cover: els.cover,
        )

      internal.Width(width) ->
        case is_fill(width) {
          True ->
            Redistributed(
              full_parent: [attr, ..els.full_parent],
              parent: [attr, ..els.parent],
              wrapper: els.wrapper,
              input: [attr, ..els.input],
              cover: els.cover,
            )

          False ->
            case stacked {
              True ->
                Redistributed(
                  full_parent: [attr, ..els.full_parent],
                  parent: els.parent,
                  wrapper: els.wrapper,
                  input: els.input,
                  cover: els.cover,
                )

              False ->
                Redistributed(
                  full_parent: els.full_parent,
                  parent: [attr, ..els.parent],
                  wrapper: els.wrapper,
                  input: els.input,
                  cover: els.cover,
                )
            }
        }

      internal.Height(height) ->
        case stacked {
          False ->
            Redistributed(
              full_parent: [attr, ..els.full_parent],
              parent: [attr, ..els.parent],
              wrapper: els.wrapper,
              input: els.input,
              cover: els.cover,
            )

          True ->
            case is_fill(height) {
              True ->
                Redistributed(
                  full_parent: [attr, ..els.full_parent],
                  parent: [attr, ..els.parent],
                  wrapper: els.wrapper,
                  input: els.input,
                  cover: els.cover,
                )

              False ->
                // case is_pixel(height) {
                //   True ->
                Redistributed(
                  full_parent: els.full_parent,
                  parent: [attr, ..els.parent],
                  wrapper: els.wrapper,
                  input: els.input,
                  cover: els.cover,
                )
              //   False ->
              //     Redistributed(
              //       full_parent: els.full_parent,
              //       parent: [attr, ..els.parent],
              //       wrapper: els.wrapper,
              //       input: els.input,
              //       cover: els.cover,
              //     )
              // }
            }
        }

      internal.AlignX(_) ->
        Redistributed(
          full_parent: [attr, ..els.full_parent],
          parent: els.parent,
          wrapper: els.wrapper,
          input: els.input,
          cover: els.cover,
        )

      internal.AlignY(_) ->
        Redistributed(
          full_parent: [attr, ..els.full_parent],
          parent: els.parent,
          wrapper: els.wrapper,
          input: els.input,
          cover: els.cover,
        )

      internal.StyleClass(_, internal.SpacingStyle(_, _, _)) ->
        Redistributed(
          full_parent: [attr, ..els.full_parent],
          parent: [attr, ..els.parent],
          wrapper: [attr, ..els.wrapper],
          input: [attr, ..els.input],
          cover: els.cover,
        )

      internal.StyleClass(_cls, internal.PaddingStyle(_pad, t, r, b, l)) ->
        case is_multiline {
          True ->
            Redistributed(
              full_parent: els.full_parent,
              parent: [attr, ..els.parent],
              wrapper: els.wrapper,
              input: els.input,
              cover: [attr, ..els.cover],
            )

          False -> {
            let new_height =
              ui.html_attribute(attribute.style(
                "height",
                "calc(1.0em + "
                  <> float.to_string(2.0 *. float.min(t, b))
                  <> "px)",
              ))
            let new_line_height =
              ui.html_attribute(attribute.style(
                "line-height",
                "calc(1.0em + "
                  <> float.to_string(2.0 *. float.min(t, b))
                  <> "px)",
              ))
            let new_top = t -. float.min(t, b)
            let new_bottom = b -. float.min(t, b)
            let reduced_vertical_padding =
              internal.StyleClass(
                flag.padding(),
                internal.PaddingStyle(
                  internal.padding_name_float(new_top, r, new_bottom, l),
                  new_top,
                  r,
                  new_bottom,
                  l,
                ),
              )
            Redistributed(
              full_parent: els.full_parent,
              parent: [reduced_vertical_padding, ..els.parent],
              wrapper: els.wrapper,
              input: [new_height, new_line_height, ..els.input],
              cover: [attr, ..els.cover],
            )
          }
        }

      internal.StyleClass(_, internal.BorderWidth(_, _, _, _, _)) ->
        Redistributed(
          full_parent: els.full_parent,
          parent: [attr, ..els.parent],
          wrapper: els.wrapper,
          input: els.input,
          cover: [attr, ..els.cover],
        )

      internal.StyleClass(_, internal.Transform(_)) ->
        Redistributed(
          full_parent: els.full_parent,
          parent: [attr, ..els.parent],
          wrapper: els.wrapper,
          input: els.input,
          cover: [attr, ..els.cover],
        )

      internal.StyleClass(_, internal.FontSize(_)) ->
        Redistributed(
          full_parent: [attr, ..els.full_parent],
          parent: els.parent,
          wrapper: els.wrapper,
          input: els.input,
          cover: els.cover,
        )

      internal.StyleClass(_, internal.FontFamily(_, _)) ->
        Redistributed(
          full_parent: [attr, ..els.full_parent],
          parent: els.parent,
          wrapper: els.wrapper,
          input: els.input,
          cover: els.cover,
        )

      internal.StyleClass(_flag, _cls) ->
        Redistributed(
          full_parent: els.full_parent,
          parent: [attr, ..els.parent],
          wrapper: els.wrapper,
          input: els.input,
          cover: els.cover,
        )

      internal.NoAttribute -> els

      internal.Attr(_) ->
        Redistributed(
          full_parent: els.full_parent,
          parent: els.parent,
          wrapper: els.wrapper,
          input: [attr, ..els.input],
          cover: els.cover,
        )

      internal.Describe(_) ->
        Redistributed(
          full_parent: els.full_parent,
          parent: els.parent,
          wrapper: els.wrapper,
          input: [attr, ..els.input],
          cover: els.cover,
        )

      internal.Class(_, _) ->
        Redistributed(
          full_parent: els.full_parent,
          parent: [attr, ..els.parent],
          wrapper: els.wrapper,
          input: els.input,
          cover: els.cover,
        )

      internal.TransformComponent(_, _) ->
        Redistributed(
          full_parent: els.full_parent,
          parent: els.parent,
          wrapper: els.wrapper,
          input: [attr, ..els.input],
          cover: els.cover,
        )
    }
  }
}

fn is_fill(len: internal.Length) -> Bool {
  case len {
    internal.Fill(_) -> True
    internal.Content -> False
    internal.Px(_) -> False
    internal.Pct(_) -> False
    internal.ScreenPct(_) -> False
    internal.Min(_, l) -> is_fill(l)
    internal.Max(_, l) -> is_fill(l)
  }
}

// fn is_pixel(len: internal.Length) -> Bool {
//   case len {
//     internal.Content -> False
//     internal.Px(_) -> True
//     // TODO: Might be True
//     internal.Pct(_) -> False
//     // TODO: Might be True
//     internal.ScreenPct(_) -> False
//     internal.Fill(_) -> False
//     internal.Min(_, l) -> is_pixel(l)
//     internal.Max(_, l) -> is_pixel(l)
//   }
// }

fn apply_label(
  attrs: List(Attribute(msg)),
  label: Label(msg),
  input: Element(msg),
) -> Element(msg) {
  case label {
    HiddenLabel(_) ->
      internal.element(
        internal.AsColumn,
        internal.NodeName("label"),
        attrs,
        internal.Unkeyed([input]),
      )
    Label(position, label_attrs, label_child) -> {
      let label_element =
        internal.element(
          internal.AsEl,
          internal.div,
          label_attrs,
          internal.Unkeyed([label_child]),
        )

      case position {
        Above ->
          internal.element(
            internal.AsColumn,
            internal.NodeName("label"),
            [internal.html_class(style.classes_input_label), ..attrs],
            internal.Unkeyed([label_element, input]),
          )
        Below ->
          internal.element(
            internal.AsColumn,
            internal.NodeName("label"),
            [internal.html_class(style.classes_input_label), ..attrs],
            internal.Unkeyed([input, label_element]),
          )
        OnRight ->
          internal.element(
            internal.AsRow,
            internal.NodeName("label"),
            [internal.html_class(style.classes_input_label), ..attrs],
            internal.Unkeyed([input, label_element]),
          )
        OnLeft ->
          internal.element(
            internal.AsRow,
            internal.NodeName("label"),
            [internal.html_class(style.classes_input_label), ..attrs],
            internal.Unkeyed([label_element, input]),
          )
      }
    }
  }
}

fn is_hidden_label(label: Label(msg)) -> Bool {
  case label {
    HiddenLabel(_) -> True
    _ -> False
  }
}

type Orientation {
  Row
  Column
}

fn radio_helper(
  orientation: Orientation,
  attrs: List(Attribute(msg)),
  on_change on_change: fn(option) -> msg,
  options options: List(RadioOption(option, msg)),
  selected selected: Option(option),
  label label: Label(msg),
) -> Element(msg) {
  let render_option = fn(radio_option: RadioOption(option, msg)) {
    let RadioOption(value: val, view: view) = radio_option
    let status = case selected {
      Some(sel) if sel == val -> Selected
      _ -> Idle
    }

    ui.el(
      [
        pointer(),
        case orientation {
          Row -> width(shrink())
          Column -> width(fill())
        },
        events.on_click(on_change(val)),
        internal.Attr(
          attribute.aria_checked(case status {
            Selected -> "true"
            _ -> "false"
          }),
        ),
        internal.Attr(attribute.role("radio")),
      ],
      view(status),
    )
  }

  let option_area = case orientation {
    Row ->
      ui.row(
        [hidden_label_attribute(label), ..attrs],
        list.map(options, render_option),
      )
    Column ->
      ui.column(
        [hidden_label_attribute(label), ..attrs],
        list.map(options, render_option),
      )
  }

  apply_label(
    [
      ui.align_left(),
      tab_index(0),
      internal.html_class("focus"),
      region.announce(),
      internal.Attr(attribute.role("radiogroup")),
    ],
    label,
    option_area,
  )
}

fn default_radio_option(
  option_label: Element(msg),
) -> fn(OptionState) -> Element(msg) {
  fn(status: OptionState) {
    ui.row([ui.spacing(10), ui.align_left(), width(shrink())], [
      ui.el(
        [
          width(ui.px(14)),
          height(ui.px(14)),
          background.color(white()),
          border.rounded(7),
          case status {
            Selected -> internal.html_class("focusable")
            _ -> internal.NoAttribute
          },
          border.width(case status {
            Selected -> 5
            _ -> 1
          }),
          border.color(case status {
            Selected -> rgb(59.0 /. 255.0, 153.0 /. 255.0, 252.0 /. 255.0)
            _ -> rgb(208.0 /. 255.0, 208.0 /. 255.0, 208.0 /. 255.0)
          }),
        ],
        none,
      ),
      ui.el(
        [width(fill()), internal.html_class("unfocusable")],
        option_label,
      ),
    ])
  }
}

// KEY CODES -------------------------------------------------------------------

const enter = "Enter"

const space = " "

fn tab_index(index: Int) -> Attribute(msg) {
  internal.Attr(attribute.tabindex(index))
}

fn on_key_lookup(msg, decoder: fn(String) -> Option(msg)) -> Attribute(msg) {
  events.on("keyup", {
    use key <- decode.then(events.key())
    case decoder(key) {
      Some(msg) -> decode.success(msg)
      None -> decode.failure(msg, "Key not handled")
    }
  })
}

/// Set an element to be focused when the page loads
pub fn focused_on_load() -> Attribute(msg) {
  internal.Attr(attribute.autofocus(True))
}

fn default_text_box_style() {
  [
    default_text_padding(),
    border.rounded(3),
    border.color(internal.Rgba(64.0 /. 255.0, 64.0 /. 255.0, 64.0 /. 255.0, 1.0)),
    // darkGrey equivalent
    background.color(white()),
    border.width(1),
    ui.spacing(5),
    ui.width(ui.fill()),
    ui.height(ui.shrink()),
  ]
}

fn default_text_padding() {
  ui.padding_xy(12, 12)
}

fn get_height(attr: Attribute(msg)) {
  case attr {
    internal.Height(h) -> Ok(h)
    _ -> Error(Nil)
  }
}

fn is_constrained(len: internal.Length) -> Bool {
  case len {
    internal.Content -> False
    internal.Px(_) -> True
    internal.Pct(_) -> True
    internal.ScreenPct(_) -> True
    internal.Fill(_) -> True
    internal.Min(_, l) -> is_constrained(l)
    internal.Max(_, _) -> True
  }
}

fn render_placeholder(
  p: Placeholder(msg),
  for_placeholder: List(Attribute(msg)),
  on: Bool,
) -> Element(msg) {
  let Placeholder(placeholder_attrs, placeholder_el) = p
  ui.el(
    list.flatten([
      for_placeholder,
      [
        font.color(rgb(0.21, 0.21, 0.21)),
        // charcoal
        internal.html_class(
          style.classes_no_text_selection
          <> " "
          <> style.classes_pass_pointer_events,
        ),
        ui.clip(),
        border.width(0),
        border.color(rgba(0.0, 0.0, 0.0, 0.0)),
        background.color(rgba(0.0, 0.0, 0.0, 0.0)),
        ui.height(ui.fill()),
        ui.width(ui.fill()),
        ui.alpha(case on {
          True -> 1.0
          False -> 0.0
        }),
      ],
      placeholder_attrs,
    ]),
    placeholder_el,
  )
}

// {-| Because textareas are now shadowed, where they're rendered twice,
// we to move the literal text area up because spacing is based on line height.
// -}
fn calc_move_to_compensate_for_padding(
  attrs: List(Attribute(msg)),
) -> Attribute(msg) {
  let gather_spacing = fn(found, attr) {
    case attr {
      internal.StyleClass(_, internal.SpacingStyle(_, _, y)) ->
        case found {
          None -> Some(y)
          Some(_) -> found
        }
      _ -> found
    }
  }

  case list.fold_right(attrs, None, gather_spacing) {
    None -> internal.NoAttribute
    Some(v_space) -> ui.move_up(float.floor(int.to_float(v_space) /. 2.0))
  }
}

fn negate_box(box: Box) -> Box {
  Box(top: -box.top, right: -box.right, bottom: -box.bottom, left: -box.left)
}

fn render_box(box: Box) -> String {
  int.to_string(box.top)
  <> "px "
  <> int.to_string(box.right)
  <> "px "
  <> int.to_string(box.bottom)
  <> "px "
  <> int.to_string(box.left)
  <> "px"
}
