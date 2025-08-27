import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/string
import legos/element.{type Attr, type Attribute, type Color}
import legos/internal/flag
import legos/internal/model as internal
import legos/internal/style

pub type Font =
  internal.Font

pub type Adjustment {
  Adjustment(
    capital: Float,
    lowercase: Float,
    baseline: Float,
    descender: Float,
  )
}

pub type Variant =
  internal.Variant

/// Set the font color
pub fn color(font_color: Color) -> Attr(decorative, msg) {
  internal.StyleClass(
    flag.font_color(),
    internal.Colored(
      "fc-" <> internal.format_color_class(font_color),
      "color",
      font_color,
    ),
  )
}

/// Set the font family from a list of fonts
pub fn family(families: List(Font)) -> Attribute(msg) {
  internal.StyleClass(
    flag.font_family(),
    internal.FontFamily(
      list.fold(families, "ff-", internal.render_font_class_name),
      families,
    ),
  )
}

/// A serif font
pub fn serif() -> Font {
  internal.Serif
}

/// A sans-serif font
pub fn sans_serif() -> Font {
  internal.SansSerif
}

/// A monospace font
pub fn monospace() -> Font {
  internal.Monospace
}

/// A specific typeface by name
pub fn typeface(name: String) -> Font {
  internal.Typeface(name)
}

pub type FontConfig {
  FontConfig(
    name: String,
    adjustment: Option(internal.Adjustment),
    variants: List(Variant),
  )
}

/// Create a font with custom properties
pub fn with(config: FontConfig) -> Font {
  internal.FontWith(config.name, config.adjustment, config.variants)
}

/// Size by capital height
pub fn size_by_capital() -> Attribute(msg) {
  internal.html_class(style.classes_size_by_capital)
}

/// Full size
pub fn full() -> Attribute(msg) {
  internal.html_class(style.classes_full_size)
}

pub type ExternalFontConfig {
  ExternalFontConfig(url: String, name: String)
}

/// Import an external font
pub fn external(config: ExternalFontConfig) -> Font {
  internal.ImportFont(config.name, config.url)
}

/// Set font size in pixels
pub fn size(i: Int) -> Attr(decorative, msg) {
  internal.StyleClass(flag.font_size(), internal.FontSize(i))
}

/// Set letter spacing in pixels
pub fn letter_spacing(offset: Float) -> Attribute(msg) {
  internal.StyleClass(
    flag.letter_spacing(),
    internal.Single(
      "ls-" <> internal.float_class(offset),
      "letter-spacing",
      float.to_string(offset) <> "px",
    ),
  )
}

/// Set word spacing in pixels
pub fn word_spacing(offset: Float) -> Attribute(msg) {
  internal.StyleClass(
    flag.word_spacing(),
    internal.Single(
      "ws-" <> internal.float_class(offset),
      "word-spacing",
      float.to_string(offset) <> "px",
    ),
  )
}

/// Align text to the left
pub fn align_left() -> Attribute(msg) {
  internal.Class(flag.font_alignment(), style.classes_text_left)
}

/// Align text to the right
pub fn align_right() -> Attribute(msg) {
  internal.Class(flag.font_alignment(), style.classes_text_right)
}

/// Center align text
pub fn center() -> Attribute(msg) {
  internal.Class(flag.font_alignment(), style.classes_text_center)
}

/// Justify text alignment
pub fn justify() -> Attribute(msg) {
  internal.Class(flag.font_alignment(), style.classes_text_justify)
}

/// Underline text
pub fn underline() -> Attribute(msg) {
  internal.html_class(style.classes_underline)
}

/// Strike through text
pub fn strike() -> Attribute(msg) {
  internal.html_class(style.classes_strike)
}

/// Italic text
pub fn italic() -> Attribute(msg) {
  internal.html_class(style.classes_italic)
}

/// Bold text
pub fn bold() -> Attribute(msg) {
  internal.Class(flag.font_weight(), style.classes_bold)
}

/// Light font weight
pub fn light() -> Attribute(msg) {
  internal.Class(flag.font_weight(), style.classes_text_light)
}

/// Hairline font weight
pub fn hairline() -> Attribute(msg) {
  internal.Class(flag.font_weight(), style.classes_text_thin)
}

/// Extra light font weight
pub fn extra_light() -> Attribute(msg) {
  internal.Class(flag.font_weight(), style.classes_text_extra_light)
}

/// Regular font weight
pub fn regular() -> Attribute(msg) {
  internal.Class(flag.font_weight(), style.classes_text_normal_weight)
}

/// Semi-bold font weight
pub fn semi_bold() -> Attribute(msg) {
  internal.Class(flag.font_weight(), style.classes_text_semi_bold)
}

/// Medium font weight
pub fn medium() -> Attribute(msg) {
  internal.Class(flag.font_weight(), style.classes_text_medium)
}

/// Extra bold font weight
pub fn extra_bold() -> Attribute(msg) {
  internal.Class(flag.font_weight(), style.classes_text_extra_bold)
}

/// Heavy font weight
pub fn heavy() -> Attribute(msg) {
  internal.Class(flag.font_weight(), style.classes_text_heavy)
}

/// Remove italic styling
pub fn unitalicized() -> Attribute(msg) {
  internal.html_class(style.classes_text_unitalicized)
}

/// Add a text shadow
pub type TextShadowConfig {
  TextShadowConfig(offset: #(Float, Float), blur: Float, color: Color)
}

pub fn shadow(config: TextShadowConfig) -> Attr(decorative, msg) {
  let config =
    internal.ShadowFloat(
      offset: config.offset,
      blur: config.blur,
      color: config.color,
      size: 0.0,
    )
  internal.StyleClass(
    flag.txt_shadows(),
    internal.Single(
      internal.text_shadow_class(config),
      "text-shadow",
      internal.format_text_shadow(config),
    ),
  )
}

/// Add a glow effect (simplified shadow)
pub fn glow(clr: Color, intensity: Float) -> Attr(decorative, msg) {
  let shade =
    internal.ShadowFloat(
      offset: #(0.0, 0.0),
      blur: intensity *. 2.0,
      color: clr,
      size: 0.0,
    )

  internal.StyleClass(
    flag.txt_shadows(),
    internal.Single(
      internal.text_shadow_class(shade),
      "text-shadow",
      internal.format_text_shadow(shade),
    ),
  )
}

/// Set a single font variant
pub fn variant(var: Variant) -> Attribute(msg) {
  case var {
    internal.VariantActive(name) ->
      internal.Class(flag.font_variant(), "v-" <> name)
    internal.VariantOff(name) ->
      internal.Class(flag.font_variant(), "v-" <> name <> "-off")
    internal.VariantIndexed(name, index) ->
      internal.StyleClass(
        flag.font_variant(),
        internal.Single(
          "v-" <> name <> "-" <> int.to_string(index),
          "font-feature-settings",
          "\"" <> name <> "\" " <> int.to_string(index),
        ),
      )
  }
}

fn is_small_caps(variant: Variant) -> Bool {
  case variant {
    internal.VariantActive(feat) -> feat == "smcp"
    _ -> False
  }
}

/// Set multiple font variants
pub fn variant_list(vars: List(Variant)) -> Attribute(msg) {
  let features = list.map(vars, internal.render_variant)
  let has_small_caps = list.any(vars, is_small_caps)

  let name = case has_small_caps {
    True ->
      vars
      |> list.map(internal.variant_name)
      |> string.join("-")
      |> fn(x) { x <> "-sc" }
    False ->
      vars
      |> list.map(internal.variant_name)
      |> string.join("-")
  }

  let feature_string = string.join(features, ", ")

  internal.StyleClass(
    flag.font_variant(),
    internal.Style("v-" <> name, [
      internal.Property("font-feature-settings", feature_string),
      internal.Property("font-variant", case has_small_caps {
        True -> "small-caps"
        False -> "normal"
      }),
    ]),
  )
}

/// Small caps variant
pub fn small_caps() -> Variant {
  internal.VariantActive("smcp")
}

/// Slashed zero variant
pub fn slashed_zero() -> Variant {
  internal.VariantActive("zero")
}

/// Ligatures variant
pub fn ligatures() -> Variant {
  internal.VariantActive("liga")
}

/// Ordinal markers variant
pub fn ordinal() -> Variant {
  internal.VariantActive("ordn")
}

/// Tabular numbers variant
pub fn tabular_numbers() -> Variant {
  internal.VariantActive("tnum")
}

/// Stacked fractions variant
pub fn stacked_fractions() -> Variant {
  internal.VariantActive("afrc")
}

/// Diagonal fractions variant
pub fn diagonal_fractions() -> Variant {
  internal.VariantActive("frac")
}

/// Swash variant with index
pub fn swash(index: Int) -> Variant {
  internal.VariantIndexed("swsh", index)
}

/// Set a feature by name and enabled state
pub fn feature(name: String, on: Bool) -> Variant {
  case on {
    True -> internal.VariantIndexed(name, 1)
    False -> internal.VariantIndexed(name, 0)
  }
}

/// Set an indexed font variant
pub fn indexed(name: String, index: Int) -> Variant {
  internal.VariantIndexed(name, index)
}
