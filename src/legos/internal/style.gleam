import gleam/int
import gleam/list
import gleam/string

// module Internal.Style exposing (classes, dot, rules)

// {-| -}

pub type Class {
  Class(name: String, rules: List(Rule))
}

pub type Rule {
  Prop(name: String, value: String)
  Child(name: String, rules: List(Rule))
  AllChildren(name: String, rules: List(Rule))
  Supports(prop: String, value: String, rules: List(#(String, String)))
  Descriptor(name: String, rules: List(Rule))
  Adjacent(name: String, rules: List(Rule))
  Batch(rules: List(Rule))
}

pub type StyleClasses {
  Root
  Any
  Single
  Row
  Column
  Paragraph
  Page
  Text
  Grid
  Spacer
}

pub type Alignment {
  Top
  Bottom
  Right
  Left
  CenterX
  CenterY
}

pub type Location {
  Above
  Below
  OnRight
  OnLeft
  Within
  Behind
}

pub fn alignments() {
  [
    Top,
    Bottom,
    Right,
    Left,
    CenterX,
    CenterY,
  ]
}

pub fn locations() {
  [
    Above,
    Below,
    OnRight,
    OnLeft,
    Within,
    Behind,
  ]
}

pub type SelfDescriptor {
  Self(Alignment)
}

pub type ContentDescriptor {
  Content(Alignment)
}

pub fn self_name(desc: SelfDescriptor) -> String {
  case desc {
    Self(Top) -> dot(classes_align_top)
    Self(Bottom) -> dot(classes_align_bottom)
    Self(Right) -> dot(classes_align_right)
    Self(Left) -> dot(classes_align_left)
    Self(CenterX) -> dot(classes_align_center_x)
    Self(CenterY) -> dot(classes_align_center_y)
  }
}

pub fn content_name(desc: ContentDescriptor) -> String {
  case desc {
    Content(Top) -> dot(classes_content_top)
    Content(Bottom) -> dot(classes_content_bottom)
    Content(Right) -> dot(classes_content_right)
    Content(Left) -> dot(classes_content_left)
    Content(CenterX) -> dot(classes_content_center_x)
    Content(CenterY) -> dot(classes_content_center_y)
  }
}

pub const classes_root = "ui"

pub const classes_any = "s"

pub const classes_single = "e"

pub const classes_row = "r"

pub const classes_column = "c"

pub const classes_page = "pg"

pub const classes_paragraph = "p"

pub const classes_text = "t"

pub const classes_grid = "g"

pub const classes_image_container = "ic"

pub const classes_wrapped = "wrp"

pub const classes_width_fill = "wf"

pub const classes_width_content = "wc"

pub const classes_width_exact = "we"

pub const classes_width_fill_portion = "wfp"

pub const classes_width_fill_percent = "wfpc"

pub const classes_height_fill = "hf"

pub const classes_height_content = "hc"

pub const classes_height_exact = "he"

pub const classes_height_fill_portion = "hfp"

pub const classes_height_fill_percent = "hfpc"

pub const classes_se_button = "sbt"

pub const classes_nearby = "nb"

pub const classes_above = "a"

pub const classes_below = "b"

pub const classes_on_right = "or"

pub const classes_on_left = "ol"

pub const classes_in_front = "fr"

pub const classes_behind = "bh"

pub const classes_has_behind = "hbh"

pub const classes_align_top = "at"

pub const classes_align_bottom = "ab"

pub const classes_align_right = "ar"

pub const classes_align_left = "al"

pub const classes_align_center_x = "cx"

pub const classes_align_center_y = "cy"

pub const classes_aligned_horizontally = "ah"

pub const classes_aligned_vertically = "av"

pub const classes_space_evenly = "sev"

pub const classes_container = "ctr"

pub const classes_align_container_right = "acr"

pub const classes_align_container_bottom = "acb"

pub const classes_align_container_center_x = "accx"

pub const classes_align_container_center_y = "accy"

pub const classes_content_top = "ct"

pub const classes_content_bottom = "cb"

pub const classes_content_right = "cr"

pub const classes_content_left = "cl"

pub const classes_content_center_x = "ccx"

pub const classes_content_center_y = "ccy"

pub const classes_no_text_selection = "notxt"

pub const classes_cursor_pointer = "cptr"

pub const classes_cursor_text = "ctxt"

pub const classes_pass_pointer_events = "ppe"

pub const classes_capture_pointer_events = "cpe"

pub const classes_transparent = "clr"

pub const classes_opaque = "oq"

pub const classes_overflow_hidden = "oh"

pub const classes_hover = "hv"

pub const classes_focus = "fcs"

pub const classes_focused_within = "focus-within"

pub const classes_active = "atv"

pub const classes_scrollbars = "sb"

pub const classes_scrollbars_x = "sbx"

pub const classes_scrollbars_y = "sby"

pub const classes_clip = "cp"

pub const classes_clip_x = "cpx"

pub const classes_clip_y = "cpy"

pub const classes_border_none = "bn"

pub const classes_border_dashed = "bd"

pub const classes_border_dotted = "bdt"

pub const classes_border_solid = "bs"

pub const classes_size_by_capital = "cap"

pub const classes_full_size = "fs"

pub const classes_text_thin = "w1"

pub const classes_text_extra_light = "w2"

pub const classes_text_light = "w3"

pub const classes_text_normal_weight = "w4"

pub const classes_text_medium = "w5"

pub const classes_text_semi_bold = "w6"

pub const classes_bold = "w7"

pub const classes_text_extra_bold = "w8"

pub const classes_text_heavy = "w9"

pub const classes_italic = "i"

pub const classes_strike = "sk"

pub const classes_underline = "u"

pub const classes_text_unitalicized = "tun"

pub const classes_text_justify = "tj"

pub const classes_text_justify_all = "tja"

pub const classes_text_center = "tc"

pub const classes_text_right = "tr"

pub const classes_text_left = "tl"

pub const classes_transition = "ts"

pub const classes_input_text = "it"

pub const classes_input_multiline = "iml"

pub const classes_input_multiline_parent = "imlp"

pub const classes_input_multiline_filler = "imlf"

pub const classes_input_multiline_wrapper = "implw"

pub const classes_input_label = "lbl"

pub const classes_link = "lnk"

pub fn dot(c: String) -> String {
  "." <> c
}

pub fn describe_alignment(
  values: fn(Alignment) -> #(List(Rule), List(Rule)),
) -> Rule {
  let create_description = fn(alignment) {
    let #(content, indiv) = values(alignment)
    [
      Descriptor(content_name(Content(alignment)), content),
      Child(dot(classes_any), [Descriptor(self_name(Self(alignment)), indiv)]),
    ]
  }

  alignments()
  |> list.flat_map(create_description)
  |> Batch()
}

pub fn grid_alignments(values: fn(Alignment) -> List(Rule)) -> Rule {
  let create_description = fn(alignment) {
    [
      Child(dot(classes_any), [
        Descriptor(self_name(Self(alignment)), values(alignment)),
      ]),
    ]
  }

  alignments()
  |> list.flat_map(create_description)
  |> Batch()
}

pub type Intermediate {
  Intermediate(
    selector: String,
    props: List(#(String, String)),
    closing: String,
    others: List(Intermediate),
  )
}

pub fn empty_intermediate(selector: String, closing: String) -> Intermediate {
  Intermediate(selector, [], closing, [])
}

pub fn render_rules(
  parent: Intermediate,
  rules_to_render: List(Rule),
) -> Intermediate {
  let generate_intermediates = fn(rendered: Intermediate, rule) {
    case rule {
      Prop(name, val) ->
        Intermediate(
          rendered.selector,
          [#(name, val), ..rendered.props],
          rendered.closing,
          rendered.others,
        )
      Supports(prop, value, props) ->
        Intermediate(rendered.selector, rendered.props, rendered.closing, [
          Intermediate(
            "@supports (" <> prop <> ":" <> value <> ") {" <> rendered.selector,
            props,
            "\n}",
            [],
          ),
          ..rendered.others
        ])
      Adjacent(selector, adj_rules) ->
        Intermediate(rendered.selector, rendered.props, rendered.closing, [
          render_rules(
            empty_intermediate(rendered.selector <> " + " <> selector, ""),
            adj_rules,
          ),
          ..rendered.others
        ])
      Child(child, child_rules) ->
        Intermediate(rendered.selector, rendered.props, rendered.closing, [
          render_rules(
            empty_intermediate(rendered.selector <> " > " <> child, ""),
            child_rules,
          ),
          ..rendered.others
        ])
      AllChildren(child, child_rules) ->
        Intermediate(rendered.selector, rendered.props, rendered.closing, [
          render_rules(
            empty_intermediate(rendered.selector <> " " <> child, ""),
            child_rules,
          ),
          ..rendered.others
        ])
      Descriptor(descriptor, descriptor_rules) ->
        Intermediate(rendered.selector, rendered.props, rendered.closing, [
          render_rules(
            empty_intermediate(rendered.selector <> descriptor, ""),
            descriptor_rules,
          ),
          ..rendered.others
        ])
      Batch(batched) ->
        Intermediate(rendered.selector, rendered.props, rendered.closing, [
          render_rules(empty_intermediate(rendered.selector, ""), batched),
          ..rendered.others
        ])
    }
  }

  list.fold_right(rules_to_render, parent, generate_intermediates)
}

fn render_values(values) {
  values
  |> list.map(fn(a: #(String, String)) {
    let x = a.0
    let y = a.1
    "  " <> x <> ": " <> y <> ";"
  })
  |> string.join("\n")
}

fn render_class(rule: Intermediate) {
  case rule.props {
    [] -> ""
    _ ->
      rule.selector
      <> " {\n"
      <> render_values(rule.props)
      <> rule.closing
      <> "\n}"
  }
}

fn render_intermediate(rule: Intermediate) {
  render_class(rule)
  <> list.map(rule.others, render_intermediate) |> string.join("\n")
}

pub fn render(class_names: List(Class)) -> String {
  class_names
  |> list.fold_right([], fn(existing, class) {
    let Class(name:, rules:) = class

    list.append([render_rules(empty_intermediate(name, ""), rules)], existing)
  })
  |> list.map(render_intermediate)
  |> string.join("\n")
}

pub fn render_compact(style_classes: List(Class)) -> String {
  let render_values = fn(values) {
    values
    |> list.map(fn(a: #(String, String)) {
      let x = a.0
      let y = a.1
      x <> ":" <> y <> ";"
    })
    |> string.concat
  }

  let render_class = fn(rule: Intermediate) {
    case rule.props {
      [] -> ""
      _ ->
        rule.selector <> "{" <> render_values(rule.props) <> rule.closing <> "}"
    }
  }

  let render_intermediate = fn(rule: Intermediate) {
    render_class(rule)
    <> list.map(rule.others, render_intermediate) |> string.concat
  }

  style_classes
  |> list.fold_right([], fn(existing, class) {
    let Class(name:, rules:) = class
    list.append([render_rules(empty_intermediate(name, ""), rules)], existing)
  })
  |> list.map(render_intermediate)
  |> string.concat
}

// String constants representing CSS rules and resets can be translated to Gleam strings as follows:

pub fn viewport_rules() {
  "
html, body {
    height: 100%;
    width: 100%;
} " <> rules()
}

pub fn describe_text(cls: String, props: List(Rule)) -> Rule {
  Descriptor(
    cls,
    list.flatten([
      list.map(props, make_important),
      [
        Child(".text", props),
        Child(".el", props),
        Child(".el > .text", props),
      ],
    ]),
  )
}

pub fn make_important(rule: Rule) -> Rule {
  case rule {
    Prop(name, prop) -> Prop(name, prop <> " !important")
    _ -> rule
  }
}

pub fn overrides() {
  "
@media screen and (-ms-high-contrast: active), (-ms-high-contrast: none) {" <> dot(
    classes_any,
  ) <> dot(classes_row) <> " > " <> dot(classes_any) <> " { flex-basis: auto !important; } " <> dot(
    classes_any,
  ) <> dot(classes_row) <> " > " <> dot(classes_any) <> dot(classes_container) <> " { flex-basis: auto !important; }}" <> input_text_reset() <> slider_reset <> track_reset <> thumb_reset <> explainer()
}

pub fn input_text_reset() {
  "
input[type=\"search\"],
input[type=\"search\"]::-webkit-search-decoration,
input[type=\"search\"]::-webkit-search-cancel-button,
input[type=\"search\"]::-webkit-search-results-button,
input[type=\"search\"]::-webkit-search-results-decoration {
  -webkit-appearance:none;
}
"
}

pub const slider_reset = "
input[type=range] {
  -webkit-appearance: none;
  background: transparent;
  position:absolute;
  left:0;
  top:0;
  z-index:10;
  width: 100%;
  outline: dashed 1px;
  height: 100%;
  opacity: 0;
}
"

pub const track_reset = "
input[type=range]::-moz-range-track {
    background: transparent;
    cursor: pointer;
}
input[type=range]::-ms-track {
    background: transparent;
    cursor: pointer;
}
input[type=range]::-webkit-slider-runnable-track {
    background: transparent;
    cursor: pointer;
}
"

pub const thumb_reset = "
input[type=range]::-webkit-slider-thumb {
    -webkit-appearance: none;
    opacity: 0.5;
    width: 80px;
    height: 80px;
    background-color: black;
    border:none;
    border-radius: 5px;
}
input[type=range]::-moz-range-thumb {
    opacity: 0.5;
    width: 80px;
    height: 80px;
    background-color: black;
    border:none;
    border-radius: 5px;
}
input[type=range]::-ms-thumb {
    opacity: 0.5;
    width: 80px;
    height: 80px;
    background-color: black;
    border:none;
    border-radius: 5px;
}
input[type=range][orient=vertical]{
    writing-mode: bt-lr; /* IE */
    -webkit-appearance: slider-vertical;  /* WebKit */
}
"

pub fn explainer() {
  "
.explain {
    border: 6px solid rgb(174, 121, 15) !important;
}
.explain > ." <> classes_any <> " {
    border: 4px dashed rgb(0, 151, 167) !important;
}

.ctr {
    border: none !important;
}
.explain > .ctr > ." <> classes_any <> " {
    border: 4px dashed rgb(0, 151, 167) !important;
}
"
}

pub fn common_values() {
  list.flatten([
    list.map(list.range(0, 6), fn(x) {
      Class(".border-" <> int.to_string(x), [
        Prop("border-width", int.to_string(x) <> "px"),
      ])
    }),
    list.map(list.range(8, 32), fn(i) {
      Class(".font-size-" <> int.to_string(i), [
        Prop("font-size", int.to_string(i) <> "px"),
      ])
    }),
    list.map(list.range(0, 24), fn(i) {
      Class(".p-" <> int.to_string(i), [
        Prop("padding", int.to_string(i) <> "px"),
      ])
    }),
    [
      Class(".v-smcp", [Prop("font-variant", "small-caps")]),
      Class(".v-smcp-off", [Prop("font-variant", "normal")]),
    ],
    list.flatten([
      font_variant("zero"),
      font_variant("onum"),
      font_variant("liga"),
      font_variant("dlig"),
      font_variant("ordn"),
      font_variant("tnum"),
      font_variant("afrc"),
      font_variant("frac"),
    ]),
  ])
}

pub fn font_variant(var: String) -> List(Class) {
  [
    Class(".v-" <> var, [Prop("font-feature-settings", "\"" <> var <> "\"")]),
    Class(".v-" <> var <> "-off", [
      Prop("font-feature-settings", "\"" <> var <> "\" 0"),
    ]),
  ]
}

pub fn rules() {
  overrides() <> render_compact(list.flatten([base_sheet(), common_values()]))
}

pub fn el_description() {
  [
    Prop("display", "flex"),
    Prop("flex-direction", "column"),
    Prop("white-space", "pre"),
    Descriptor(dot(classes_has_behind), [
      Prop("z-index", "0"),
      Child(dot(classes_behind), [
        Prop("z-index", "-1"),
      ]),
    ]),
    Descriptor(dot(classes_se_button), [
      Child(dot(classes_text), [
        Descriptor(dot(classes_height_fill), [
          Prop("flex-grow", "0"),
        ]),
        Descriptor(dot(classes_width_fill), [
          Prop("align-self", "auto !important"),
        ]),
      ]),
    ]),
    Child(dot(classes_height_content), [
      Prop("height", "auto"),
    ]),
    Child(dot(classes_height_fill), [
      Prop("flex-grow", "100000"),
    ]),
    Child(dot(classes_width_fill), [
      Prop("width", "100%"),
    ]),
    Child(dot(classes_width_fill_portion), [
      Prop("width", "100%"),
    ]),
    Child(dot(classes_width_content), [
      Prop("align-self", "flex-start"),
    ]),
    describe_alignment(fn(alignment) {
      case alignment {
        Top -> #([Prop("justify-content", "flex-start")], [
          Prop("margin-bottom", "auto !important"),
          Prop("margin-top", "0 !important"),
        ])
        Bottom -> #([Prop("justify-content", "flex-end")], [
          Prop("margin-top", "auto !important"),
          Prop("margin-bottom", "0 !important"),
        ])
        Right -> #([Prop("align-items", "flex-end")], [
          Prop("align-self", "flex-end"),
        ])
        Left -> #([Prop("align-items", "flex-start")], [
          Prop("align-self", "flex-start"),
        ])
        CenterX -> #([Prop("align-items", "center")], [
          Prop("align-self", "center"),
        ])
        CenterY -> #(
          [
            Child(dot(classes_any), [
              Prop("margin-top", "auto"),
              Prop("margin-bottom", "auto"),
            ]),
          ],
          [
            Prop("margin-top", "auto !important"),
            Prop("margin-bottom", "auto !important"),
          ],
        )
      }
    }),
  ]
}

pub fn base_sheet() {
  [
    Class("html,body", [
      Prop("height", "100%"),
      Prop("padding", "0"),
      Prop("margin", "0"),
    ]),
    Class(".transparency-0", [
      Prop("opacity", "0"),
    ]),
    Class(
      dot(classes_any) <> dot(classes_single) <> dot(classes_image_container),
      [
        Prop("display", "block"),
        Descriptor(dot(classes_height_fill), [
          Child("img", [
            Prop("max-height", "100%"),
            Prop("object-fit", "cover"),
          ]),
        ]),
        Descriptor(dot(classes_width_fill), [
          Child("img", [
            Prop("max-width", "100%"),
            Prop("object-fit", "cover"),
          ]),
        ]),
      ],
    ),
    Class(dot(classes_any) <> ":focus", [
      Prop("outline", "none"),
    ]),
    Class(dot(classes_root), [
      Prop("width", "100%"),
      Prop("height", "auto"),
      Prop("min-height", "100%"),
      Prop("z-index", "0"),
      Descriptor(dot(classes_any) <> dot(classes_height_fill), [
        Prop("height", "100%"),
        Child(dot(classes_height_fill), [
          Prop("height", "100%"),
        ]),
      ]),
      Child(dot(classes_in_front), [
        Descriptor(dot(classes_nearby), [
          Prop("position", "fixed"),
          Prop("z-index", "20"),
        ]),
      ]),
    ]),
    Class(dot(classes_nearby), [
      Prop("position", "relative"),
      Prop("border", "none"),
      Prop("display", "flex"),
      Prop("flex-direction", "row"),
      Prop("flex-basis", "auto"),
      Descriptor(dot(classes_single), el_description()),
      Batch(
        list.map(locations(), fn(loc) {
          case loc {
            Above ->
              Descriptor(dot(classes_above), [
                Prop("position", "absolute"),
                Prop("bottom", "100%"),
                Prop("left", "0"),
                Prop("width", "100%"),
                Prop("z-index", "20"),
                Prop("margin", "0 !important"),
                Child(dot(classes_height_fill), [Prop("height", "auto")]),
                Child(dot(classes_width_fill), [Prop("width", "100%")]),
                Prop("pointer-events", "none"),
                Child("*", [Prop("pointer-events", "auto")]),
              ])
            Below ->
              Descriptor(dot(classes_below), [
                Prop("position", "absolute"),
                Prop("bottom", "0"),
                Prop("left", "0"),
                Prop("height", "0"),
                Prop("width", "100%"),
                Prop("z-index", "20"),
                Prop("margin", "0 !important"),
                Prop("pointer-events", "none"),
                Child("*", [Prop("pointer-events", "auto")]),
                Child(dot(classes_height_fill), [Prop("height", "auto")]),
              ])
            OnRight ->
              Descriptor(dot(classes_on_right), [
                Prop("position", "absolute"),
                Prop("left", "100%"),
                Prop("top", "0"),
                Prop("height", "100%"),
                Prop("margin", "0 !important"),
                Prop("z-index", "20"),
                Prop("pointer-events", "none"),
                Child("*", [Prop("pointer-events", "auto")]),
              ])
            OnLeft ->
              Descriptor(dot(classes_on_left), [
                Prop("position", "absolute"),
                Prop("right", "100%"),
                Prop("top", "0"),
                Prop("height", "100%"),
                Prop("margin", "0 !important"),
                Prop("z-index", "20"),
                Prop("pointer-events", "none"),
                Child("*", [Prop("pointer-events", "auto")]),
              ])
            Within ->
              Descriptor(dot(classes_in_front), [
                Prop("position", "absolute"),
                Prop("width", "100%"),
                Prop("height", "100%"),
                Prop("left", "0"),
                Prop("top", "0"),
                Prop("margin", "0 !important"),
                Prop("pointer-events", "none"),
                Child("*", [Prop("pointer-events", "auto")]),
              ])
            Behind ->
              Descriptor(dot(classes_behind), [
                Prop("position", "absolute"),
                Prop("width", "100%"),
                Prop("height", "100%"),
                Prop("left", "0"),
                Prop("top", "0"),
                Prop("margin", "0 !important"),
                Prop("z-index", "0"),
                Prop("pointer-events", "none"),
                Child("*", [Prop("pointer-events", "auto")]),
              ])
          }
        }),
      ),
    ]),
    Class(dot(classes_any), [
      Prop("position", "relative"),
      Prop("border", "none"),
      Prop("flex-shrink", "0"),
      Prop("display", "flex"),
      Prop("flex-direction", "row"),
      Prop("flex-basis", "auto"),
      Prop("resize", "none"),
      Prop("font-feature-settings", "inherit"),
      Prop("box-sizing", "border-box"),
      Prop("margin", "0"),
      Prop("padding", "0"),
      Prop("border-width", "0"),
      Prop("border-style", "solid"),
      Prop("font-size", "inherit"),
      Prop("color", "inherit"),
      Prop("font-family", "inherit"),
      Prop("line-height", "1"),
      Prop("font-weight", "inherit"),
      Prop("text-decoration", "none"),
      Prop("font-style", "inherit"),
      Descriptor(dot(classes_wrapped), [
        Prop("flex-wrap", "wrap"),
      ]),
      Descriptor(dot(classes_no_text_selection), [
        Prop("-moz-user-select", "none"),
        Prop("-webkit-user-select", "none"),
        Prop("-ms-user-select", "none"),
        Prop("user-select", "none"),
      ]),
      Descriptor(dot(classes_cursor_pointer), [
        Prop("cursor", "pointer"),
      ]),
      Descriptor(dot(classes_cursor_text), [
        Prop("cursor", "text"),
      ]),
      Descriptor(dot(classes_pass_pointer_events), [
        Prop("pointer-events", "none !important"),
      ]),
      Descriptor(dot(classes_capture_pointer_events), [
        Prop("pointer-events", "auto !important"),
      ]),
      Descriptor(dot(classes_transparent), [
        Prop("opacity", "0"),
      ]),
      Descriptor(dot(classes_opaque), [
        Prop("opacity", "1"),
      ]),
      Descriptor(dot(classes_hover <> classes_transparent) <> ":hover", [
        Prop("opacity", "0"),
      ]),
      Descriptor(dot(classes_hover <> classes_opaque) <> ":hover", [
        Prop("opacity", "1"),
      ]),
      Descriptor(dot(classes_focus <> classes_transparent) <> ":focus", [
        Prop("opacity", "0"),
      ]),
      Descriptor(dot(classes_focus <> classes_opaque) <> ":focus", [
        Prop("opacity", "1"),
      ]),
      Descriptor(dot(classes_active <> classes_transparent) <> ":active", [
        Prop("opacity", "0"),
      ]),
      Descriptor(dot(classes_active <> classes_opaque) <> ":active", [
        Prop("opacity", "1"),
      ]),
      Descriptor(dot(classes_transition), [
        Prop(
          "transition",
          string.join(
            list.map(
              [
                "transform",
                "opacity",
                "filter",
                "background-color",
                "color",
                "font-size",
              ],
              fn(x) { x <> " 160ms" },
            ),
            ", ",
          ),
        ),
      ]),
      Descriptor(dot(classes_scrollbars), [
        Prop("overflow", "auto"),
        Prop("flex-shrink", "1"),
      ]),
      Descriptor(dot(classes_scrollbars_x), [
        Prop("overflow-x", "auto"),
        Descriptor(dot(classes_row), [
          Prop("flex-shrink", "1"),
        ]),
      ]),
      Descriptor(dot(classes_scrollbars_y), [
        Prop("overflow-y", "auto"),
        Descriptor(dot(classes_column), [
          Prop("flex-shrink", "1"),
        ]),
        Descriptor(dot(classes_single), [
          Prop("flex-shrink", "1"),
        ]),
      ]),
      Descriptor(dot(classes_clip), [
        Prop("overflow", "hidden"),
      ]),
      Descriptor(dot(classes_clip_x), [
        Prop("overflow-x", "hidden"),
      ]),
      Descriptor(dot(classes_clip_y), [
        Prop("overflow-y", "hidden"),
      ]),
      Descriptor(dot(classes_width_content), [
        Prop("width", "auto"),
      ]),
      Descriptor(dot(classes_border_none), [
        Prop("border-width", "0"),
      ]),
      Descriptor(dot(classes_border_dashed), [
        Prop("border-style", "dashed"),
      ]),
      Descriptor(dot(classes_border_dotted), [
        Prop("border-style", "dotted"),
      ]),
      Descriptor(dot(classes_border_solid), [
        Prop("border-style", "solid"),
      ]),
      Descriptor(dot(classes_text), [
        Prop("white-space", "pre"),
        Prop("display", "inline-block"),
      ]),
      Descriptor(dot(classes_input_text), [
        Prop("line-height", "1.05"),
        Prop("background", "transparent"),
        Prop("text-align", "inherit"),
      ]),
      Descriptor(dot(classes_single), el_description()),
      Descriptor(dot(classes_row), [
        Prop("display", "flex"),
        Prop("flex-direction", "row"),
        Child(dot(classes_any), [
          Prop("flex-basis", "0%"),
          Descriptor(dot(classes_width_exact), [
            Prop("flex-basis", "auto"),
          ]),
          Descriptor(dot(classes_link), [
            Prop("flex-basis", "auto"),
          ]),
        ]),
        Child(dot(classes_height_fill), [
          Prop("align-self", "stretch !important"),
        ]),
        Child(dot(classes_height_fill_portion), [
          Prop("align-self", "stretch !important"),
        ]),
        Child(dot(classes_width_fill), [
          Prop("flex-grow", "100000"),
        ]),
        Child(dot(classes_container), [
          Prop("flex-grow", "0"),
          Prop("flex-basis", "auto"),
          Prop("align-self", "stretch"),
        ]),
        Child("u:first-of-type." <> classes_align_container_right, [
          Prop("flex-grow", "1"),
        ]),
        Child("s:first-of-type." <> classes_align_container_center_x, [
          Prop("flex-grow", "1"),
          Child(dot(classes_align_center_x), [
            Prop("margin-left", "auto !important"),
          ]),
        ]),
        Child("s:last-of-type." <> classes_align_container_center_x, [
          Prop("flex-grow", "1"),
          Child(dot(classes_align_center_x), [
            Prop("margin-right", "auto !important"),
          ]),
        ]),
        Child("s:only-of-type." <> classes_align_container_center_x, [
          Prop("flex-grow", "1"),
          Child(dot(classes_align_center_y), [
            Prop("margin-top", "auto !important"),
            Prop("margin-bottom", "auto !important"),
          ]),
        ]),
        Child("s:last-of-type." <> classes_align_container_center_x <> " ~ u", [
          Prop("flex-grow", "0"),
        ]),
        Child(
          "u:first-of-type."
            <> classes_align_container_right
            <> " ~ s."
            <> classes_align_container_center_x,
          [
            Prop("flex-grow", "0"),
          ],
        ),
        describe_alignment(fn(alignment) {
          case alignment {
            Top -> #([Prop("align-items", "flex-start")], [
              Prop("align-self", "flex-start"),
            ])
            Bottom -> #([Prop("align-items", "flex-end")], [
              Prop("align-self", "flex-end"),
            ])
            Right -> #([Prop("justify-content", "flex-end")], [])
            Left -> #([Prop("justify-content", "flex-start")], [])
            CenterX -> #([Prop("justify-content", "center")], [])
            CenterY -> #([Prop("align-items", "center")], [
              Prop("align-self", "center"),
            ])
          }
        }),
        Descriptor(dot(classes_space_evenly), [
          Prop("justify-content", "space-between"),
        ]),
        Descriptor(dot(classes_input_label), [
          Prop("align-items", "baseline"),
        ]),
      ]),
      Descriptor(dot(classes_column), [
        Prop("display", "flex"),
        Prop("flex-direction", "column"),
        Child(dot(classes_any), [
          Prop("flex-basis", "0px"),
          Prop("min-height", "min-content"),
          Descriptor(dot(classes_height_exact), [
            Prop("flex-basis", "auto"),
          ]),
        ]),
        Child(dot(classes_height_fill), [
          Prop("flex-grow", "100000"),
        ]),
        Child(dot(classes_width_fill), [
          Prop("width", "100%"),
        ]),
        Child(dot(classes_width_fill_portion), [
          Prop("width", "100%"),
        ]),
        Child(dot(classes_width_content), [
          Prop("align-self", "flex-start"),
        ]),
        Child("u:first-of-type." <> classes_align_container_bottom, [
          Prop("flex-grow", "1"),
        ]),
        Child("s:first-of-type." <> classes_align_container_center_y, [
          Prop("flex-grow", "1"),
          Child(dot(classes_align_center_y), [
            Prop("margin-top", "auto !important"),
            Prop("margin-bottom", "0 !important"),
          ]),
        ]),
        Child("s:last-of-type." <> classes_align_container_center_y, [
          Prop("flex-grow", "1"),
          Child(dot(classes_align_center_y), [
            Prop("margin-bottom", "auto !important"),
            Prop("margin-top", "0 !important"),
          ]),
        ]),
        Child("s:only-of-type." <> classes_align_container_center_y, [
          Prop("flex-grow", "1"),
          Child(dot(classes_align_center_y), [
            Prop("margin-top", "auto !important"),
            Prop("margin-bottom", "auto !important"),
          ]),
        ]),
        Child("s:last-of-type." <> classes_align_container_center_y <> " ~ u", [
          Prop("flex-grow", "0"),
        ]),
        Child(
          "u:first-of-type."
            <> classes_align_container_bottom
            <> " ~ s."
            <> classes_align_container_center_y,
          [
            Prop("flex-grow", "0"),
          ],
        ),
        describe_alignment(fn(alignment) {
          case alignment {
            Top -> #([Prop("justify-content", "flex-start")], [
              Prop("margin-bottom", "auto"),
            ])
            Bottom -> #([Prop("justify-content", "flex-end")], [
              Prop("margin-top", "auto"),
            ])
            Right -> #([Prop("align-items", "flex-end")], [
              Prop("align-self", "flex-end"),
            ])
            Left -> #([Prop("align-items", "flex-start")], [
              Prop("align-self", "flex-start"),
            ])
            CenterX -> #([Prop("align-items", "center")], [
              Prop("align-self", "center"),
            ])
            CenterY -> #([Prop("justify-content", "center")], [])
          }
        }),
        Child(dot(classes_container), [
          Prop("flex-grow", "0"),
          Prop("flex-basis", "auto"),
          Prop("width", "100%"),
          Prop("align-self", "stretch !important"),
        ]),
        Descriptor(dot(classes_space_evenly), [
          Prop("justify-content", "space-between"),
        ]),
      ]),
      Descriptor(dot(classes_grid), [
        Prop("display", "-ms-grid"),
        Child(".gp", [
          Child(dot(classes_any), [
            Prop("width", "100%"),
          ]),
        ]),
        Supports("display", "grid", [
          #("display", "grid"),
        ]),
        grid_alignments(fn(alignment) {
          case alignment {
            Top -> [Prop("justify-content", "flex-start")]
            Bottom -> [Prop("justify-content", "flex-end")]
            Right -> [Prop("align-items", "flex-end")]
            Left -> [Prop("align-items", "flex-start")]
            CenterX -> [Prop("align-items", "center")]
            CenterY -> [Prop("justify-content", "center")]
          }
        }),
      ]),
      Descriptor(dot(classes_page), [
        Prop("display", "block"),
        Child(dot(classes_any <> ":first-child"), [
          Prop("margin", "0 !important"),
        ]),
        Child(
          dot(
            classes_any
            <> self_name(Self(Left))
            <> ":first-child + ."
            <> classes_any,
          ),
          [
            Prop("margin", "0 !important"),
          ],
        ),
        Child(
          dot(
            classes_any
            <> self_name(Self(Right))
            <> ":first-child + ."
            <> classes_any,
          ),
          [
            Prop("margin", "0 !important"),
          ],
        ),
        describe_alignment(fn(alignment) {
          case alignment {
            Top -> #([], [])
            Bottom -> #([], [])
            Right -> #([], [
              Prop("float", "right"),
              Descriptor("::after", [
                Prop("content", "\"\""),
                Prop("display", "table"),
                Prop("clear", "both"),
              ]),
            ])
            Left -> #([], [
              Prop("float", "left"),
              Descriptor("::after", [
                Prop("content", "\"\""),
                Prop("display", "table"),
                Prop("clear", "both"),
              ]),
            ])
            CenterX -> #([], [])
            CenterY -> #([], [])
          }
        }),
      ]),
      Descriptor(dot(classes_input_multiline), [
        Prop("white-space", "pre-wrap !important"),
        Prop("height", "100%"),
        Prop("width", "100%"),
        Prop("background-color", "transparent"),
      ]),
      Descriptor(dot(classes_input_multiline_wrapper), [
        Descriptor(dot(classes_single), [
          Prop("flex-basis", "auto"),
        ]),
      ]),
      Descriptor(dot(classes_input_multiline_parent), [
        Prop("white-space", "pre-wrap !important"),
        Prop("cursor", "text"),
        Child(dot(classes_input_multiline_filler), [
          Prop("white-space", "pre-wrap !important"),
          Prop("color", "transparent"),
        ]),
      ]),
      Descriptor(dot(classes_paragraph), [
        Prop("display", "block"),
        Prop("white-space", "normal"),
        Prop("overflow-wrap", "break-word"),
        Descriptor(dot(classes_has_behind), [
          Prop("z-index", "0"),
          Child(dot(classes_behind), [
            Prop("z-index", "-1"),
          ]),
        ]),
        AllChildren(dot(classes_text), [
          Prop("display", "inline"),
          Prop("white-space", "normal"),
        ]),
        AllChildren(dot(classes_paragraph), [
          Prop("display", "inline"),
          Descriptor("::after", [Prop("content", "none")]),
          Descriptor("::before", [Prop("content", "none")]),
        ]),
        AllChildren(dot(classes_single), [
          Prop("display", "inline"),
          Prop("white-space", "normal"),
          Descriptor(dot(classes_width_exact), [Prop("display", "inline-block")]),
          Descriptor(dot(classes_in_front), [Prop("display", "flex")]),
          Descriptor(dot(classes_behind), [Prop("display", "flex")]),
          Descriptor(dot(classes_above), [Prop("display", "flex")]),
          Descriptor(dot(classes_below), [Prop("display", "flex")]),
          Descriptor(dot(classes_on_right), [Prop("display", "flex")]),
          Descriptor(dot(classes_on_left), [Prop("display", "flex")]),
          Child(dot(classes_text), [
            Prop("display", "inline"),
            Prop("white-space", "normal"),
          ]),
        ]),
        Child(dot(classes_row), [Prop("display", "inline")]),
        Child(dot(classes_column), [Prop("display", "inline-flex")]),
        Child(dot(classes_grid), [Prop("display", "inline-grid")]),
        describe_alignment(fn(alignment) {
          case alignment {
            Top -> #([], [])
            Bottom -> #([], [])
            Right -> #([], [Prop("float", "right")])
            Left -> #([], [Prop("float", "left")])
            CenterX -> #([], [])
            CenterY -> #([], [])
          }
        }),
      ]),
      Descriptor(".hidden", [Prop("display", "none")]),
      Descriptor(dot(classes_text_thin), [Prop("font-weight", "100")]),
      Descriptor(dot(classes_text_extra_light), [Prop("font-weight", "200")]),
      Descriptor(dot(classes_text_light), [Prop("font-weight", "300")]),
      Descriptor(dot(classes_text_normal_weight), [Prop("font-weight", "400")]),
      Descriptor(dot(classes_text_medium), [Prop("font-weight", "500")]),
      Descriptor(dot(classes_text_semi_bold), [Prop("font-weight", "600")]),
      Descriptor(dot(classes_bold), [Prop("font-weight", "700")]),
      Descriptor(dot(classes_text_extra_bold), [Prop("font-weight", "800")]),
      Descriptor(dot(classes_text_heavy), [Prop("font-weight", "900")]),
      Descriptor(dot(classes_italic), [Prop("font-style", "italic")]),
      Descriptor(dot(classes_strike), [Prop("text-decoration", "line-through")]),
      Descriptor(dot(classes_underline), [
        Prop("text-decoration", "underline"),
        Prop("text-decoration-skip-ink", "auto"),
        Prop("text-decoration-skip", "ink"),
      ]),
      Descriptor(dot(classes_underline <> classes_strike), [
        Prop("text-decoration", "line-through underline"),
        Prop("text-decoration-skip-ink", "auto"),
        Prop("text-decoration-skip", "ink"),
      ]),
      Descriptor(dot(classes_text_unitalicized), [Prop("font-style", "normal")]),
      Descriptor(dot(classes_text_justify), [Prop("text-align", "justify")]),
      Descriptor(dot(classes_text_justify_all), [
        Prop("text-align", "justify-all"),
      ]),
      Descriptor(dot(classes_text_center), [Prop("text-align", "center")]),
      Descriptor(dot(classes_text_right), [Prop("text-align", "right")]),
      Descriptor(dot(classes_text_left), [Prop("text-align", "left")]),
      Descriptor(".modal", [
        Prop("position", "fixed"),
        Prop("left", "0"),
        Prop("top", "0"),
        Prop("width", "100%"),
        Prop("height", "100%"),
        Prop("pointer-events", "none"),
      ]),
    ]),
  ]
}
