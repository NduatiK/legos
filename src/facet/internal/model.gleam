import facet/internal/flag.{type Flag}
import facet/internal/style
import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string
import lustre/attribute.{type Attribute as LustreAttribute} as attr
import lustre/element.{type Element as LustreElement}
import lustre/element/html
import lustre/element/keyed
import lustre/vdom/vattr

// import lustre/vdom/vnode.{type Element as VNode}

pub type Element(msg) {
  Unstyled(fn(LayoutContext) -> LustreElement(msg))
  Styled(
    styles: List(Style),
    html: fn(EmbedStyle) -> fn(LayoutContext) -> LustreElement(msg),
  )
  Text(String)
  Empty
}

pub type EmbedStyle {
  NoStyleSheet
  StaticRootAndDynamic(OptionRecord, List(Style))
  OnlyDynamic(OptionRecord, List(Style))
}

fn no_style_sheet() -> EmbedStyle {
  NoStyleSheet
}

pub type LayoutContext {
  AsRow
  AsColumn
  AsEl
  AsGrid
  AsParagraph
  AsTextColumn
}

pub type Aligned {
  Unaligned
  Aligned(Option(HAlign), Option(VAlign))
}

pub type HAlign {
  Left
  CenterX
  Right
}

pub type VAlign {
  Top
  CenterY
  Bottom
}

pub type Style {
  Style(String, List(Property))
  // //       class  prop   val
  FontFamily(String, List(Font))
  FontSize(Int)

  // // classname, prop, value
  Single(classname: String, prop: String, value: String)
  Colored(String, String, Color)
  SpacingStyle(String, Int, Int)
  BorderWidth(String, Int, Int, Int, Int)
  PaddingStyle(String, Float, Float, Float, Float)
  GridTemplateStyle(
    spacing: #(Length, Length),
    columns: List(Length),
    rows: List(Length),
  )
  GridPosition(row: Int, col: Int, width: Int, height: Int)
  Transform(Transformation)
  PseudoSelector(PseudoClass, List(Style))
  Transparency(String, Float)
  Shadows(String, String)
}

pub type Transformation {
  Untransformed
  Moved(XYZ)
  // //              translate, scale, rotate
  FullTransform(XYZ, XYZ, XYZ, Angle)
}

pub type PseudoClass {
  Focus
  Hover
  Active
}

pub type Adjustment {
  Adjustment(
    capital: Float,
    lowercase: Float,
    baseline: Float,
    descender: Float,
  )
}

pub type Font {
  Serif
  SansSerif
  Monospace
  Typeface(String)
  ImportFont(String, String)
  FontWith(
    name: String,
    adjustment: Option(Adjustment),
    variants: List(Variant),
  )
}

pub type Variant {
  VariantActive(String)
  VariantOff(String)
  VariantIndexed(String, Int)
}

pub fn render_variant(var: Variant) {
  case var {
    VariantActive(name) -> "\"" <> name <> "\""

    VariantOff(name) -> "\"" <> name <> "\" 0"

    VariantIndexed(name, index) -> "\"" <> name <> "\" " <> int.to_string(index)
  }
}

pub fn variant_name(var: Variant) {
  case var {
    VariantActive(name) -> name

    VariantOff(name) -> name <> "-0"

    VariantIndexed(name, index) -> name <> "-" <> int.to_string(index)
  }
}

fn render_variants(typeface) {
  case typeface {
    FontWith(variants:, ..) ->
      variants
      |> list.map(render_variant)
      |> string.join(", ")
      |> Some()

    _ -> None
  }
}

fn is_small_caps(var: Variant) -> Bool {
  case var {
    VariantActive(name) -> name == "smcp"
    VariantOff(_) -> False
    VariantIndexed(name, index) -> name == "smcp" && index == 1
  }
}

fn has_small_caps(typeface) {
  case typeface {
    FontWith(variants:, ..) -> list.any(variants, is_small_caps)

    _ -> False
  }
}

pub type Property {
  Property(key: String, val: String)
}

type XYZ =
  #(Float, Float, Float)

type Angle =
  Float

pub type Attribute(aligned, msg) {
  NoAttribute
  Attr(LustreAttribute(msg))
  Describe(Description)
  Class(invalidation_key: Flag, name: String)
  StyleClass(invalidation_key: Flag, style: Style)
  AlignY(VAlign)
  AlignX(HAlign)
  Width(Length)
  Height(Length)
  Nearby(Location, Element(msg))
  TransformComponent(Flag, TransformComponent)
}

pub type TransformComponent {
  MoveX(Float)
  MoveY(Float)
  MoveZ(Float)
  MoveXYZ(XYZ)
  Rotate(XYZ, Angle)
  Scale(XYZ)
}

pub type Description {
  Main
  Navigation
  ContentInfo
  Complementary
  Heading(Int)
  Label(String)
  LivePolite
  LiveAssertive
  Button
  Paragraph
}

pub type Length {
  Px(Int)
  Content
  Fill(Int)
  Min(Int, Length)
  Max(Int, Length)
}

type Axis {
  XAxis
  YAxis
  AllAxis
}

pub type Location {
  Above
  Below
  OnRight
  OnLeft
  InFront
  Behind
}

pub type Color {
  Rgba(Float, Float, Float, Float)
  Oklch(Float, Float, Float)
}

pub type NodeName {
  Generic
  NodeName(String)
  Embedded(String, String)
}

pub type NearbyChildren(msg) {
  NoNearbyChildren
  ChildrenBehind(List(LustreElement(msg)))
  ChildrenInFront(List(LustreElement(msg)))
  ChildrenBehindAndInFront(
    behind: List(LustreElement(msg)),
    infront: List(LustreElement(msg)),
  )
}

pub const div = Generic

pub type Gathered(msg) {
  Gathered(
    node: NodeName,
    attributes: List(attr.Attribute(msg)),
    styles: List(Style),
    children: NearbyChildren(msg),
    has: flag.Field,
  )
}

pub fn html_class(class_name: String) -> Attribute(a, msg) {
  Attr(attr.class(class_name))
}

pub fn unstyled(element: LustreElement(msg)) -> Element(msg) {
  Unstyled(fn(_) { element })
}

pub fn finalize_node(
  // has: flag.Field,
  // node: NodeName,
  // attributes: List(VAttr(msg)),
  // children: Children(LustreElement(msg)),
  // embed_mode: EmbedStyle,
  // parentContext: LayoutContext,
  has: flag.Field,
  node: NodeName,
  attributes: List(LustreAttribute(msg)),
  children: Children(LustreElement(msg)),
  embed_mode: EmbedStyle,
  parent_context: LayoutContext,
) -> LustreElement(msg) {
  let create_node = fn(node_name, attrs) {
    case children {
      Keyed(keyed) ->
        keyed.element(node_name, attrs, case embed_mode {
          NoStyleSheet -> keyed
          OnlyDynamic(opts, styles) -> embed_keyed(False, opts, styles, keyed)
          StaticRootAndDynamic(opts, styles) ->
            embed_keyed(True, opts, styles, keyed)
        })

      Unkeyed(unkeyed) -> {
        let node_fn = case node_name {
          "div" -> html.div
          "p" -> html.p
          _ -> fn(attr, c) { element.element(node_name, attr, c) }
        }
        node_fn(attrs, case embed_mode {
          NoStyleSheet -> unkeyed
          OnlyDynamic(opts, styles) -> embed_with(False, opts, styles, unkeyed)
          StaticRootAndDynamic(opts, styles) ->
            embed_with(True, opts, styles, unkeyed)
        })
      }
    }
  }

  let html = case node {
    Generic -> create_node("div", attributes)
    NodeName(node_name) -> create_node(node_name, attributes)
    Embedded(node_name, internal) ->
      element.element(node_name, attributes, [
        create_node(internal, [
          attr.class(style.classes_any <> " " <> style.classes_single),
        ]),
      ])
  }

  case parent_context {
    AsRow ->
      case
        flag.present(flag.width_fill(), has)
        && !flag.present(flag.width_between(), has)
      {
        True -> html
        False -> {
          case flag.present(flag.align_right(), has) {
            True ->
              html.u(
                [
                  attr.class(string.join(
                    [
                      style.classes_any,
                      style.classes_single,
                      style.classes_container,
                      style.classes_content_center_y,
                      style.classes_align_container_right,
                    ],
                    " ",
                  )),
                ],
                [html],
              )
            False ->
              case flag.present(flag.center_x(), has) {
                True ->
                  html.s(
                    [
                      attr.class(string.join(
                        [
                          style.classes_any,
                          style.classes_single,
                          style.classes_container,
                          style.classes_content_center_y,
                          style.classes_align_container_center_x,
                        ],
                        " ",
                      )),
                    ],
                    [html],
                  )
                False -> html
              }
          }
        }
      }

    AsColumn ->
      case
        flag.present(flag.height_fill(), has)
        && !flag.present(flag.height_between(), has)
      {
        True -> html
        False -> {
          case flag.present(flag.center_y(), has) {
            True ->
              html.s(
                [
                  attr.class(string.join(
                    [
                      style.classes_any,
                      style.classes_single,
                      style.classes_container,
                      style.classes_align_container_center_y,
                    ],
                    " ",
                  )),
                ],
                [html],
              )
            False ->
              case flag.present(flag.align_bottom(), has) {
                True ->
                  html.u(
                    [
                      attr.class(string.join(
                        [
                          style.classes_any,
                          style.classes_single,
                          style.classes_container,
                          style.classes_align_container_bottom,
                        ],
                        " ",
                      )),
                    ],
                    [html],
                  )
                False -> html
              }
          }
        }
      }
    _ -> html
  }
}

pub fn embed_with(
  static: Bool,
  opts: OptionRecord,
  styles: List(Style),
  children: List(LustreElement(msg)),
) -> List(LustreElement(msg)) {
  let dynamic_style_sheet =
    styles
    |> list.fold(#(set.new(), render_focus_style(opts.focus)), reduce_styles)
    |> pair.second
    // // |> reduceStylesRecursive(Set.new(), [ ]) //renderFocusStyle opts.focus ]
    // // |> sortedReduce
    |> to_style_sheet(opts, _)

  case static {
    True -> [static_root(opts), dynamic_style_sheet, ..children]
    False -> [dynamic_style_sheet, ..children]
  }
}

pub fn embed_keyed(
  static_: Bool,
  opts: OptionRecord,
  styles: List(Style),
  children: List(#(String, LustreElement(msg))),
) -> List(#(String, LustreElement(msg))) {
  let dynamic_style_sheet =
    styles
    |> list.fold(#(set.new(), render_focus_style(opts.focus)), reduce_styles)
    |> pair.second
    // // |> reduceStylesRecursive Set.empty [ ]) //renderFocusStyle opts.focus ]
    // // |> sortedReduce
    |> to_style_sheet(opts, _)

  case static_ {
    True -> [
      #("static-stylesheet", static_root(opts)),
      #("dynamic-stylesheet", dynamic_style_sheet),
      ..children
    ]
    False -> [#("dynamic-stylesheet", dynamic_style_sheet), ..children]
  }
}

fn reduce_styles_recursive(
  cache: Set(String),
  found: List(Style),
  styles: List(Style),
) -> List(Style) {
  case styles {
    [] -> found

    [head, ..remaining] -> {
      let style_name = get_style_name(head)

      case set.contains(cache, style_name) {
        True -> reduce_styles_recursive(cache, found, remaining)
        False ->
          reduce_styles_recursive(
            set.insert(cache, style_name),
            [head, ..found],
            remaining,
          )
      }
    }
  }
}

fn reduce_styles(
  styles: #(Set(String), List(Style)),
  style: Style,
) -> #(Set(String), List(Style)) {
  let #(cache, existing) = styles
  let style_name = get_style_name(style)

  case set.contains(cache, style_name) {
    True -> #(cache, existing)
    False -> #(set.insert(cache, style_name), [style, ..existing])
  }
}

fn reduce_recursive_calc_name(
  found: List(Style),
  styles: List(#(String, Style)),
) -> List(Style) {
  case styles {
    [] -> found

    [#(_, head_of_list)] -> [head_of_list, ..found]

    [#(head_of_list_name, head_of_list), #(other_name, other), ..remaining] ->
      case head_of_list_name != other_name {
        True ->
          reduce_recursive_calc_name([head_of_list, ..found], [
            #(other_name, other),
            ..remaining
          ])
        False ->
          reduce_recursive_calc_name(found, [#(other_name, other), ..remaining])
      }
  }
}

fn reduce_recursive(
  found: List(Style),
  styles: List(#(String, Style)),
) -> List(Style) {
  case styles {
    [] -> found

    [#(_, head_of_list)] -> [head_of_list, ..found]

    [#(head_of_list_name, head_of_list), #(other_name, other), ..remaining] -> {
      case head_of_list_name != other_name {
        True ->
          reduce_recursive([head_of_list, ..found], [
            #(other_name, other),
            ..remaining
          ])
        False -> reduce_recursive(found, [#(other_name, other), ..remaining])
      }
    }
  }
}

// addNodeName : String -> NodeName -> NodeName
fn add_node_name(new_node, old) {
  case old {
    Generic -> NodeName(new_node)

    NodeName(name) -> Embedded(name, new_node)

    Embedded(x, y) -> Embedded(x, y)
  }
}

pub fn align_x_name(align: HAlign) -> String {
  case align {
    Left ->
      style.classes_aligned_horizontally <> " " <> style.classes_align_left
    Right ->
      style.classes_aligned_horizontally <> " " <> style.classes_align_right
    CenterX ->
      style.classes_aligned_horizontally <> " " <> style.classes_align_center_x
  }
}

pub fn align_y_name(align: VAlign) -> String {
  case align {
    Top -> style.classes_aligned_vertically <> " " <> style.classes_align_top
    Bottom ->
      style.classes_aligned_vertically <> " " <> style.classes_align_bottom
    CenterY ->
      style.classes_aligned_vertically <> " " <> style.classes_align_center_y
  }
}

pub fn transform_class(transform: Transformation) -> Option(String) {
  case transform {
    Untransformed -> None

    Moved(#(x, y, z)) ->
      Some(
        "mv-"
        <> float_class(x)
        <> "-"
        <> float_class(y)
        <> "-"
        <> float_class(z),
      )

    FullTransform(#(tx, ty, tz), #(sx, sy, sz), #(ox, oy, oz), angle) ->
      Some(
        "tfrm-"
        <> float_class(tx)
        <> "-"
        <> float_class(ty)
        <> "-"
        <> float_class(tz)
        <> "-"
        <> float_class(sx)
        <> "-"
        <> float_class(sy)
        <> "-"
        <> float_class(sz)
        <> "-"
        <> float_class(ox)
        <> "-"
        <> float_class(oy)
        <> "-"
        <> float_class(oz)
        <> "-"
        <> float_class(angle),
      )
  }
}

fn transform_value(transform: Transformation) -> Option(String) {
  case transform {
    Untransformed -> None

    Moved(#(x, y, z)) ->
      Some(
        "translate3d("
        <> float.to_string(x)
        <> "px, "
        <> float.to_string(y)
        <> "px, "
        <> float.to_string(z)
        <> "px)",
      )

    FullTransform(#(tx, ty, tz), #(sx, sy, sz), #(ox, oy, oz), angle) -> {
      let translate =
        "translate3d("
        <> float.to_string(tx)
        <> "px, "
        <> float.to_string(ty)
        <> "px, "
        <> float.to_string(tz)
        <> "px)"

      let scale =
        "scale3d("
        <> float.to_string(sx)
        <> ", "
        <> float.to_string(sy)
        <> ", "
        <> float.to_string(sz)
        <> ")"

      let rotate =
        "rotate3d("
        <> float.to_string(ox)
        <> ", "
        <> float.to_string(oy)
        <> ", "
        <> float.to_string(oz)
        <> ", "
        <> float.to_string(angle)
        <> "rad)"
      Some(translate <> " " <> scale <> " " <> rotate)
    }
  }
}

fn compose_transformation(
  transform: Transformation,
  component: TransformComponent,
) -> Transformation {
  case transform {
    Untransformed ->
      case component {
        MoveX(x) -> Moved(#(x, 0.0, 0.0))

        MoveY(y) -> Moved(#(0.0, y, 0.0))

        MoveZ(z) -> Moved(#(0.0, 0.0, z))

        MoveXYZ(xyz) -> Moved(xyz)

        Rotate(xyz, angle) ->
          FullTransform(#(0.0, 0.0, 0.0), #(1.0, 1.0, 1.0), xyz, angle)

        Scale(xyz) ->
          FullTransform(#(0.0, 0.0, 0.0), xyz, #(0.0, 0.0, 1.0), 0.0)
      }

    Moved(#(x, y, z) as moved) ->
      case component {
        MoveX(new_x) -> Moved(#(new_x, y, z))

        MoveY(new_y) -> Moved(#(x, new_y, z))

        MoveZ(new_z) -> Moved(#(x, y, new_z))

        MoveXYZ(xyz) -> Moved(xyz)

        Rotate(xyz, angle) -> FullTransform(moved, #(1.0, 1.0, 1.0), xyz, angle)

        Scale(scale) -> FullTransform(moved, scale, #(0.0, 0.0, 1.0), 0.0)
      }

    FullTransform(#(x, y, z) as moved, scaled, origin, angle) ->
      case component {
        MoveX(new_x) -> FullTransform(#(new_x, y, z), scaled, origin, angle)

        MoveY(new_y) -> FullTransform(#(x, new_y, z), scaled, origin, angle)

        MoveZ(new_z) -> FullTransform(#(x, y, new_z), scaled, origin, angle)

        MoveXYZ(new_move) -> FullTransform(new_move, scaled, origin, angle)

        Rotate(new_origin, new_angle) ->
          FullTransform(moved, scaled, new_origin, new_angle)

        Scale(new_scale) -> FullTransform(moved, new_scale, origin, angle)
      }
  }
}

fn skippable(flag: Flag, style: Style) -> Bool {
  case flag == flag.border_width() {
    True ->
      case style {
        Single(_, _, val) ->
          case val {
            "0px" -> True
            "1px" -> True
            "2px" -> True
            "3px" -> True
            "4px" -> True
            "5px" -> True
            "6px" -> True
            _ -> False
          }
        _ -> False
      }
    False ->
      case style {
        FontSize(i) -> i >= 8 && i <= 32
        PaddingStyle(_, t, r, b, l) ->
          t == b && t == r && t == l && t >=. 0.0 && t <=. 24.0

        _ -> False
      }
  }
}

fn gather_attr_recursive(
  classes: String,
  node: NodeName,
  has: flag.Field,
  transform: Transformation,
  styles: List(Style),
  attrs: List(attr.Attribute(msg)),
  children: NearbyChildren(msg),
  element_attrs: List(Attribute(aligned, msg)),
) -> Gathered(msg) {
  case element_attrs {
    [] ->
      case transform_class(transform) {
        None ->
          Gathered(node, [attr.class(classes), ..attrs], styles, children, has)

        Some(class_name) ->
          Gathered(
            node,
            [attr.class(classes <> " " <> class_name), ..attrs],
            [Transform(transform), ..styles],
            children,
            has,
          )
      }

    [attribute, ..remaining] ->
      case attribute {
        NoAttribute ->
          gather_attr_recursive(
            classes,
            node,
            has,
            transform,
            styles,
            attrs,
            children,
            remaining,
          )

        Class(flag, exact_class_name) ->
          case flag.present(flag, has) {
            True ->
              gather_attr_recursive(
                classes,
                node,
                has,
                transform,
                styles,
                attrs,
                children,
                remaining,
              )
            False ->
              gather_attr_recursive(
                exact_class_name <> " " <> classes,
                node,
                flag.add(has, flag),
                transform,
                styles,
                attrs,
                children,
                remaining,
              )
          }

        Attr(actual_attribute) ->
          gather_attr_recursive(
            classes,
            node,
            has,
            transform,
            styles,
            [actual_attribute, ..attrs],
            children,
            remaining,
          )

        StyleClass(flag, style) ->
          case flag.present(flag, has) {
            True ->
              gather_attr_recursive(
                classes,
                node,
                has,
                transform,
                styles,
                attrs,
                children,
                remaining,
              )
            False ->
              case skippable(flag, style) {
                True ->
                  gather_attr_recursive(
                    get_style_name(style) <> " " <> classes,
                    node,
                    flag.add(has, flag),
                    transform,
                    styles,
                    attrs,
                    children,
                    remaining,
                  )
                False ->
                  gather_attr_recursive(
                    get_style_name(style) <> " " <> classes,
                    node,
                    flag.add(has, flag),
                    transform,
                    [style, ..styles],
                    attrs,
                    children,
                    remaining,
                  )
              }
          }

        TransformComponent(flag, component) ->
          gather_attr_recursive(
            classes,
            node,
            flag.add(has, flag),
            compose_transformation(transform, component),
            styles,
            attrs,
            children,
            remaining,
          )

        Width(width) ->
          case flag.present(flag.width(), has) {
            True ->
              gather_attr_recursive(
                classes,
                node,
                has,
                transform,
                styles,
                attrs,
                children,
                remaining,
              )
            False ->
              case width {
                Px(px) -> {
                  let class_name =
                    style.classes_width_exact
                    <> " width-px-"
                    <> int.to_string(px)

                  let style_item =
                    Single(
                      "width-px-" <> int.to_string(px),
                      "width",
                      int.to_string(px) <> "px",
                    )
                  gather_attr_recursive(
                    class_name <> " " <> classes,
                    node,
                    flag.add(has, flag.width()),
                    transform,
                    [style_item, ..styles],
                    attrs,
                    children,
                    remaining,
                  )
                }

                Content ->
                  gather_attr_recursive(
                    classes <> " " <> style.classes_width_content,
                    node,
                    has
                      |> flag.add(flag.width_content())
                      |> flag.add(flag.width()),
                    transform,
                    styles,
                    attrs,
                    children,
                    remaining,
                  )

                Fill(portion) ->
                  case portion == 1 {
                    True ->
                      gather_attr_recursive(
                        classes <> " " <> style.classes_width_fill,
                        node,
                        has
                          |> flag.add(flag.width_fill())
                          |> flag.add(flag.width()),
                        transform,
                        styles,
                        attrs,
                        children,
                        remaining,
                      )
                    False ->
                      gather_attr_recursive(
                        classes
                          <> " "
                          <> style.classes_width_fill_portion
                          <> " width-fill-"
                          <> int.to_string(portion),
                        node,
                        has
                          |> flag.add(flag.width_fill())
                          |> flag.add(flag.width()),
                        transform,
                        [
                          Single(
                            style.classes_any
                              <> "."
                              <> style.classes_row
                              <> " > "
                              <> style.dot(
                              "width-fill-" <> int.to_string(portion),
                            ),
                            "flex-grow",
                            int.to_string(portion * 100_000),
                          ),
                          ..styles
                        ],
                        attrs,
                        children,
                        remaining,
                      )
                  }

                _ -> {
                  let #(add_to_flags, new_class, new_styles) =
                    render_width(width)

                  gather_attr_recursive(
                    classes <> " " <> new_class,
                    node,
                    flag.merge(add_to_flags, flag.add(has, flag.width())),
                    transform,
                    list.append(new_styles, styles),
                    attrs,
                    children,
                    remaining,
                  )
                }
              }
          }

        Height(height) ->
          case flag.present(flag.height(), has) {
            True ->
              gather_attr_recursive(
                classes,
                node,
                has,
                transform,
                styles,
                attrs,
                children,
                remaining,
              )
            False ->
              case height {
                Px(px) -> {
                  let val = int.to_string(px) <> "px"
                  let name = "height-px-" <> val
                  let style_item = Single(name, "height", val)
                  gather_attr_recursive(
                    style.classes_height_exact <> " " <> name <> " " <> classes,
                    node,
                    flag.add(has, flag.height()),
                    transform,
                    [style_item, ..styles],
                    attrs,
                    children,
                    remaining,
                  )
                }
                Content ->
                  gather_attr_recursive(
                    style.classes_height_content <> " " <> classes,
                    node,
                    has
                      |> flag.add(flag.height_content())
                      |> flag.add(flag.height()),
                    transform,
                    styles,
                    attrs,
                    children,
                    remaining,
                  )

                Fill(portion) ->
                  case portion == 1 {
                    True ->
                      gather_attr_recursive(
                        echo { style.classes_height_fill <> " " <> classes },
                        node,
                        has
                          |> flag.add(flag.height_fill())
                          |> flag.add(flag.height()),
                        transform,
                        styles,
                        attrs,
                        children,
                        remaining,
                      )
                    False ->
                      gather_attr_recursive(
                        classes
                          <> " "
                          <> style.classes_height_fill_portion
                          <> " height-fill-"
                          <> int.to_string(portion),
                        node,
                        has
                          |> flag.add(flag.height_fill())
                          |> flag.add(flag.height()),
                        transform,
                        [
                          Single(
                            style.classes_any
                              <> "."
                              <> style.classes_column
                              <> " > "
                              <> style.dot(
                              "height-fill-" <> int.to_string(portion),
                            ),
                            "flex-grow",
                            int.to_string(portion * 100_000),
                          ),
                          ..styles
                        ],
                        attrs,
                        children,
                        remaining,
                      )
                  }

                _ -> {
                  let #(add_to_flags, new_class, new_styles) =
                    render_height(height)
                  gather_attr_recursive(
                    classes <> " " <> new_class,
                    node,
                    flag.merge(add_to_flags, flag.add(has, flag.height())),
                    transform,
                    list.append(new_styles, styles),
                    attrs,
                    children,
                    remaining,
                  )
                }
              }
          }

        Describe(description) ->
          case description {
            Main ->
              gather_attr_recursive(
                classes,
                add_node_name("main", node),
                has,
                transform,
                styles,
                attrs,
                children,
                remaining,
              )

            Navigation ->
              gather_attr_recursive(
                classes,
                add_node_name("nav", node),
                has,
                transform,
                styles,
                attrs,
                children,
                remaining,
              )

            ContentInfo ->
              gather_attr_recursive(
                classes,
                add_node_name("footer", node),
                has,
                transform,
                styles,
                attrs,
                children,
                remaining,
              )

            Complementary ->
              gather_attr_recursive(
                classes,
                add_node_name("aside", node),
                has,
                transform,
                styles,
                attrs,
                children,
                remaining,
              )

            Heading(i) ->
              case i {
                _ if i <= 1 ->
                  gather_attr_recursive(
                    classes,
                    add_node_name("h1", node),
                    has,
                    transform,
                    styles,
                    attrs,
                    children,
                    remaining,
                  )
                _ if i < 7 ->
                  gather_attr_recursive(
                    classes,
                    add_node_name("h" <> int.to_string(i), node),
                    has,
                    transform,
                    styles,
                    attrs,
                    children,
                    remaining,
                  )
                _ ->
                  gather_attr_recursive(
                    classes,
                    add_node_name("h6", node),
                    has,
                    transform,
                    styles,
                    attrs,
                    children,
                    remaining,
                  )
              }

            Paragraph ->
              // previously we rendered a <p> tag, though apparently this invalidates the htmlcase it has <div>s inside.True->
              // Since we can't guaranteee that there are no divs, we need another strategy.
              // While it's not documented in many places, there apparently is a paragraph aria role
              // https://github.com/w3c/aria/blob/11f85f41a5b621fdbe85fc9bcdcd270e653a48ba/common/script/roleInfo.js
              // Though we'll need to wait till it gets released in an official wai-aria spec to use it.
              // If it's used at the moment, then Lighthouse complains (likely rightfully) that role paragraph is not recognized.
              gather_attr_recursive(
                classes,
                node,
                has,
                transform,
                styles,
                attrs,
                children,
                remaining,
              )

            Button ->
              gather_attr_recursive(
                classes,
                node,
                has,
                transform,
                styles,
                [attr.role("button"), ..attrs],
                children,
                remaining,
              )

            Label(label) ->
              gather_attr_recursive(
                classes,
                node,
                has,
                transform,
                styles,
                [attr.aria_label(label), ..attrs],
                children,
                remaining,
              )

            LivePolite ->
              gather_attr_recursive(
                classes,
                node,
                has,
                transform,
                styles,
                [attr.aria_live("polite"), ..attrs],
                children,
                remaining,
              )

            LiveAssertive ->
              gather_attr_recursive(
                classes,
                node,
                has,
                transform,
                styles,
                [attr.aria_live("assertive"), ..attrs],
                children,
                remaining,
              )
          }

        Nearby(location, elem) -> {
          let new_styles = case elem {
            Empty -> styles
            Text(_) -> styles
            Unstyled(_) -> styles
            Styled(styles:, ..) -> list.append(styles, styles)
          }
          gather_attr_recursive(
            classes,
            node,
            has,
            transform,
            new_styles,
            attrs,
            add_nearby_element(location, elem, children),
            remaining,
          )
        }
        AlignX(x) ->
          case flag.present(flag.x_align(), has) {
            True ->
              gather_attr_recursive(
                classes,
                node,
                has,
                transform,
                styles,
                attrs,
                children,
                remaining,
              )
            False -> {
              let new_flags =
                has
                |> flag.add(flag.x_align())
                |> fn(flags) {
                  case x {
                    CenterX -> flag.add(flags, flag.center_x())
                    Right -> flag.add(flags, flag.align_right())
                    _ -> flags
                  }
                }
              gather_attr_recursive(
                align_x_name(x) <> " " <> classes,
                node,
                new_flags,
                transform,
                styles,
                attrs,
                children,
                remaining,
              )
            }
          }

        AlignY(y) ->
          case flag.present(flag.y_align(), has) {
            True ->
              gather_attr_recursive(
                classes,
                node,
                has,
                transform,
                styles,
                attrs,
                children,
                remaining,
              )
            False -> {
              let new_flags =
                flag.add(has, flag.y_align())
                |> fn(flags) {
                  case y {
                    CenterY -> flag.add(flags, flag.center_y())
                    Bottom -> flag.add(flags, flag.align_bottom())
                    _ -> flags
                  }
                }
              gather_attr_recursive(
                align_y_name(y) <> " " <> classes,
                node,
                new_flags,
                transform,
                styles,
                attrs,
                children,
                remaining,
              )
            }
          }
      }
  }
}

fn add_nearby_element(
  location: Location,
  elem: Element(msg),
  existing: NearbyChildren(msg),
) -> NearbyChildren(msg) {
  let nearby = nearby_element(location, elem)
  case existing {
    NoNearbyChildren ->
      case location {
        Behind -> ChildrenBehind([nearby])
        _ -> ChildrenInFront([nearby])
      }

    ChildrenBehind(existing_behind) ->
      case location {
        Behind -> ChildrenBehind([nearby, ..existing_behind])
        _ -> ChildrenBehindAndInFront(existing_behind, [nearby])
      }

    ChildrenInFront(existing_in_front) ->
      case location {
        Behind -> ChildrenBehindAndInFront([nearby], existing_in_front)
        _ -> ChildrenInFront([nearby, ..existing_in_front])
      }

    ChildrenBehindAndInFront(existing_behind, existing_in_front) ->
      case location {
        Behind ->
          ChildrenBehindAndInFront(
            [nearby, ..existing_behind],
            existing_in_front,
          )
        _ ->
          ChildrenBehindAndInFront(existing_behind, [
            nearby,
            ..existing_in_front
          ])
      }
  }
}

fn nearby_element(location: Location, elem: Element(msg)) -> LustreElement(msg) {
  let class_name = case location {
    Above ->
      string.join(
        [
          style.classes_nearby,
          style.classes_single,
          style.classes_above,
        ],
        " ",
      )

    Below ->
      string.join(
        [
          style.classes_nearby,
          style.classes_single,
          style.classes_below,
        ],
        " ",
      )

    OnRight ->
      string.join(
        [
          style.classes_nearby,
          style.classes_single,
          style.classes_on_right,
        ],
        " ",
      )

    OnLeft ->
      string.join(
        [
          style.classes_nearby,
          style.classes_single,
          style.classes_on_left,
        ],
        " ",
      )

    InFront ->
      string.join(
        [
          style.classes_nearby,
          style.classes_single,
          style.classes_in_front,
        ],
        " ",
      )

    Behind ->
      string.join(
        [
          style.classes_nearby,
          style.classes_single,
          style.classes_behind,
        ],
        " ",
      )
  }

  let child = case elem {
    Empty -> html.text("")

    Text(str) -> text_element(str)

    Unstyled(inner_html) -> inner_html(AsEl)

    Styled(html:, ..) -> html(NoStyleSheet)(AsEl)
  }

  html.div([attr.class(class_name)], [child])
}

fn render_width(w: Length) -> #(flag.Field, String, List(Style)) {
  case w {
    Px(px) -> #(
      flag.none,
      style.classes_width_exact <> " width-px-" <> int.to_string(px),
      [
        Single(
          "width-px-" <> int.to_string(px),
          "width",
          int.to_string(px) <> "px",
        ),
      ],
    )

    Content -> #(
      flag.add(flag.none, flag.width_content()),
      style.classes_width_content,
      [],
    )

    Fill(portion) ->
      case portion == 1 {
        True -> #(
          flag.add(flag.none, flag.width_fill()),
          style.classes_width_fill,
          [],
        )
        False -> #(
          flag.add(flag.none, flag.width_fill()),
          style.classes_width_fill_portion
            <> " width-fill-"
            <> int.to_string(portion),
          [
            Single(
              style.classes_any
                <> "."
                <> style.classes_row
                <> " > "
                <> style.dot("width-fill-" <> int.to_string(portion)),
              "flex-grow",
              int.to_string(portion * 100_000),
            ),
          ],
        )
      }

    Min(min_size, len) -> {
      let cls = "min-width-" <> int.to_string(min_size)

      let style_item = Single(cls, "min-width", int.to_string(min_size) <> "px")

      let #(new_flag, new_attrs, new_styles) = render_width(len)

      #(flag.add(new_flag, flag.width_between()), cls <> " " <> new_attrs, [
        style_item,
        ..new_styles
      ])
    }
    Max(max_size, len) -> {
      let cls = "max-width-" <> int.to_string(max_size)

      let style_item = Single(cls, "max-width", int.to_string(max_size) <> "px")

      let #(new_flag, new_attrs, new_styles) = render_width(len)

      #(flag.add(new_flag, flag.width_between()), cls <> " " <> new_attrs, [
        style_item,
        ..new_styles
      ])
    }
  }
}

fn render_height(h: Length) -> #(flag.Field, String, List(Style)) {
  case h {
    Px(px) -> {
      let val = int.to_string(px)
      let name = "height-px-" <> val
      #(flag.none, style.classes_height_exact <> " " <> name, [
        Single(name, "height", val <> "px"),
      ])
    }

    Content -> #(
      flag.add(flag.none, flag.height_content()),
      style.classes_height_content,
      [],
    )

    Fill(portion) ->
      case portion == 1 {
        True -> #(
          flag.add(flag.none, flag.height_fill()),
          style.classes_height_fill,
          [],
        )
        False -> #(
          flag.add(flag.none, flag.height_fill()),
          style.classes_height_fill_portion
            <> " height-fill-"
            <> int.to_string(portion),
          [
            Single(
              style.classes_any
                <> "."
                <> style.classes_column
                <> " > "
                <> style.dot("height-fill-" <> int.to_string(portion)),
              "flex-grow",
              int.to_string(portion * 100_000),
            ),
          ],
        )
      }

    Min(min_size, len) -> {
      let cls = "min-height-" <> int.to_string(min_size)
      let style_item =
        Single(
          cls,
          "min-height",
          // This needs to be !important because we're using `min-height: min-content`
          // to correct for safari's incorrect implementation of flexbox.
          int.to_string(min_size) <> "px !important",
        )
      let #(new_flag, new_attrs, new_styles) = render_height(len)
      #(flag.add(new_flag, flag.height_between()), cls <> " " <> new_attrs, [
        style_item,
        ..new_styles
      ])
    }

    Max(max_size, len) -> {
      let cls = "max-height-" <> int.to_string(max_size)
      let style_item =
        Single(cls, "max-height", int.to_string(max_size) <> "px")
      let #(new_flag, new_attrs, new_styles) = render_height(len)
      #(flag.add(new_flag, flag.height_between()), cls <> " " <> new_attrs, [
        style_item,
        ..new_styles
      ])
    }
  }
}

fn row_class() {
  style.classes_any <> " " <> style.classes_row
}

fn column_class() {
  style.classes_any <> " " <> style.classes_column
}

fn single_class() {
  style.classes_any <> " " <> style.classes_single
}

fn grid_class() {
  style.classes_any <> " " <> style.classes_grid
}

fn paragraph_class() {
  style.classes_any <> " " <> style.classes_paragraph
}

fn page_class() {
  style.classes_any <> " " <> style.classes_page
}

fn context_classes(context) {
  case context {
    AsRow -> row_class()
    AsColumn -> column_class()
    AsEl -> single_class()
    AsGrid -> grid_class()
    AsParagraph -> paragraph_class()
    AsTextColumn -> page_class()
  }
}

pub fn element(
  context: LayoutContext,
  node: NodeName,
  attributes: List(Attribute(aligned, msg)),
  children: Children(Element(msg)),
) -> Element(msg) {
  attributes
  |> list.reverse
  |> gather_attr_recursive(
    context_classes(context),
    node,
    flag.none,
    Untransformed,
    [],
    [],
    NoNearbyChildren,
    _,
  )
  |> create_element(context, children)
}

fn untransformed() {
  Untransformed
}

pub fn create_element(
  rendered: Gathered(msg),
  context: LayoutContext,
  children: Children(Element(msg)),
) -> Element(msg) {
  let gather = fn(acc, child) {
    let #(htmls, existing_styles) = acc
    case child {
      Unstyled(html) -> #([html(context), ..htmls], existing_styles)

      Styled(html:, styles:) -> {
        let new_styles = case list.is_empty(existing_styles) {
          True -> styles
          False -> list.append(styles, existing_styles)
        }

        #([html(NoStyleSheet)(context), ..htmls], new_styles)
      }
      Text(str) -> #(
        [
          case context == AsEl {
            True -> text_element_fill(str)
            False -> text_element(str)
          },
          ..htmls
        ],
        existing_styles,
      )

      Empty -> #(htmls, existing_styles)
    }
  }

  let gather_keyed = fn(acc, item) {
    let #(htmls, existing_styles) = acc
    let #(key, child) = item
    case child {
      Unstyled(html) -> #([#(key, html(context)), ..htmls], existing_styles)

      Styled(styles:, html:) -> {
        let new_styles = case list.is_empty(existing_styles) {
          True -> styles
          False -> list.append(styles, existing_styles)
        }

        #([#(key, html(NoStyleSheet)(context)), ..htmls], new_styles)
      }
      Text(str) -> #(
        [
          #(key, case context == AsEl {
            True -> text_element_fill(str)
            False -> text_element(str)
          }),
          ..htmls
        ],
        existing_styles,
      )

      Empty -> #(htmls, existing_styles)
    }
  }

  case children {
    Keyed(keyed_children) ->
      case list.fold_right(keyed_children, #([], []), gather_keyed) {
        #(keyed, styles) -> {
          let new_styles = case list.is_empty(styles) {
            True -> rendered.styles
            False -> list.append(rendered.styles, styles)
          }

          case new_styles {
            [] ->
              Unstyled(fn(layout) {
                finalize_node(
                  rendered.has,
                  rendered.node,
                  rendered.attributes,
                  Keyed(add_keyed_children(
                    "nearby-element-pls",
                    keyed,
                    rendered.children,
                  )),
                  NoStyleSheet,
                  layout,
                )
              })

            all_styles ->
              Styled(styles: all_styles, html: fn(embed_mode) {
                fn(layout) {
                  finalize_node(
                    rendered.has,
                    rendered.node,
                    rendered.attributes,
                    Keyed(add_keyed_children(
                      "nearby-element-pls",
                      keyed,
                      rendered.children,
                    )),
                    embed_mode,
                    layout,
                  )
                }
              })
          }
        }
      }

    Unkeyed(unkeyed_children) ->
      case list.fold_right(unkeyed_children, #([], []), gather) {
        #(unkeyed, styles) -> {
          let new_styles = case list.is_empty(styles) {
            True -> rendered.styles
            False -> list.append(rendered.styles, styles)
          }

          case new_styles {
            [] ->
              Unstyled(finalize_node(
                rendered.has,
                rendered.node,
                rendered.attributes,
                Unkeyed(add_children(unkeyed, rendered.children)),
                NoStyleSheet,
                _,
              ))

            all_styles ->
              Styled(styles: all_styles, html: fn(embed_mode) {
                fn(layout) {
                  finalize_node(
                    rendered.has,
                    rendered.node,
                    rendered.attributes,
                    Unkeyed(add_children(unkeyed, rendered.children)),
                    embed_mode,
                    layout,
                  )
                }
              })
          }
        }
      }
  }
}

fn add_children(
  existing: List(LustreElement(msg)),
  nearby_children: NearbyChildren(msg),
) -> List(LustreElement(msg)) {
  case nearby_children {
    NoNearbyChildren -> existing

    ChildrenBehind(behind) -> list.append(behind, existing)

    ChildrenInFront(in_front) -> list.append(existing, in_front)

    ChildrenBehindAndInFront(behind, in_front) ->
      list.flatten([behind, existing, in_front])
  }
}

fn add_keyed_children(
  key: String,
  existing: List(#(String, LustreElement(msg))),
  nearby_children: NearbyChildren(msg),
) -> List(#(String, LustreElement(msg))) {
  let map_with_key = fn(elements) {
    list.map(elements, fn(elem) { #(key, elem) })
  }

  case nearby_children {
    NoNearbyChildren -> existing

    ChildrenBehind(behind) -> list.append(map_with_key(behind), existing)

    ChildrenInFront(in_front) -> list.append(existing, map_with_key(in_front))

    ChildrenBehindAndInFront(behind, in_front) ->
      list.flatten([map_with_key(behind), existing, map_with_key(in_front)])
  }
}

const unit = 0

const default_options = OptionRecord(
  hover: AllowHover,
  focus: focus_default_style,
  mode: Layout,
)

fn static_root(opts: OptionRecord) {
  case opts.mode {
    Layout ->
      // wrap the style node in a div to prevent `Dark Reader` from blowin up the dom.
      element.element("div", [], [
        element.element("style", [], [element.text(style.rules())]),
      ])

    NoStaticStyleSheet -> element.text("")

    WithVirtualCss ->
      element.element(
        "elm-ui-static-rules",
        [attr.property("rules", json.string(style.rules()))],
        [],
      )
  }
}

fn add_when(if_this: Bool, x: a, to: List(a)) -> List(a) {
  case if_this {
    True -> [x, ..to]
    False -> to
  }
}

// {-| TODO:

// This doesn't reduce equivalent attributes completely.

// -}
fn filter(attrs: List(Attribute(aligned, msg))) -> List(Attribute(aligned, msg)) {
  attrs
  |> list.fold_right(#([], set.new()), fn(acc, x) {
    let #(found, has) = acc
    case x {
      NoAttribute -> #(found, has)

      Class(_, _) -> #([x, ..found], has)

      Attr(_) -> #([x, ..found], has)

      StyleClass(_, _) -> #([x, ..found], has)

      Width(_) ->
        case set.contains(has, "width") {
          True -> #(found, has)
          False -> #([x, ..found], set.insert(has, "width"))
        }

      Height(_) ->
        case set.contains(has, "height") {
          True -> #(found, has)
          False -> #([x, ..found], set.insert(has, "height"))
        }

      Describe(_) ->
        case set.contains(has, "described") {
          True -> #(found, has)
          False -> #([x, ..found], set.insert(has, "described"))
        }

      Nearby(_, _) -> #([x, ..found], has)

      AlignX(_) ->
        case set.contains(has, "align-x") {
          True -> #(found, has)
          False -> #([x, ..found], set.insert(has, "align-x"))
        }

      AlignY(_) ->
        case set.contains(has, "align-y") {
          True -> #(found, has)
          False -> #([x, ..found], set.insert(has, "align-y"))
        }

      TransformComponent(_, _) ->
        case set.contains(has, "transform") {
          True -> #(found, has)
          False -> #([x, ..found], set.insert(has, "transform"))
        }
    }
  })
  |> pair.first()
}

fn is_content(len) {
  case len {
    Content -> True

    Max(_, l) -> is_content(l)

    Min(_, l) -> is_content(l)

    _ -> False
  }
}

fn get(
  attrs: List(Attribute(aligned, msg)),
  is_attr: fn(Attribute(aligned, msg)) -> Bool,
) -> List(Attribute(aligned, msg)) {
  attrs
  |> filter
  |> list.fold_right([], fn(found, x) {
    case is_attr(x) {
      True -> [x, ..found]
      False -> found
    }
  })
}

pub type Spacing {
  Spaced(String, Int, Int)
}

pub type Padding {
  Padding(String, Float, Float, Float, Float)
}

pub fn extract_spacing_and_padding(
  attrs: List(Attribute(aligned, msg)),
) -> #(Option(Padding), Option(Spacing)) {
  attrs
  |> list.fold_right(#(None, None), fn(pad_and_spacing, attr) {
    let #(pad, spacing) = pad_and_spacing

    let new_pad = case pad {
      Some(_) -> pad

      None ->
        case attr {
          StyleClass(_, PaddingStyle(name, t, r, b, l)) ->
            Some(Padding(name, t, r, b, l))

          _ -> None
        }
    }

    let new_spacing = case spacing {
      Some(_) -> spacing

      None ->
        case attr {
          StyleClass(_, SpacingStyle(name, x, y)) -> Some(Spaced(name, x, y))

          _ -> None
        }
    }

    #(new_pad, new_spacing)
  })
}

pub fn get_spacing(
  attrs: List(Attribute(aligned, msg)),
  default: #(Int, Int),
) -> #(Int, Int) {
  attrs
  |> list.fold_right(None, fn(acc, attr) {
    case acc {
      Some(x) -> Some(x)

      None ->
        case attr {
          StyleClass(_, SpacingStyle(_, x, y)) -> Some(#(x, y))
          _ -> None
        }
    }
  })
  |> option.unwrap(default)
}

pub fn get_width(attrs: List(Attribute(aligned, msg))) -> Option(Length) {
  attrs
  |> list.fold_right(None, fn(acc, attr) {
    case acc {
      Some(x) -> Some(x)

      None ->
        case attr {
          Width(len) -> Some(len)
          _ -> None
        }
    }
  })
}

fn get_height(attrs: List(Attribute(aligned, msg))) -> Option(Length) {
  case
    list.fold_right(attrs, None, fn(acc, attr) {
      case acc {
        Some(x) -> Some(x)

        None ->
          case attr {
            Height(len) -> Some(len)
            _ -> None
          }
      }
    })
  {
    Some(length) -> Some(length)
    None -> None
  }
}

fn text_element_classes() {
  style.classes_any
  <> " "
  <> style.classes_text
  <> " "
  <> style.classes_width_content
  <> " "
  <> style.classes_height_content
}

pub fn text_element(str: String) -> LustreElement(msg) {
  html.div([attr.class(text_element_classes())], [html.text(str)])
}

fn text_element_fill_classes() {
  style.classes_any
  <> " "
  <> style.classes_text
  <> " "
  <> style.classes_width_fill
  <> " "
  <> style.classes_height_fill
}

pub fn text_element_fill(str: String) -> LustreElement(msg) {
  html.div([attr.class(text_element_fill_classes())], [html.text(str)])
}

pub type Children(x) {
  Unkeyed(List(x))
  Keyed(List(#(String, x)))
}

pub fn to_html(
  el: Element(msg),
  mode: fn(List(Style)) -> EmbedStyle,
) -> LustreElement(msg) {
  case el {
    Unstyled(html) -> html(AsEl)

    Styled(styles:, html:) -> html(mode(styles))(AsEl)

    Text(text) -> text_element(text)

    Empty -> text_element("")
  }
}

pub fn render_root(
  option_list: List(Opt),
  attributes: List(Attribute(aligned, msg)),
  child: Element(msg),
) -> LustreElement(msg) {
  let options = options_to_record(option_list)

  let embed_style = case options.mode {
    NoStaticStyleSheet -> OnlyDynamic(options, _)
    _ -> StaticRootAndDynamic(options, _)
  }
  as_el()
  |> element(div, attributes, Unkeyed([child]))
  |> to_html(embed_style)
}

pub type RenderMode {
  Layout
  NoStaticStyleSheet
  WithVirtualCss
}

pub type OptionRecord {
  OptionRecord(hover: HoverSetting, focus: FocusStyle, mode: RenderMode)
}

pub type OptionRecordBuidler {
  OptionRecordBuidler(
    hover: Option(HoverSetting),
    focus: Option(FocusStyle),
    mode: Option(RenderMode),
  )
}

pub type HoverSetting {
  NoHover
  AllowHover
  ForceHover
}

pub type Opt {
  HoverOption(HoverSetting)
  FocusStyleOption(FocusStyle)
  RenderModeOption(RenderMode)
}

pub type FocusStyle {
  FocusStyle(
    border_color: Option(Color),
    background_color: Option(Color),
    shadow: Option(Shadow),
  )
}

pub type Shadow {
  Shadow(color: Color, offset: #(Int, Int), blur: Int, size: Int)
}

pub type ShadowFloat {
  ShadowFloat(color: Color, offset: #(Float, Float), blur: Float, size: Float)
}

pub type InsetShadow {
  InsetShadow(
    color: Color,
    offset: #(Float, Float),
    blur: Float,
    size: Float,
    inset: Bool,
  )
}

pub fn root_style() {
  let families = [
    Typeface("Open Sans"),
    Typeface("Helvetica"),
    Typeface("Verdana"),
    SansSerif,
  ]

  [
    StyleClass(
      flag.bg_color(),
      Colored(
        "bg-" <> format_color_class(Rgba(1.0, 1.0, 1.0, 0.0)),
        "background-color",
        Rgba(1.0, 1.0, 1.0, 0.0),
      ),
    ),
    StyleClass(
      flag.font_color(),
      Colored(
        "fg-" <> format_color_class(Rgba(0.0, 0.0, 0.0, 1.0)),
        "color",
        Rgba(0.0, 0.0, 0.0, 1.0),
      ),
    ),
    StyleClass(flag.font_size(), FontSize(20)),
    StyleClass(
      flag.font_family(),
      FontFamily(list.fold(families, "font-", render_font_class_name), families),
    ),
  ]
}

pub fn render_font_class_name(current, font) {
  current
  <> case font {
    Serif -> "serif"
    SansSerif -> "sans-serif"
    Monospace -> "monospace"
    Typeface(name) ->
      name
      |> string.lowercase
      // TODO: Should work, not guaranteed
      |> string.split(" ")
      |> string.join("-")
    ImportFont(name, _) ->
      name
      |> string.lowercase
      |> string.split(" ")
      |> string.join("-")
    FontWith(name:, ..) ->
      name
      |> string.lowercase
      |> string.split(" ")
      |> string.join("-")
  }
}

fn render_focus_style(focus: FocusStyle) -> List(Style) {
  [
    Style(
      style.dot(style.classes_focused_within) <> ":focus-within",
      option.values([
        option.map(focus.border_color, fn(color) {
          Property("border-color", format_color(color))
        }),
        option.map(focus.background_color, fn(color) {
          Property("background-color", format_color(color))
        }),
        option.map(focus.shadow, fn(shadow) {
          Property(
            "box-shadow",
            format_box_shadow(InsetShadow(
              inset: False,
              color: shadow.color,
              offset: #(
                int.to_float(pair.first(shadow.offset)),
                int.to_float(pair.second(shadow.offset)),
              ),
              blur: int.to_float(shadow.blur),
              size: int.to_float(shadow.size),
            )),
          )
        }),
        Some(Property("outline", "none")),
      ]),
    ),
    Style(
      style.dot(style.classes_any)
        <> ":focus .focusable, "
        <> style.dot(style.classes_any)
        <> ".focusable:focus, "
        <> ".ui-slide-bar:focus + "
        <> style.dot(style.classes_any)
        <> " .focusable-thumb",
      option.values([
        option.map(focus.border_color, fn(color) {
          Property("border-color", format_color(color))
        }),
        option.map(focus.background_color, fn(color) {
          Property("background-color", format_color(color))
        }),
        option.map(focus.shadow, fn(shadow) {
          Property(
            "box-shadow",
            format_box_shadow(InsetShadow(
              inset: False,
              color: shadow.color,
              offset: #(
                int.to_float(pair.first(shadow.offset)),
                int.to_float(pair.second(shadow.offset)),
              ),
              blur: int.to_float(shadow.blur),
              size: int.to_float(shadow.size),
            )),
          )
        }),
        Some(Property("outline", "none")),
      ]),
    ),
  ]
}

pub const focus_default_style = FocusStyle(
  border_color: None,
  background_color: None,
  shadow: Some(
    Shadow(
      //    Rgba(155.0 / 255.0, 203. /. 255., 1., 1)  ,
      color: Rgba(0.608, 0.796, 1.0, 1.0),
      offset: #(0, 0),
      blur: 0,
      size: 3,
    ),
  ),
)

pub fn options_to_record(options: List(Opt)) -> OptionRecord {
  let combine = fn(record: OptionRecordBuidler, opt) {
    case opt {
      HoverOption(hover) -> {
        case record.hover {
          None -> OptionRecordBuidler(..record, hover: Some(hover))
          Some(_) -> record
        }
      }
      FocusStyleOption(focus) -> {
        case record.focus {
          None -> OptionRecordBuidler(..record, focus: Some(focus))
          Some(_) -> record
        }
      }
      RenderModeOption(mode) -> {
        case record.mode {
          None -> OptionRecordBuidler(..record, mode: Some(mode))
          Some(_) -> record
        }
      }
    }
  }

  let and_finally = fn(record: OptionRecordBuidler) {
    OptionRecord(
      hover: case record.hover {
        None -> AllowHover
        Some(hoverable) -> hoverable
      },
      focus: case record.focus {
        None -> focus_default_style
        Some(focusable) -> focusable
      },
      mode: case record.mode {
        None -> Layout
        Some(actual_mode) -> actual_mode
      },
    )
  }

  and_finally(list.fold_right(
    options,
    OptionRecordBuidler(hover: None, focus: None, mode: None),
    combine,
  ))
}

fn to_style_sheet(
  options: OptionRecord,
  style_sheet: List(Style),
) -> LustreElement(msg) {
  case options.mode {
    Layout ->
      // wrap the style node in a div to prevent `Dark Reader` from blowin up the dom.
      html.div([], [
        element.element("style", [], [
          html.text(to_style_sheet_string(options, style_sheet)),
        ]),
      ])

    NoStaticStyleSheet ->
      // wrap the style node in a div to prevent `Dark Reader` from blowin up the dom.
      html.div([], [
        element.element("style", [], [
          html.text(to_style_sheet_string(options, style_sheet)),
        ]),
      ])

    WithVirtualCss ->
      element.element(
        "elm-ui-rules",
        [attr.property("rules", encode_styles(options, style_sheet))],
        [],
      )
  }
}

fn render_top_level_values(rules: List(#(String, List(Font)))) -> String {
  let with_import = fn(font) {
    case font {
      ImportFont(_, url) -> Some("@import url('" <> url <> "');")

      _ -> None
    }
  }
  let all_names = list.map(rules, pair.first)

  let font_imports = fn(typefaces) {
    typefaces
    |> pair.second
    |> list.map(with_import)
    |> option.values()
    |> string.join("\n")
  }

  let font_adjustments = fn(name, typefaces) {
    case typeface_adjustment(typefaces) {
      None ->
        string.join(
          list.map(all_names, fn(other_name) {
            render_null_adjustment_rule(name, other_name)
          }),
          "",
        )

      Some(adjustment) ->
        all_names
        |> list.map(fn(other_name) {
          render_font_adjustment_rule(name, adjustment, other_name)
        })
        |> string.join("")
    }
  }

  let font_imports_rules = string.join(list.map(rules, font_imports), "\n")
  let font_adjustments_rules =
    rules
    |> list.map(fn(t) { font_adjustments(pair.first(t), pair.second(t)) })
    |> string.join("\n")
  font_imports_rules <> "\n" <> font_adjustments_rules
}

fn render_null_adjustment_rule(
  font_to_adjust: String,
  other_font_name: String,
) -> String {
  let name = case font_to_adjust == other_font_name {
    True -> font_to_adjust
    False -> other_font_name <> " ." <> font_to_adjust
  }
  [
    bracket(
      "."
        <> name
        <> "."
        <> style.classes_size_by_capital
        <> ", "
        <> "."
        <> name
        <> " ."
        <> style.classes_size_by_capital,
      [#("line-height", "1")],
    ),
    bracket(
      "."
        <> name
        <> "."
        <> style.classes_size_by_capital
        <> "> ."
        <> style.classes_text
        <> ", ."
        <> name
        <> " ."
        <> style.classes_size_by_capital
        <> " > ."
        <> style.classes_text,
      [#("vertical-align", "0"), #("line-height", "1")],
    ),
  ]
  |> string.join(" ")
}

fn font_rule(
  name: String,
  modifier: String,
  adjustments: #(List(#(String, String)), List(#(String, String))),
) -> List(String) {
  let #(parent_adj, text_adjustment) = adjustments

  [
    bracket(
      "." <> name <> "." <> modifier <> ", " <> "." <> name <> " ." <> modifier,
      parent_adj,
    ),
    bracket(
      "."
        <> name
        <> "."
        <> modifier
        <> "> ."
        <> style.classes_text
        <> ", ."
        <> name
        <> " ."
        <> modifier
        <> " > ."
        <> style.classes_text,
      text_adjustment,
    ),
  ]
}

fn render_font_adjustment_rule(
  font_to_adjust: String,
  full_and_capital: #(
    #(List(#(String, String)), List(#(String, String))),
    #(List(#(String, String)), List(#(String, String))),
  ),
  other_font_name: String,
) -> String {
  let name = case font_to_adjust == other_font_name {
    True -> font_to_adjust
    False -> other_font_name <> " ." <> font_to_adjust
  }

  string.join(
    list.append(
      font_rule(
        name,
        style.classes_size_by_capital,
        pair.second(full_and_capital),
      ),
      font_rule(name, style.classes_full_size, pair.first(full_and_capital)),
    ),
    " ",
  )
}

fn bracket(selector: String, rules: List(#(String, String))) -> String {
  let render_pair = fn(a) {
    let #(name, val) = a
    name <> ": " <> val <> ";"
  }
  selector <> " {" <> string.join(list.map(rules, render_pair), "") <> "}"
}

pub type FontSizing {
  FontSizing(vertical: Float, height: Float, size: Float)
}

fn font_adjustment_rules(converted: FontSizing) {
  #([#("display", "block")], [
    #("display", "inline-block"),
    #("line-height", float.to_string(converted.height)),
    #("vertical-align", float.to_string(converted.vertical) <> "em"),
    #("font-size", float.to_string(converted.size) <> "em"),
  ])
}

fn typeface_adjustment(
  typefaces: List(Font),
) -> Option(
  #(
    #(List(#(String, String)), List(#(String, String))),
    #(List(#(String, String)), List(#(String, String))),
  ),
) {
  list.fold(typefaces, None, fn(found, face) {
    case found {
      None ->
        case face {
          FontWith(adjustment:, ..) ->
            case adjustment {
              None -> found
              Some(adjustment) ->
                Some(#(
                  font_adjustment_rules(convert_adjustment(adjustment).full),
                  font_adjustment_rules(convert_adjustment(adjustment).capital),
                ))
            }
          _ -> found
        }
      Some(_) -> found
    }
  })
}

fn font_name(font) {
  case font {
    Serif -> "serif"

    SansSerif -> "sans-serif"

    Monospace -> "monospace"

    Typeface(name) -> "\"" <> name <> "\""

    ImportFont(name, _url) -> "\"" <> name <> "\""

    FontWith(name:, ..) -> "\"" <> name <> "\""
  }
}

fn top_level_value(rule) {
  case rule {
    FontFamily(name, typefaces) -> Some(#(name, typefaces))
    _ -> None
  }
}

fn render_props(force: Bool, p: Property, existing: String) -> String {
  case force {
    True -> existing <> "\n  " <> p.key <> ": " <> p.val <> " !important;"
    False -> existing <> "\n  " <> p.key <> ": " <> p.val <> ";"
  }
}

fn encode_styles(options: OptionRecord, stylesheet: List(Style)) {
  stylesheet
  |> list.map(fn(style) {
    let styled = render_style_rule(options, style, None)
    #(get_style_name(style), json.array(styled, json.string))
  })
  |> json.object
}

type StyleSheetB(a, b) {
  StyleSheetB(rules: a, top_level: a)
}

fn to_style_sheet_string(
  options: OptionRecord,
  stylesheet: List(Style),
) -> String {
  let combine = fn(rendered, style) {
    let #(rules, top_level_acc) = rendered
    #(
      list.append(rules, render_style_rule(options, style, None)),
      case top_level_value(style) {
        None -> top_level_acc
        Some(top_level) -> [top_level, ..top_level_acc]
      },
    )
  }
  let #(rules, top_level) = list.fold(stylesheet, #([], []), combine)
  render_top_level_values(top_level) <> string.join(rules, "")
}

fn render_style(
  options: OptionRecord,
  maybe_pseudo: Option(PseudoClass),
  selector: String,
  props: List(Property),
) -> List(String) {
  case maybe_pseudo {
    None -> [
      selector
      <> "{"
      <> list.fold(props, "", fn(acc, p) { render_props(False, p, acc) })
      <> "\n}",
    ]

    Some(pseudo) ->
      case pseudo {
        Hover ->
          case options.hover {
            NoHover -> []

            ForceHover -> [
              selector
              <> "-hv {"
              <> list.fold(props, "", fn(acc, p) { render_props(True, p, acc) })
              <> "\n}",
            ]

            AllowHover -> [
              selector
              <> "-hv:hover {"
              <> list.fold(props, "", fn(acc, p) { render_props(False, p, acc) })
              <> "\n}",
            ]
          }

        Focus -> {
          let rendered_props =
            list.fold(props, "", fn(acc, p) { render_props(False, p, acc) })
          [
            selector <> "-fs:focus {" <> rendered_props <> "\n}",
            "."
              <> style.classes_any
              <> ":focus "
              <> selector
              <> "-fs {"
              <> rendered_props
              <> "\n}",
            selector <> "-fs:focus-within {" <> rendered_props <> "\n}",
            ".ui-slide-bar:focus + "
              <> style.dot(style.classes_any)
              <> " .focusable-thumb"
              <> selector
              <> "-fs {"
              <> rendered_props
              <> "\n}",
          ]
        }
        Active -> [
          selector
          <> "-act:active {"
          <> list.fold(props, "", fn(acc, p) { render_props(False, p, acc) })
          <> "\n}",
        ]
      }
  }
}

fn to_grid_length_helper(minimum, maximum, x) {
  case x {
    Px(px) -> int.to_string(px) <> "px"

    Content -> {
      case minimum, maximum {
        None, None -> "max-content"

        Some(min_size), None ->
          "minmax(" <> int.to_string(min_size) <> "px, max-content)"

        None, Some(max_size) ->
          "minmax(max-content, " <> int.to_string(max_size) <> "px)"

        Some(min_size), Some(max_size) ->
          "minmax("
          <> int.to_string(min_size)
          <> "px, "
          <> int.to_string(max_size)
          <> "px)"
      }
    }

    Fill(i) -> {
      case minimum, maximum {
        None, None -> int.to_string(i) <> "fr"

        Some(min_size), None ->
          "minmax("
          <> int.to_string(min_size)
          <> "px, "
          <> int.to_string(i)
          <> "frfr)"

        None, Some(max_size) ->
          "minmax(max-content, " <> int.to_string(max_size) <> "px)"

        Some(min_size), Some(max_size) ->
          "minmax("
          <> int.to_string(min_size)
          <> "px, "
          <> int.to_string(max_size)
          <> "px)"
      }
    }

    Min(m, len) -> to_grid_length_helper(Some(m), maximum, len)

    Max(m, len) -> to_grid_length_helper(minimum, Some(m), len)
  }
}

pub fn render_style_rule(
  options: OptionRecord,
  rule: Style,
  maybe_pseudo: Option(PseudoClass),
) -> List(String) {
  case rule {
    Style(selector, props) ->
      render_style(options, maybe_pseudo, selector, props)

    Shadows(name, prop) ->
      render_style(options, maybe_pseudo, "." <> name, [
        Property("box-shadow", prop),
      ])

    Transparency(name, transparency) -> {
      let opacity = case { 1.0 -. transparency } <=. 1.0 {
        True ->
          case { 1.0 -. transparency } >=. 0.0 {
            True -> 1.0 -. transparency
            False -> 0.0
          }
        False -> 1.0
      }

      render_style(options, maybe_pseudo, "." <> name, [
        Property("opacity", float.to_string(opacity)),
      ])
    }

    FontSize(i) ->
      render_style(options, maybe_pseudo, ".font-size-" <> int.to_string(i), [
        Property("font-size", int.to_string(i) <> "px"),
      ])

    FontFamily(name, typefaces) -> {
      let features =
        typefaces
        |> list.map(render_variants)
        |> option.values
        |> string.join(", ")

      let families = [
        Property(
          "font-family",
          typefaces
            |> list.map(font_name)
            |> string.join(", "),
        ),
        Property("font-feature-settings", features),
        Property("font-variant", case list.any(typefaces, has_small_caps) {
          True -> "small-caps"
          False -> "normal"
        }),
      ]

      render_style(options, maybe_pseudo, "." <> name, families)
    }

    Single(class, prop, val) ->
      render_style(options, maybe_pseudo, "." <> class, [Property(prop, val)])

    Colored(class, prop, color) ->
      render_style(options, maybe_pseudo, "." <> class, [
        Property(prop, format_color(color)),
      ])

    SpacingStyle(cls, x, y) -> {
      let class = "." <> cls
      let half_x = float.to_string(int.to_float(x) /. 2.0) <> "px"
      let half_y = float.to_string(int.to_float(y) /. 2.0) <> "px"
      let x_px = int.to_string(x) <> "px"
      let y_px = int.to_string(y) <> "px"
      let row = "." <> style.classes_row
      let wrapped_row = "." <> style.classes_wrapped <> row
      let column = "." <> style.classes_column
      let page = "." <> style.classes_page
      let paragraph = "." <> style.classes_paragraph
      let left = "." <> style.classes_align_left
      let right = "." <> style.classes_align_right
      let any = "." <> style.classes_any
      let single = "." <> style.classes_single

      list.flatten([
        render_style(
          options,
          maybe_pseudo,
          class <> row <> " > " <> any <> " + " <> any,
          [Property("margin-left", x_px)],
        ),
        // margins don't apply to last element of normal, unwrapped rows
        // , renderStyle options maybePseudo (class ++ row ++ " > " ++ any ++ ":first-child") [ Property "margin" "0" ]
        // For wrapped rows, margins always apply because we handle "canceling out" the other margins manually in the element.
        render_style(
          options,
          maybe_pseudo,
          class <> wrapped_row <> " > " <> any,
          [Property("margin", half_y <> " " <> half_x)],
        ),

        // , renderStyle options maybePseudo
        //     (class ++ wrappedRow ++ " > " ++ any ++ ":last-child")
        //     [ Property "margin-right" "0"
        //     ]
        // columns
        render_style(
          options,
          maybe_pseudo,
          class <> column <> " > " <> any <> " + " <> any,
          [Property("margin-top", y_px)],
        ),
        render_style(
          options,
          maybe_pseudo,
          class <> page <> " > " <> any <> " + " <> any,
          [Property("margin-top", y_px)],
        ),
        render_style(options, maybe_pseudo, class <> page <> " > " <> left, [
          Property("margin-right", x_px),
        ]),
        render_style(options, maybe_pseudo, class <> page <> " > " <> right, [
          Property("margin-left", x_px),
        ]),
        render_style(options, maybe_pseudo, class <> paragraph, [
          Property("line-height", "calc(1em + " <> int.to_string(y) <> "px)"),
        ]),
        render_style(options, maybe_pseudo, "textarea" <> any <> class, [
          Property("line-height", "calc(1em + " <> int.to_string(y) <> "px)"),
          Property("height", "calc(100% + " <> int.to_string(y) <> "px)"),
        ]),

        // , renderStyle options
        //     maybePseudo
        //     (class ++ paragraph ++ " > " ++ any)
        //     [ Property "margin-right" xPx
        //     , Property "margin-bottom" yPx
        //     ]
        render_style(
          options,
          maybe_pseudo,
          class <> paragraph <> " > " <> left,
          [Property("margin-right", x_px)],
        ),
        render_style(
          options,
          maybe_pseudo,
          class <> paragraph <> " > " <> right,
          [Property("margin-left", x_px)],
        ),
        render_style(options, maybe_pseudo, class <> paragraph <> "::after", [
          Property("content", "''"),
          Property("display", "block"),
          Property("height", "0"),
          Property("width", "0"),
          Property("margin-top", int.to_string(-1 * { y / 2 }) <> "px"),
        ]),
        render_style(options, maybe_pseudo, class <> paragraph <> "::before", [
          Property("content", "''"),
          Property("display", "block"),
          Property("height", "0"),
          Property("width", "0"),
          Property("margin-bottom", int.to_string(-1 * { y / 2 }) <> "px"),
        ]),
      ])
    }

    PaddingStyle(cls, top, right, bottom, left) -> {
      let class = "." <> cls

      render_style(options, maybe_pseudo, class, [
        Property(
          "padding",
          float.to_string(top)
            <> "px "
            <> float.to_string(right)
            <> "px "
            <> float.to_string(bottom)
            <> "px "
            <> float.to_string(left)
            <> "px",
        ),
      ])
    }

    BorderWidth(cls, top, right, bottom, left) -> {
      let class = "." <> cls

      render_style(options, maybe_pseudo, class, [
        Property(
          "border-width",
          int.to_string(top)
            <> "px "
            <> int.to_string(right)
            <> "px "
            <> int.to_string(bottom)
            <> "px "
            <> int.to_string(left)
            <> "px",
        ),
      ])
    }

    GridTemplateStyle(spacing:, columns:, rows:) -> {
      let class =
        ".grid-rows-"
        <> string.join(list.map(rows, length_class_name), "-")
        <> "-cols-"
        <> string.join(list.map(columns, length_class_name), "-")
        <> "-space-x-"
        <> length_class_name(pair.first(spacing))
        <> "-space-y-"
        <> length_class_name(pair.second(spacing))

      let to_grid_length = fn(x) { to_grid_length_helper(None, None, x) }

      let y_spacing = to_grid_length(pair.second(spacing))

      let ms_columns =
        columns
        |> list.map(to_grid_length)
        |> string.join(y_spacing)
        |> fn(x) { "-ms-grid-columns: " <> x <> ";" }

      let ms_rows =
        columns
        |> list.map(to_grid_length)
        |> string.join(y_spacing)
        |> fn(x) { "-ms-grid-rows: " <> x <> ";" }

      let base = class <> "{" <> ms_columns <> ms_rows <> "}"

      let columns =
        columns
        |> list.map(to_grid_length)
        |> string.join(" ")
        |> fn(x) { "grid-template-columns: " <> x <> ";" }

      let rows =
        rows
        |> list.map(to_grid_length)
        |> string.join(" ")
        |> fn(x) { "grid-template-rows: " <> x <> ";" }

      let gap_x =
        "grid-column-gap:" <> to_grid_length(pair.first(spacing)) <> ";"

      let gap_y = "grid-row-gap:" <> to_grid_length(pair.second(spacing)) <> ";"

      let modern_grid = class <> "{" <> columns <> rows <> gap_x <> gap_y <> "}"

      let supports = "@supports (display:grid) {" <> modern_grid <> "}"

      [base, supports]
    }

    GridPosition(row:, col:, width:, height:) -> {
      let class =
        ".grid-pos-"
        <> int.to_string(row)
        <> "-"
        <> int.to_string(col)
        <> "-"
        <> int.to_string(width)
        <> "-"
        <> int.to_string(height)

      let ms_position =
        string.join(
          [
            "-ms-grid-row: " <> int.to_string(row) <> ";",
            "-ms-grid-row-span: " <> int.to_string(height) <> ";",
            "-ms-grid-column: " <> int.to_string(col) <> ";",
            "-ms-grid-column-span: " <> int.to_string(width) <> ";",
          ],
          " ",
        )

      let base = class <> "{" <> ms_position <> "}"

      let modern_position =
        string.join(
          [
            "grid-row: "
              <> int.to_string(row)
              <> " / "
              <> int.to_string(row + height)
              <> ";",
            "grid-column: "
              <> int.to_string(col)
              <> " / "
              <> int.to_string(col + width)
              <> ";",
          ],
          " ",
        )

      let modern_grid = class <> "{" <> modern_position <> "}"

      let supports = "@supports (display:grid) {" <> modern_grid <> "}"

      [base, supports]
    }

    PseudoSelector(class, styles) -> {
      let render_pseudo_rule = fn(style) {
        render_style_rule(options, style, Some(class))
      }
      list.flatten(list.map(styles, render_pseudo_rule))
    }

    Transform(transform) -> {
      let val_ = transform_value(transform)
      let class_ = transform_class(transform)

      case class_, val_ {
        Some(cls), Some(v) ->
          render_style(options, maybe_pseudo, "." <> cls, [
            Property("transform", v),
          ])

        _, _ -> []
      }
    }
  }
}

fn length_class_name(len: Length) -> String {
  case len {
    Px(px) -> int.to_string(px) <> "px"
    Content -> "auto"
    Fill(i) -> int.to_string(i) <> "fr"
    Min(min, l) -> "min" <> int.to_string(min) <> length_class_name(l)
    Max(max, l) -> "max" <> int.to_string(max) <> length_class_name(l)
  }
}

fn format_drop_shadow(shadow: ShadowFloat) -> String {
  string.join(
    [
      float.to_string(pair.first(shadow.offset)) <> "px",
      float.to_string(pair.second(shadow.offset)) <> "px",
      float.to_string(shadow.blur) <> "px",
      format_color(shadow.color),
    ],
    " ",
  )
}

pub fn format_text_shadow(shadow: ShadowFloat) -> String {
  string.join(
    [
      float.to_string(pair.first(shadow.offset)) <> "px",
      float.to_string(pair.second(shadow.offset)) <> "px",
      float.to_string(shadow.blur) <> "px",
      format_color(shadow.color),
    ],
    " ",
  )
}

pub fn text_shadow_class(shadow: ShadowFloat) -> String {
  string.join(
    [
      "txt",
      float_class(pair.first(shadow.offset)) <> "px",
      float_class(pair.second(shadow.offset)) <> "px",
      float_class(shadow.blur) <> "px",
      format_color_class(shadow.color),
    ],
    "",
  )
}

pub fn format_box_shadow(shadow: InsetShadow) -> String {
  string.join(
    option.values([
      case shadow.inset {
        True -> Some("inset")
        False -> None
      },
      Some(float.to_string(pair.first(shadow.offset)) <> "px"),
      Some(float.to_string(pair.second(shadow.offset)) <> "px"),
      Some(float.to_string(shadow.blur) <> "px"),
      Some(float.to_string(shadow.size) <> "px"),
      Some(format_color(shadow.color)),
    ]),
    " ",
  )
}

pub fn box_shadow_class(shadow: InsetShadow) -> String {
  string.join(
    [
      case shadow.inset {
        True -> "box-inset"
        False -> "box-"
      },
      float_class(pair.first(shadow.offset)) <> "px",
      float_class(pair.second(shadow.offset)) <> "px",
      float_class(shadow.blur) <> "px",
      float_class(shadow.size) <> "px",
      format_color_class(shadow.color),
    ],
    "",
  )
}

pub fn float_class(x: Float) -> String {
  int.to_string(float.round(x *. 255.0))
}

pub fn format_color(color: Color) -> String {
  case color {
    Rgba(red, green, blue, alpha) -> {
      let r = int.to_string(float.round(red *. 255.0))
      let g = int.to_string(float.round(green *. 255.0))
      let b = int.to_string(float.round(blue *. 255.0))
      let a = float.to_string(alpha)

      "rgba(" <> r <> "," <> g <> "," <> b <> "," <> a <> ")"
    }
    Oklch(a, b, c) ->
      "oklch("
      <> float.to_string(a)
      <> " "
      <> float.to_string(b)
      <> " "
      <> float.to_string(c)
      <> ")"
  }
}

pub fn format_color_class(color: Color) -> String {
  case color {
    Rgba(red, green, blue, alpha) -> {
      float_class(red)
      <> "-"
      <> float_class(green)
      <> "-"
      <> float_class(blue)
      <> "-"
      <> float_class(alpha)
    }
    Oklch(a, b, c) -> {
      "oklch-"
      <> float_class(a)
      <> "-"
      <> float_class(b)
      <> "-"
      <> float_class(c)
    }
  }
}

pub fn spacing_name(x: Int, y: Int) -> String {
  "spacing-" <> int.to_string(x) <> "-" <> int.to_string(y)
}

pub fn padding_name(top: Int, right: Int, bottom: Int, left: Int) -> String {
  "pad-"
  <> int.to_string(top)
  <> "-"
  <> int.to_string(right)
  <> "-"
  <> int.to_string(bottom)
  <> "-"
  <> int.to_string(left)
}

pub fn padding_name_float(
  top: Float,
  right: Float,
  bottom: Float,
  left: Float,
) -> String {
  "pad-"
  <> float_class(top)
  <> "-"
  <> float_class(right)
  <> "-"
  <> float_class(bottom)
  <> "-"
  <> float_class(left)
}

pub fn get_style_name(style: Style) -> String {
  case style {
    Shadows(name, _) -> name

    Transparency(name, _) -> name

    Style(class, _) -> class

    FontFamily(name, _) -> name

    FontSize(i) -> "font-size-" <> int.to_string(i)

    Single(class, _, _) -> class

    Colored(class, _, _) -> class

    SpacingStyle(cls, _, _) -> cls

    PaddingStyle(cls, _, _, _, _) -> cls

    BorderWidth(cls, _, _, _, _) -> cls

    GridTemplateStyle(spacing:, columns:, rows:) ->
      "grid-rows-"
      <> string.join(list.map(rows, length_class_name), "-")
      <> "-cols-"
      <> string.join(list.map(columns, length_class_name), "-")
      <> "-space-x-"
      <> length_class_name(pair.first(spacing))
      <> "-space-y-"
      <> length_class_name(pair.second(spacing))

    GridPosition(row:, col:, width:, height:) ->
      "gp grid-pos-"
      <> int.to_string(row)
      <> "-"
      <> int.to_string(col)
      <> "-"
      <> int.to_string(width)
      <> "-"
      <> int.to_string(height)

    PseudoSelector(selector, sub_style) -> {
      let name = case selector {
        Focus -> "fs"
        Hover -> "hv"
        Active -> "act"
      }

      sub_style
      |> list.map(fn(sty) {
        case get_style_name(sty) {
          "" -> ""
          style_name -> style_name <> "-" <> name
        }
      })
      |> string.join(" ")
    }

    Transform(x) -> {
      case transform_class(x) {
        Some(cls) -> cls
        None -> ""
      }
    }
  }
}

// {- Constants -}

pub fn as_grid() {
  AsGrid
}

pub fn as_row() {
  AsRow
}

pub fn as_column() {
  AsColumn
}

pub fn as_el() {
  AsEl
}

pub fn as_paragraph() {
  AsParagraph
}

pub fn as_text_column() {
  AsTextColumn
}

// {- Mapping -}

pub fn map(el: Element(msg), fn_: fn(msg) -> msg2) -> Element(msg2) {
  case el {
    Styled(styles:, html:) ->
      Styled(styles: styles, html: fn(add) {
        fn(context) { element.map(html(add)(context), fn_) }
      })

    Unstyled(html) -> Unstyled(fn(layout) { element.map(html(layout), fn_) })

    Text(str) -> Text(str)

    Empty -> Empty
  }
}

pub fn map_attr(
  attr: Attribute(aligned, msg),
  fn_: fn(msg) -> msg2,
) -> Attribute(aligned, msg2) {
  case attr {
    NoAttribute -> NoAttribute

    Describe(description) -> Describe(description)

    AlignX(x) -> AlignX(x)

    AlignY(y) -> AlignY(y)

    Width(x) -> Width(x)

    Height(x) -> Height(x)

    Class(x, y) -> Class(x, y)

    StyleClass(flag, style) -> StyleClass(flag, style)

    Nearby(location, elem) -> Nearby(location, map(elem, fn_))

    Attr(html_attr) -> Attr(map_html_attr(html_attr, fn_))

    TransformComponent(fl, trans) -> TransformComponent(fl, trans)
  }
}

pub fn map_attr_from_style(
  attr: Attribute(a, msg),
  fn_: fn(msg) -> msg2,
) -> Attribute(a, msg2) {
  case attr {
    NoAttribute -> NoAttribute

    Describe(description) -> Describe(description)

    AlignX(x) -> AlignX(x)

    AlignY(y) -> AlignY(y)

    Width(x) -> Width(x)

    Height(x) -> Height(x)

    Class(x, y) -> Class(x, y)

    // invalidation key "border-color" as opposed to "border-color-10-10-10" that will be the key for the class
    StyleClass(flag, style) -> StyleClass(flag, style)

    Nearby(location, elem) -> Nearby(location, map(elem, fn_))

    Attr(html_attr) -> Attr(map_html_attr(html_attr, fn_))

    TransformComponent(fl, trans) -> TransformComponent(fl, trans)
  }
}

fn map_html_attr(html_attr, fn_) {
  case html_attr {
    vattr.Attribute(kind:, name:, value:) ->
      vattr.Attribute(kind:, name:, value:)
    vattr.Event(
      kind:,
      name:,
      handler:,
      include:,
      prevent_default:,
      stop_propagation:,
      immediate:,
      debounce:,
      throttle:,
    ) ->
      vattr.Event(
        kind:,
        name:,
        handler: decode.map(handler, fn(handler) {
          vattr.Handler(..handler, message: fn_(handler.message))
        }),
        include:,
        prevent_default:,
        stop_propagation:,
        immediate:,
        debounce:,
        throttle:,
      )
    vattr.Property(kind:, name:, value:) -> vattr.Property(kind:, name:, value:)
  }
}

pub fn unwrap_decorations(attrs: List(Attribute(Never, Never))) -> List(Style) {
  case list.fold(attrs, #([], untransformed()), unwrap_decs_helper) {
    #(styles, transform) -> list.append([Transform(transform)], styles)
  }
}

fn unwrap_decs_helper(
  acc: #(List(Style), Transformation),
  attr: Attribute(Never, Never),
) -> #(List(Style), Transformation) {
  let #(styles, trans) = acc
  case remove_never(attr) {
    StyleClass(_, style) -> #(list.append([style], styles), trans)

    TransformComponent(flag, component) -> #(
      styles,
      compose_transformation(trans, component),
    )

    _ -> #(styles, trans)
  }
}

pub type Never

fn remove_never(style: Attribute(Never, Never)) -> Attribute(a, msg) {
  todo
  // map_attr_from_style(fn(Never, style)
}

pub fn tag(label: String, style: Style) -> Style {
  case style {
    Single(class, prop, val) -> Single(label <> "-" <> class, prop, val)

    Colored(class, prop, val) -> Colored(label <> "-" <> class, prop, val)

    Style(class, props) -> Style(label <> "-" <> class, props)

    Transparency(class, o) -> Transparency(label <> "-" <> class, o)

    x -> x
  }
}

pub fn only_styles(attr: Attribute(aligned, msg)) -> Option(Style) {
  case attr {
    StyleClass(_, style) -> Some(style)
    _ -> None
  }
}

//{- Font Adjustments -}

pub fn convert_adjustment(adjustment: Adjustment) -> ConvertedAdjustment {
  let line_height = 1.5
  let base = line_height
  let normal_descender = { line_height -. 1.0 } /. 2.0
  let old_middle = line_height /. 2.0

  let lines = [
    adjustment.capital,
    adjustment.baseline,
    adjustment.descender,
    adjustment.lowercase,
  ]

  let ascender =
    result.unwrap(list.max(lines, with: float.compare), adjustment.capital)
  let descender =
    result.unwrap(
      list.max(lines, with: order.reverse(float.compare)),
      adjustment.descender,
    )
  let new_baseline =
    lines
    |> list.filter(fn(x) { x != descender })
    |> list.max(with: order.reverse(float.compare))
    |> result.unwrap(adjustment.baseline)

  let capital_vertical = 1.0 -. ascender
  let capital_size = 1.0 /. { ascender -. new_baseline }
  let full_size = 1.0 /. { ascender -. descender }
  let full_vertical = 1.0 -. ascender
  // (old_middle - newFullMiddle) * 2

  ConvertedAdjustment(
    full: adjust(full_size, { ascender -. descender }, full_vertical),
    capital: adjust(
      capital_size,
      { ascender -. new_baseline },
      capital_vertical,
    ),
  )
}

pub type ConvertedAdjustment {
  ConvertedAdjustment(full: FontSizing, capital: FontSizing)
}

fn adjust(size: Float, height: Float, vertical: Float) -> FontSizing {
  FontSizing(vertical: vertical, height: height /. size, size: size)
}
