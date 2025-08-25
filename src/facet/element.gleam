import facet/internal/flag
import facet/internal/model.{type FocusStyle}
import facet/internal/style
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import lustre/attribute as attr
import lustre/vdom/vattr
import lustre/vdom/vnode

// Element and Attribute types
pub type Color =
  model.Color

pub type Element(msg) =
  model.Element(msg)

pub type Attribute(msg) =
  model.Attribute(model.Aligned, msg)

pub type Attr(decorative, msg) =
  model.Attribute(decorative, msg)

pub type Decoration =
  model.Attribute(model.Never, model.Never)

pub fn html(a: fn(model.LayoutContext) -> vnode.Element(e)) -> Element(e) {
  model.Unstyled(a)
}

pub fn html_attribute(a: vattr.Attribute(c)) -> Attr(d, c) {
  model.Attr(a)
}

pub fn map(transform: fn(a) -> b, element: Element(a)) -> Element(b) {
  model.map(element, transform)
}

pub fn map_attribute(
  transform: fn(a) -> b,
  attribute: Attribute(a),
) -> Attribute(b) {
  model.map_attr(attribute, transform)
}

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

pub fn minimum(length: Length, min_length: Int) -> Length {
  model.Min(min_length, length)
}

pub fn maximum(length: Length, max_length: Int) -> Length {
  model.Max(max_length, length)
}

pub fn fill_portion(portion: Int) -> Length {
  model.Fill(portion)
}

// Layout functions
pub fn layout(
  attributes: List(Attribute(msg)),
  child: Element(msg),
) -> vnode.Element(msg) {
  layout_with([], attributes, child)
}

pub fn layout_with(
  options: List(Opt),
  attributes: List(Attribute(msg)),
  child: Element(msg),
) -> vnode.Element(msg) {
  model.render_root(
    options,
    list.flatten([
      [
        model.html_class(string.join(
          [
            style.classes_root,
            style.classes_any,
            style.classes_single,
          ],
          " ",
        )),
      ],
      model.root_style(),
      attributes,
    ]),
    child,
  )
}

// Option types
pub type Opt =
  model.Opt

pub fn no_static_style_sheet() -> Opt {
  model.RenderModeOption(model.NoStaticStyleSheet)
}

pub fn default_focus() -> FocusStyle {
  model.focus_default_style
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

pub fn el(attributes: List(Attribute(msg)), child: Element(msg)) -> Element(msg) {
  model.element(model.AsEl, model.div, attributes, model.Unkeyed([child]))
}

pub fn row(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  model.element(
    model.AsRow,
    model.div,
    list.append(
      [
        model.html_class(
          style.classes_content_left <> " " <> style.classes_content_center_x,
        ),
        width(shrink()),
        height(shrink()),
      ],
      attributes,
    ),
    model.Unkeyed(children),
  )
}

pub fn column(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  model.element(
    model.AsColumn,
    model.div,
    list.append(
      [
        model.html_class(
          style.classes_content_top <> " " <> style.classes_content_left,
        ),
        width(shrink()),
        height(shrink()),
      ],
      attributes,
    ),
    model.Unkeyed(children),
  )
}

pub fn wrapped_row(
  attrs: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  let #(padded, spaced) = model.extract_spacing_and_padding(attrs)
  case spaced {
    None ->
      model.element(
        model.as_row(),
        model.div,
        list.flatten([
          [
            model.html_class(
              style.classes_content_left
              <> " "
              <> style.classes_content_center_y
              <> " "
              <> style.classes_wrapped,
            ),
            width(shrink()),
            height(shrink()),
          ],
          attrs,
        ]),
        model.Unkeyed(children),
      )
    Some(model.Spaced(space_name, x, y)) -> {
      let new_padding = case padded {
        Some(model.Padding(_name, t, r, b, l)) ->
          case
            r >=. { int.to_float(x) /. 2.0 } && b >=. { int.to_float(y) /. 2.0 }
          {
            True -> {
              let new_top = t -. { int.to_float(y) /. 2.0 }
              let new_right = r -. { int.to_float(x) /. 2.0 }
              let new_bottom = b -. { int.to_float(y) /. 2.0 }
              let new_left = l -. { int.to_float(x) /. 2.0 }
              Some(model.StyleClass(
                flag.padding(),
                model.PaddingStyle(
                  model.padding_name_float(
                    new_top,
                    new_right,
                    new_bottom,
                    new_left,
                  ),
                  new_top,
                  new_right,
                  new_bottom,
                  new_left,
                ),
              ))
            }
            False -> None
          }
        None -> None
      }
      case new_padding {
        Some(pad) ->
          model.element(
            model.as_row(),
            model.div,
            list.flatten([
              [
                model.html_class(
                  style.classes_content_left
                  <> " "
                  <> style.classes_content_center_y
                  <> " "
                  <> style.classes_wrapped,
                ),
                width(shrink()),
                height(shrink()),
              ],
              attrs,
              [pad],
            ]),
            model.Unkeyed(children),
          )
        None -> {
          let half_x = 0.0 -. { int.to_float(x) /. 2.0 }
          let half_y = 0.0 -. { int.to_float(y) /. 2.0 }
          model.element(
            model.as_el(),
            model.div,
            attrs,
            model.Unkeyed([
              model.element(
                model.as_row(),
                model.div,
                list.flatten([
                  [
                    model.html_class(
                      style.classes_content_left
                      <> " "
                      <> style.classes_content_center_y
                      <> " "
                      <> style.classes_wrapped,
                    ),
                    model.Attr(attr.style(
                      "margin",
                      float.to_string(half_y)
                        <> "px "
                        <> float.to_string(half_x)
                        <> "px",
                    )),
                    model.Attr(attr.style(
                      "width",
                      "calc(100% + " <> int.to_string(x) <> "px)",
                    )),
                    model.Attr(attr.style(
                      "height",
                      "calc(100% + " <> int.to_string(y) <> "px)",
                    )),
                    model.StyleClass(
                      flag.spacing(),
                      model.SpacingStyle(space_name, x, y),
                    ),
                  ],
                ]),
                model.Unkeyed(children),
              ),
            ]),
          )
        }
      }
    }
  }
}

pub fn paragraph(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  model.element(
    model.AsParagraph,
    model.div,
    list.append(
      [model.Describe(model.Paragraph), width(fill()), spacing(5)],
      attributes,
    ),
    model.Unkeyed(children),
  )
}

pub fn text_column(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  model.element(
    model.AsTextColumn,
    model.div,
    list.append(
      [
        width(
          fill()
          |> minimum(500)
          |> maximum(750),
        ),
      ],
      attributes,
    ),
    model.Unkeyed(children),
  )
}

// Table types and functions
pub type Column(data, msg) {
  Column(header: Element(msg), width: Length, view: fn(data) -> Element(msg))
}

// pub fn table(
//   attributes: List(Attribute(msg)),
//   config: TableConfig(data, msg),
// ) -> Element(msg) {
//   table_helper(config.data, config.columns, attributes)
// }

// pub type IndexedColumn(data, msg) {
//   IndexedColumn(
//     header: Element(msg),
//     width: Length,
//     view: fn(Int, data) -> Element(msg),
//   )
// }

// pub fn indexed_table(
//   attributes: List(Attribute(msg)),
//   config: IndexedTableConfig(data, msg),
// ) -> Element(msg) {
//   indexed_table_helper(config.data, config.columns, attributes)
// }

// pub type TableConfig(data, msg) {
//   TableConfig(data: List(data), columns: List(Column(data, msg)))
// }

// pub type IndexedTableConfig(data, msg) {
//   IndexedTableConfig(data: List(data), columns: List(IndexedColumn(data, msg)))
// }

// // fn table_helper(
// //   data: List(data),
// //   columns: List(Column(data, msg)),
// //   attributes: List(Attribute(msg)),
// // ) -> Element(msg) {
// //   el(attributes, text("Table implementation needed"))
// // }
// //

// type Cursor(a) {
//   Cursor(elements: List(a), row: Int, column: Int)
// }

// pub fn table_helper(
//   attrs: List(Attribute(msg)),
//   config: InternalTable(data, msg),
// ) -> Element(msg) {
//   let #(s_x, s_y) = model.get_spacing(attrs, #(0, 0))

//   let column_header = fn(col) {
//     case col {
//       InternalIndexedColumn(col_config) -> col_config.header
//       InternalColumn(col_config) -> col_config.header
//     }
//   }

//   let column_width = fn(col) {
//     case col {
//       InternalIndexedColumn(col_config) -> col_config.width
//       InternalColumn(col_config) -> col_config.width
//     }
//   }

//   let on_grid = fn(row_level, column_level, elem) {
//     model.element(
//       model.as_el(),
//       model.div,
//       [
//         model.StyleClass(
//           flag.gridPosition(),
//           model.GridPosition(
//             row: row_level,
//             col: column_level,
//             width: 1,
//             height: 1,
//           ),
//         ),
//       ],
//       model.Unkeyed([elem]),
//     )
//   }
//   let maybe_headers =
//     column_header(config.columns)
//     |> List.map(column_header)
//     |> fn(headers) {
//       case List.all(headers, fn(a) { a == model.Empty }) {
//         True -> None
//         False ->
//           Some(list.index_map(
//             fn(header, col) { on_grid(1, col + 1, header) },
//             headers,
//           ))
//       }
//     }

//   let template =
//     model.StyleClass(
//       flag.gridTemplate(),
//       model.GridTemplateStyle(
//         spacing: #(px(s_x), px(s_y)),
//         columns: list.map(config.columns, column_width),
//         rows: list.repeat(model.Content, list.length(config.data)),
//       ),
//     )

//   let add = fn(cell, columnConfig, cursor) {
//     case columnConfig {
//       InternalIndexedColumn(col) -> {
//         Cursor(
//           ..cursor,
//           elements: [
//             on_grid(
//               cursor.row,
//               cursor.column,
//               col.view(
//                 case maybe_headers == None {
//                   True -> cursor.row - 1
//                   False -> cursor.row - 2
//                 },
//                 cell,
//               ),
//             ),
//             ..cursor.elements
//           ],
//           column: cursor.column + 1,
//         )
//       }
//       InternalColumn(col) -> {
//         Cursor(
//           ..cursor,
//           elements: [
//             on_grid(cursor.row, cursor.column, col.view(cell)),
//             ..cursor.elements
//           ],
//           column: cursor.column + 1,
//         )
//       }
//     }
//   }

//   let build = fn(columns) {
//     fn(row_data, cursor) {
//       let new_cursor =
//         list.fold(columns, cursor, fn(a, b) { add(row_data, a, b) })
//       Cursor(..new_cursor, row: new_cursor.row + 1, column: 1)
//     }
//   }
//   let starting_row = case maybe_headers == None {
//     True -> 1
//     False -> 2
//   }

//   let children =
//     list.fold(
//       config.data,
//       Cursor(elements: [], row: starting_row, column: 1),
//       build(config.columns),
//     )

//   model.element(
//     model.asGrid,
//     model.div,
//     list.append([width(fill()), template], attrs),
//     model.Unkeyed(case maybe_headers {
//       None -> children.elements
//       Some(renderedHeaders) ->
//         list.append(renderedHeaders, list.reverse(children.elements))
//     }),
//   )
// }

// fn indexed_table_helper(
//   data: List(data),
//   columns: List(IndexedColumn(data, msg)),
//   attributes: List(Attribute(msg)),
// ) -> Element(msg) {
//   el(attributes, text("Indexed table implementation needed"))
// }

// // Image and link functions
// pub fn image(
//   attributes: List(Attribute(msg)),
//   config: ImageConfig,
// ) -> Element(msg) {
//   model.element(
//     model.AsEl,
//     model.NodeName("img"),
//     list.append(
//       [model.Attr("src", config.src), model.Attr("alt", config.description)],
//       attributes,
//     ),
//     model.Unkeyed([]),
//   )
// }

// pub type ImageConfig {
//   ImageConfig(src: String, description: String)
// }

pub fn link(
  attributes: List(Attribute(msg)),
  config: LinkConfig(msg),
) -> Element(msg) {
  model.element(
    model.AsEl,
    model.NodeName("a"),
    // list.append([], attributes),
    list.append(
      [
        model.Attr(attr.href(config.url)),
        model.Attr(attr.rel("noopener noreferrer")),
        width(shrink()),
        height(shrink()),
        model.html_class(
          style.classes_content_center_y
          <> " "
          <> style.classes_content_center_x
          <> " "
          <> style.classes_link,
        ),
      ],
      attributes,
    ),
    model.Unkeyed([config.label]),
  )
}

pub fn new_tab_link(
  attributes: List(Attribute(msg)),
  config: LinkConfig(msg),
) -> Element(msg) {
  model.element(
    model.AsEl,
    model.NodeName("a"),
    list.append(
      [
        model.Attr(attr.href(config.url)),
        model.Attr(attr.rel("noopener noreferrer")),
        model.Attr(attr.target("_blank")),
        width(shrink()),
        height(shrink()),
        model.html_class(
          style.classes_content_center_y
          <> " "
          <> style.classes_content_center_x
          <> " "
          <> style.classes_link,
        ),
      ],
      attributes,
    ),
    model.Unkeyed([config.label]),
  )
}

pub type LinkConfig(msg) {
  LinkConfig(url: String, label: Element(msg))
}

// Nearby elements
pub fn below(element: Element(msg)) -> Attribute(msg) {
  model.Nearby(model.Below, element)
}

pub fn above(element: Element(msg)) -> Attribute(msg) {
  model.Nearby(model.Above, element)
}

pub fn on_right(element: Element(msg)) -> Attribute(msg) {
  model.Nearby(model.OnRight, element)
}

pub fn on_left(element: Element(msg)) -> Attribute(msg) {
  model.Nearby(model.OnLeft, element)
}

pub fn in_front(element: Element(msg)) -> Attribute(msg) {
  model.Nearby(model.InFront, element)
}

pub fn behind_content(element: Element(msg)) -> Attribute(msg) {
  model.Nearby(model.Behind, element)
}

// Sizing attributes
pub fn width(length: Length) -> Attribute(msg) {
  model.Width(length)
}

pub fn height(length: Length) -> Attribute(msg) {
  model.Height(length)
}

// Transform attributes
pub fn scale(factor: Float) -> Attribute(msg) {
  model.TransformComponent(flag.scale(), model.Scale(#(factor, factor, 1.0)))
}

pub fn rotate(angle: Float) -> Attribute(msg) {
  model.TransformComponent(flag.rotate(), model.Rotate(#(0.0, 0.0, 1.0), angle))
}

pub fn move_up(distance: Float) -> Attribute(msg) {
  model.TransformComponent(flag.move_y(), model.MoveY(0.0 -. distance))
}

pub fn move_down(distance: Float) -> Attribute(msg) {
  model.TransformComponent(flag.move_y(), model.MoveY(distance))
}

pub fn move_right(distance: Float) -> Attribute(msg) {
  model.TransformComponent(flag.move_x(), model.MoveX(distance))
}

pub fn move_left(distance: Float) -> Attribute(msg) {
  model.TransformComponent(flag.move_x(), model.MoveX(0.0 -. distance))
}

// Spacing and padding
pub fn padding(pixels: Int) -> Attribute(msg) {
  let p = int.to_float(pixels)
  model.StyleClass(
    flag.padding(),
    model.PaddingStyle("p-" <> int.to_string(pixels), p, p, p, p),
  )
}

pub fn padding_xy(x: Int, y: Int) -> Attribute(msg) {
  let x_float = int.to_float(x)
  let y_float = int.to_float(y)
  model.StyleClass(
    flag.padding(),
    model.PaddingStyle(
      "p-" <> int.to_string(x) <> "-" <> int.to_string(y),
      y_float,
      x_float,
      y_float,
      x_float,
    ),
  )
}

pub fn padding_each(config: PaddingConfig) -> Attribute(msg) {
  model.StyleClass(
    flag.padding(),
    model.PaddingStyle(
      model.padding_name(config.top, config.right, config.bottom, config.left),
      int.to_float(config.top),
      int.to_float(config.right),
      int.to_float(config.bottom),
      int.to_float(config.left),
    ),
  )
}

pub type PaddingConfig {
  PaddingConfig(top: Int, right: Int, bottom: Int, left: Int)
}

// Alignment

pub fn center_x() -> Attribute(msg) {
  model.AlignX(model.CenterX)
}

pub fn center_y() -> Attribute(msg) {
  model.AlignY(model.CenterY)
}

pub fn align_top() -> Attribute(msg) {
  model.AlignY(model.Top)
}

pub fn align_bottom() -> Attribute(msg) {
  model.AlignY(model.Bottom)
}

pub fn align_left() -> Attribute(msg) {
  model.AlignX(model.Left)
}

pub fn align_right() -> Attribute(msg) {
  model.AlignX(model.Right)
}

pub fn space_evenly() -> Attribute(msg) {
  model.Class(flag.spacing(), style.classes_space_evenly)
}

pub fn spacing(pixels: Int) -> Attribute(msg) {
  model.StyleClass(
    flag.spacing(),
    model.SpacingStyle(model.spacing_name(pixels, pixels), pixels, pixels),
  )
}

pub fn spacing_xy(x: Int, y: Int) -> Attribute(msg) {
  model.StyleClass(
    flag.spacing(),
    model.SpacingStyle(model.spacing_name(x, y), x, y),
  )
}

// Transparency and opacity
pub fn transparent(is_transparent: Bool) -> Attribute(msg) {
  case is_transparent {
    True -> alpha(0.0)
    False -> alpha(1.0)
  }
}

// pub fn alpha(opacity: Float) -> Attribute(msg) {
//   model.StyleClass(flag.transparency(), model.Transparency(opacity))
// }

pub fn alpha(o: Float) -> Attribute(msg) {
  let transparency =
    o
    |> float.max(0.0)
    |> float.min(1.0)
    |> fn(x) { 1.0 -. x }

  model.StyleClass(
    flag.transparency(),
    // TODO: Look into this
    model.Transparency("transparency-" <> model.float_class(o), transparency),
  )
}

// Scrollbars and clipping
pub fn scrollbars() -> Attribute(msg) {
  model.Class(flag.overflow(), style.classes_scrollbars)
}

pub fn scrollbar_y() -> Attribute(msg) {
  model.Class(flag.overflow(), style.classes_scrollbars_y)
}

pub fn scrollbar_x() -> Attribute(msg) {
  model.Class(flag.overflow(), style.classes_scrollbars_x)
}

pub fn clip() -> Attribute(msg) {
  model.Class(flag.overflow(), style.classes_clip)
}

pub fn clip_y() -> Attribute(msg) {
  model.Class(flag.overflow(), style.classes_clip_y)
}

pub fn clip_x() -> Attribute(msg) {
  model.Class(flag.overflow(), style.classes_clip_x)
}

// Pointer and cursor
pub fn pointer() -> Attribute(msg) {
  model.Class(flag.cursor(), style.classes_cursor_pointer)
}

// Device classification
pub type Device {
  Device(class: DeviceClass, orientation: Orientation)
}

pub type DeviceClass {
  Phone
  Tablet
  Desktop
  BigDesktop
}

pub type Orientation {
  Portrait
  Landscape
}

pub fn classify_device(window: WindowSize) -> Device {
  let long_side = int.max(window.width, window.height)
  let short_side = int.min(window.width, window.height)

  let class = case True {
    _ if short_side < 600 -> Phone
    _ if long_side <= 1200 -> Tablet
    _ if long_side > 1200 && long_side <= 1920 -> Desktop
    _ -> BigDesktop
  }

  let orientation = case window.width > window.height {
    True -> Landscape
    False -> Portrait
  }

  Device(class, orientation)
}

pub type WindowSize {
  WindowSize(width: Int, height: Int)
}

// Scale function for responsive design
pub fn modular(ratio: Float, base: Float) -> fn(Int) -> Float {
  fn(step: Int) {
    case float.power(ratio, int.to_float(step)) {
      Ok(a) -> base *. a
      Error(_) -> 1.0
    }
  }
}

// Pseudo-class attributes
pub fn mouse_over(decs) -> Attribute(msg) {
  model.StyleClass(
    flag.hover(),
    model.PseudoSelector(model.Hover, model.unwrap_decorations(decs)),
  )
}

pub fn mouse_down(decs) -> Attribute(msg) {
  model.StyleClass(
    flag.active(),
    model.PseudoSelector(model.Active, model.unwrap_decorations(decs)),
  )
}

pub fn focused(decs) -> Attribute(msg) {
  model.StyleClass(
    flag.focus(),
    model.PseudoSelector(model.Focus, model.unwrap_decorations(decs)),
  )
}

// HTML integration

// Placeholder types for HTML integration (would need proper HTML library)
pub type Html(msg)

pub type HtmlAttribute(msg)
