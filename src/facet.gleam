import gleam/list
import gleam/string
import gleam/int
import gleam/float
import gleam/option.{type Option, None, Some}
import facet/internal/model.{
  type Attribute, type Element, type Length, type Color, type Device, 
  type DeviceClass, type Orientation, type FocusStyle, type Shadow,
  type Description, type Location, type Transformation, type HAlign, 
  type VAlign, type Style, type Font, type Property, type RenderMode,
  type Opt, type HoverSetting
}
import facet/internal/flag

// Color type and functions
pub type Color {
  Rgba(red: Float, green: Float, blue: Float, alpha: Float)
}

pub fn rgb(red: Float, green: Float, blue: Float) -> Color {
  Rgba(red, green, blue, 1.0)
}

pub fn rgba(red: Float, green: Float, blue: Float, alpha: Float) -> Color {
  Rgba(red, green, blue, alpha)
}

pub fn rgb255(red: Int, green: Int, blue: Int) -> Color {
  Rgba(
    int.to_float(red) /. 255.0,
    int.to_float(green) /. 255.0,
    int.to_float(blue) /. 255.0,
    1.0
  )
}

pub fn rgba255(red: Int, green: Int, blue: Int, alpha: Float) -> Color {
  Rgba(
    int.to_float(red) /. 255.0,
    int.to_float(green) /. 255.0,
    int.to_float(blue) /. 255.0,
    alpha
  )
}

pub fn from_rgb(color: #(Float, Float, Float)) -> Color {
  let #(r, g, b) = color
  Rgba(r, g, b, 1.0)
}

pub fn from_rgb255(color: #(Int, Int, Int)) -> Color {
  let #(r, g, b) = color
  rgb255(r, g, b)
}

pub fn to_rgb(color: Color) -> #(Float, Float, Float) {
  case color {
    Rgba(r, g, b, _) -> #(r, g, b)
  }
}

// Element and Attribute types
pub type Element(msg) =
  model.Element(msg)

pub type Attribute(msg) =
  model.Attribute(model.Aligned, msg)

pub type Attr(decorative, msg) =
  model.Attribute(decorative, msg)

pub type Decoration =
  model.Aligned

// Length type and functions
pub type Length =
  model.Length

pub fn px(pixels: Int) -> Length {
  model.Px(pixels)
}

pub fn shrink() -> Length {
  model.Content
}

pub fn fill() -> Length {
  model.Fill(1)
}

pub fn minimum(min_length: Int, length: Length) -> Length {
  model.Min(min_length, length)
}

pub fn maximum(max_length: Int, length: Length) -> Length {
  model.Max(max_length, length)
}

pub fn fill_portion(portion: Int) -> Length {
  model.Fill(portion)
}

// Layout functions
pub fn layout(attributes: List(Attribute(msg)), child: Element(msg)) -> Element(msg) {
  layout_with([], attributes, child)
}

pub fn layout_with(
  options: List(Opt), 
  attributes: List(Attribute(msg)), 
  child: Element(msg)
) -> Element(msg) {
  model.create_element(
    model.AsEl,
    model.div,
    list.append([
      model.Class(flag.none(), "container"),
      model.Class(flag.none(), "root")
    ], attributes),
    model.Unkeyed([child])
  )
}

// Option types
pub type Opt =
  model.Opt

pub fn no_static_style_sheet() -> Opt {
  model.RenderModeOption(model.NoStaticStyleSheet)
}

pub fn default_focus() -> Option(FocusStyle) {
  Some(FocusStyle(
    border_color: Some(rgba(0.0, 0.0, 1.0, 1.0)),
    background_color: None,
    shadow: Some(Shadow(
      color: rgba(0.0, 0.0, 0.0, 0.1),
      offset: #(0.0, 0.0),
      blur: 3.0,
      size: 3.0
    ))
  ))
}

pub type FocusStyle {
  FocusStyle(
    border_color: Option(Color),
    background_color: Option(Color), 
    shadow: Option(Shadow)
  )
}

pub fn focus_style(focus: FocusStyle) -> Opt {
  model.FocusStyleOption(focus)
}

pub fn no_hover() -> Opt {
  model.HoverOption(model.NoHover)
}

pub fn force_hover() -> Opt {
  model.HoverOption(model.ForceHover)
}

// Basic elements
pub fn none() -> Element(msg) {
  model.Empty
}

pub fn text(content: String) -> Element(msg) {
  model.Text(content)
}

pub fn el(
  attributes: List(Attribute(msg)), 
  child: Element(msg)
) -> Element(msg) {
  model.create_element(
    model.AsEl,
    model.div,
    attributes,
    model.Unkeyed([child])
  )
}

pub fn row(
  attributes: List(Attribute(msg)), 
  children: List(Element(msg))
) -> Element(msg) {
  model.create_element(
    model.AsRow,
    model.div,
    list.append([
      model.Class(flag.none(), "flex-row")
    ], attributes),
    model.Unkeyed(children)
  )
}

pub fn column(
  attributes: List(Attribute(msg)), 
  children: List(Element(msg))
) -> Element(msg) {
  model.create_element(
    model.AsColumn,
    model.div,
    list.append([
      model.Class(flag.none(), "flex-column")
    ], attributes),
    model.Unkeyed(children)
  )
}

pub fn wrapped_row(
  attributes: List(Attribute(msg)), 
  children: List(Element(msg))
) -> Element(msg) {
  model.create_element(
    model.AsRow,
    model.div,
    list.append([
      model.Class(flag.none(), "flex-wrap")
    ], attributes),
    model.Unkeyed(children)
  )
}

pub fn paragraph(
  attributes: List(Attribute(msg)), 
  children: List(Element(msg))
) -> Element(msg) {
  model.create_element(
    model.AsParagraph,
    model.div,
    list.append([
      model.Class(flag.none(), "paragraph")
    ], attributes),
    model.Unkeyed(children)
  )
}

pub fn text_column(
  attributes: List(Attribute(msg)), 
  children: List(Element(msg))
) -> Element(msg) {
  model.create_element(
    model.AsTextColumn,
    model.div,
    list.append([
      model.Class(flag.none(), "text-column")
    ], attributes),
    model.Unkeyed(children)
  )
}

// Table types and functions
pub type Column(data, msg) {
  Column(
    header: Element(msg),
    width: Length,
    view: fn(data) -> Element(msg)
  )
}

pub fn