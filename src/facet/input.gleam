import facet/element.{
  type Attribute, type Element, fill, height, none, pointer, shrink, width,
}

import facet/color.{rgb, white}
import facet/element/background
import facet/element/border
import facet/element/events
import facet/element/region
import facet/internal/model as internal
import facet/internal/style
import gleam/dynamic/decode
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute as attr

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
    internal.as_el(),
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
      internal.Attr(attr.tabindex(0)),
      ..case on_press {
        None -> [internal.Attr(attr.disabled(True)), ..attrs]
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

pub type CheckboxConfig(msg) {
  CheckboxConfig(
    on_change: fn(Bool) -> msg,
    icon: fn(Bool) -> Element(msg),
    checked: Bool,
    label: Label(msg),
  )
}

/// Create a checkbox input
pub fn checkbox(
  attrs: List(Attribute(msg)),
  config: CheckboxConfig(msg),
) -> Element(msg) {
  let CheckboxConfig(
    on_change: on_change,
    icon: icon,
    checked: checked,
    label: label,
  ) = config

  let attributes = [
    case is_hidden_label(label) {
      True -> internal.NoAttribute
      False -> element.spacing(6)
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
    element.align_left(),
    width(fill()),
    ..attrs
  ]

  apply_label(
    [
      internal.Attr(attr.role("checkbox")),
      internal.Attr(
        attr.aria_checked(case checked {
          True -> "true"
          False -> "false"
        }),
      ),
      hidden_label_attribute(label),
      ..attributes
    ],
    label,
    internal.element(
      internal.as_el(),
      internal.div,
      [
        element.center_y(),
        height(fill()),
        width(shrink()),
      ],
      internal.Unkeyed([icon(checked)]),
    ),
  )
}

/// Default checkbox icon
pub fn default_checkbox(checked: Bool) -> Element(msg) {
  element.el(
    [
      width(element.px(14)),
      height(element.px(14)),
      background.color(white()),
      border.rounded(7),
      border.width(case checked {
        True -> 5
        False -> 1
      }),
      border.color(case checked {
        True -> rgb(59.0 /. 255.0, 153.0 /. 255.0, 252.0 /. 255.0)
        False -> rgb(208.0 /. 255.0, 208.0 /. 255.0, 208.0 /. 255.0)
      }),
    ],
    none(),
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

pub type PasswordConfig(msg) {
  PasswordConfig(
    on_change: fn(String) -> msg,
    text: String,
    placeholder: Option(Placeholder(msg)),
    label: Label(msg),
    show: Bool,
  )
}

pub type MultilineConfig(msg) {
  MultilineConfig(
    on_change: fn(String) -> msg,
    text: String,
    placeholder: Option(Placeholder(msg)),
    label: Label(msg),
    spellcheck: Bool,
  )
}

/// Create a basic text input
pub fn text_input(
  attrs: List(Attribute(msg)),
  config: TextConfig(msg),
) -> Element(msg) {
  text_helper(
    TextInput(type_: TextInputNode("text"), spellchecked: False, autofill: None),
    attrs,
    config,
  )
}

/// Create a spell-checked text input
pub fn spell_checked(
  attrs: List(Attribute(msg)),
  config: TextConfig(msg),
) -> Element(msg) {
  text_helper(
    TextInput(type_: TextInputNode("text"), spellchecked: True, autofill: None),
    attrs,
    config,
  )
}

/// Create a search input
pub fn search(
  attrs: List(Attribute(msg)),
  config: TextConfig(msg),
) -> Element(msg) {
  text_helper(
    TextInput(
      type_: TextInputNode("search"),
      spellchecked: False,
      autofill: None,
    ),
    attrs,
    config,
  )
}

/// Create a username input
pub fn username(
  attrs: List(Attribute(msg)),
  config: TextConfig(msg),
) -> Element(msg) {
  text_helper(
    TextInput(
      type_: TextInputNode("text"),
      spellchecked: False,
      autofill: Some("username"),
    ),
    attrs,
    config,
  )
}

/// Create an email input
pub fn email(
  attrs: List(Attribute(msg)),
  config: TextConfig(msg),
) -> Element(msg) {
  text_helper(
    TextInput(
      type_: TextInputNode("email"),
      spellchecked: False,
      autofill: Some("email"),
    ),
    attrs,
    config,
  )
}

/// Create a new password input
pub fn new_password(
  attrs: List(Attribute(msg)),
  config: PasswordConfig(msg),
) -> Element(msg) {
  let PasswordConfig(
    on_change: on_change,
    text: text_val,
    placeholder: placeholder_val,
    label: label_val,
    show: show,
  ) = config

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
    TextConfig(
      on_change: on_change,
      text: text_val,
      placeholder: placeholder_val,
      label: label_val,
    ),
  )
}

/// Create a current password input
pub fn current_password(
  attrs: List(Attribute(msg)),
  config: PasswordConfig(msg),
) -> Element(msg) {
  let PasswordConfig(
    on_change: on_change,
    text: text_val,
    placeholder: placeholder_val,
    label: label_val,
    show: show,
  ) = config

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
    TextConfig(
      on_change: on_change,
      text: text_val,
      placeholder: placeholder_val,
      label: label_val,
    ),
  )
}

/// Create a multiline text input (textarea)
pub fn multiline(
  attrs: List(Attribute(msg)),
  config: MultilineConfig(msg),
) -> Element(msg) {
  let MultilineConfig(
    on_change: on_change,
    text: text_val,
    placeholder: placeholder_val,
    label: label_val,
    spellcheck: spellcheck_val,
  ) = config

  text_helper(
    TextInput(type_: TextArea, spellchecked: spellcheck_val, autofill: None),
    attrs,
    TextConfig(
      on_change: on_change,
      text: text_val,
      placeholder: placeholder_val,
      label: label_val,
    ),
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

pub type RadioConfig(option, msg) {
  RadioConfig(
    on_change: fn(option) -> msg,
    options: List(RadioOption(option, msg)),
    selected: Option(option),
    label: Label(msg),
  )
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
  config: RadioConfig(option, msg),
) -> Element(msg) {
  radio_helper(Column, attrs, config)
}

/// Create a radio button group (row layout)
pub fn radio_row(
  attrs: List(Attribute(msg)),
  config: RadioConfig(option, msg),
) -> Element(msg) {
  radio_helper(Row, attrs, config)
}

// SLIDER ----------------------------------------------------------------------

pub type Thumb {
  Thumb(attrs: List(Attribute(internal.Never)))
}

pub type SliderConfig(msg) {
  SliderConfig(
    on_change: fn(Float) -> msg,
    label: Label(msg),
    min: Float,
    max: Float,
    value: Float,
    thumb: Thumb,
    step: Option(Float),
  )
}

/// Create a slider thumb
pub fn thumb(attrs: List(Attribute(internal.Never))) -> Thumb {
  Thumb(attrs)
}

/// Default slider thumb
pub fn default_thumb() -> Thumb {
  Thumb([
    width(element.px(16)),
    height(element.px(16)),
    border.rounded(8),
    border.width(1),
    border.color(rgb(0.5, 0.5, 0.5)),
    background.color(white()),
  ])
}

/// Create a slider input
pub fn slider(
  attrs: List(Attribute(msg)),
  config: SliderConfig(msg),
) -> Element(msg) {
  let SliderConfig(
    on_change: on_change,
    label: label_val,
    min: min_val,
    max: max_val,
    value: value_val,
    thumb: thumb_val,
    step: step_val,
  ) = config

  // TODO:

  // This is a simplified implementation - the full slider would require
  // more complex positioning and event handling
  apply_label(
    attrs,
    label_val,
    element.el(
      [
        width(fill()),
        height(element.px(30)),
        background.color(rgb(0.9, 0.9, 0.9)),
        border.rounded(15),
      ],
      none(),
    ),
  )
}

// UTILITY FUNCTIONS -----------------------------------------------------------

fn text_helper(
  input_type: TextInput,
  attrs: List(Attribute(msg)),
  config: TextConfig(msg),
) -> Element(msg) {
  let TextConfig(
    on_change: on_change,
    text: text_val,
    placeholder: _,
    label: label_val,
  ) = config

  apply_label(
    attrs,
    label_val,
    internal.element(
      internal.as_el(),
      case input_type.type_ {
        TextInputNode(_) -> internal.NodeName("input")
        TextArea -> internal.NodeName("textarea")
      },
      [
        internal.Attr(case input_type.type_ {
          TextInputNode(type_) -> attr.type_(type_)
          TextArea -> attr.none()
        }),
        internal.Attr(attr.value(text_val)),
        events.on_input(on_change),
        hidden_label_attribute(label_val),
        internal.Attr(attr.spellcheck(input_type.spellchecked)),
        case input_type {
          TextInput(_, _, Some(autofill_val)) ->
            internal.Attr(attr.autocomplete(autofill_val))
          _ -> internal.NoAttribute
        },
      ],
      internal.Unkeyed([]),
    ),
  )
}

fn apply_label(
  attrs: List(Attribute(msg)),
  label: Label(msg),
  input: Element(msg),
) -> Element(msg) {
  case label {
    HiddenLabel(_) ->
      internal.element(
        internal.as_column(),
        internal.NodeName("label"),
        attrs,
        internal.Unkeyed([input]),
      )
    Label(position, label_attrs, label_child) -> {
      let label_element =
        internal.element(
          internal.as_el(),
          internal.div,
          label_attrs,
          internal.Unkeyed([label_child]),
        )

      case position {
        Above ->
          internal.element(
            internal.as_column(),
            internal.NodeName("label"),
            [internal.html_class(style.classes_input_label), ..attrs],
            internal.Unkeyed([label_element, input]),
          )
        Below ->
          internal.element(
            internal.as_column(),
            internal.NodeName("label"),
            [internal.html_class(style.classes_input_label), ..attrs],
            internal.Unkeyed([input, label_element]),
          )
        OnRight ->
          internal.element(
            internal.as_row(),
            internal.NodeName("label"),
            [internal.html_class(style.classes_input_label), ..attrs],
            internal.Unkeyed([input, label_element]),
          )
        OnLeft ->
          internal.element(
            internal.as_row(),
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
  config: RadioConfig(option, msg),
) -> Element(msg) {
  let RadioConfig(
    on_change: on_change,
    options: options,
    selected: selected,
    label: label_val,
  ) = config

  let render_option = fn(radio_option: RadioOption(option, msg)) {
    let RadioOption(value: val, view: view) = radio_option
    let status = case selected {
      Some(sel) if sel == val -> Selected
      _ -> Idle
    }

    element.el(
      [
        pointer(),
        case orientation {
          Row -> width(shrink())
          Column -> width(fill())
        },
        events.on_click(on_change(val)),
        internal.Attr(
          attr.aria_checked(case status {
            Selected -> "true"
            _ -> "false"
          }),
        ),
        internal.Attr(attr.role("radio")),
      ],
      view(status),
    )
  }

  let option_area = case orientation {
    Row ->
      element.row(
        [hidden_label_attribute(label_val), ..attrs],
        list.map(options, render_option),
      )
    Column ->
      element.column(
        [hidden_label_attribute(label_val), ..attrs],
        list.map(options, render_option),
      )
  }

  apply_label(
    [
      element.align_left(),
      tab_index(0),
      internal.html_class("focus"),
      region.announce(),
      internal.Attr(attr.role("radiogroup")),
    ],
    label_val,
    option_area,
  )
}

fn default_radio_option(
  option_label: Element(msg),
) -> fn(OptionState) -> Element(msg) {
  fn(status: OptionState) {
    element.row([element.spacing(10), element.align_left(), width(shrink())], [
      element.el(
        [
          width(element.px(14)),
          height(element.px(14)),
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
        none(),
      ),
      element.el(
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
  internal.Attr(attr.tabindex(index))
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
  internal.Attr(attr.autofocus(True))
}
