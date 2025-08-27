import gleam/float
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import legos/internal/flag
import legos/internal/model
import legos/internal/style
import lustre/attribute as attr
import lustre/vdom/vattr
import lustre/vdom/vnode

// Element and Attribute types
pub type Color =
  model.Color

pub type Shadow =
  model.Shadow

pub type FocusStyle =
  model.FocusStyle

pub type Element(msg) =
  model.Element(msg)

pub type Attribute(msg) =
  model.Attribute(model.Aligned, msg)

pub type Attr(decorative, msg) =
  model.Attribute(decorative, msg)

pub type Decoration(a, b) =
  model.Attribute(a, b)

/// Render a Lustre element with legos
pub fn html(a: fn(model.LayoutContext) -> vnode.Element(e)) -> Element(e) {
  model.Unstyled(a)
}

/// Render a Lustre attribute with legos
pub fn html_attribute(a: vattr.Attribute(c)) -> Attr(d, c) {
  model.Attr(a)
}

pub fn map(element: Element(a), transform: fn(a) -> b) -> Element(b) {
  model.map(element, transform)
}

pub fn map_attribute(
  attribute: Attribute(a),
  transform: fn(a) -> b,
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

/// Fill a percent of the safe-viewport size
pub fn pct_screen(pct: Int) -> Length {
  model.ScreenPct(pct)
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

pub fn pct(portion: Int) -> Length {
  model.Pct(portion)
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

pub fn focus_style(style: FocusStyle) -> Opt {
  model.FocusStyleOption(style)
}

pub fn no_hover() -> Opt {
  model.HoverOption(model.NoHover)
}

pub fn force_hover() -> Opt {
  model.HoverOption(model.ForceHover)
}

// Basic elements
pub const none = model.Empty

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
        model.AsRow,
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
            model.AsRow,
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
            model.AsEl,
            model.div,
            attrs,
            model.Unkeyed([
              model.element(
                model.AsRow,
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

pub fn prose(
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
pub type TableColumn(data, msg) {
  TableColumn(
    //
    header: Element(msg),
    width: Length,
    view: fn(data) -> Element(msg),
  )
}

pub type IndexedColumn(data, msg) {
  IndexedColumn(
    header: Element(msg),
    width: Length,
    view: fn(Int, data) -> Element(msg),
  )
}

type InternalTableColumn(record, msg) {
  InternalIndexedColumn(IndexedColumn(record, msg))
  InternalColumn(TableColumn(record, msg))
}

/// Show some tabular data.
///
/// Start with a list of records and specify how each column should be rendered.
///
/// So, if we have a list of `persons`:
///
///     type Person {
///       Person(first_name: String, last_name: String)
///     }
///
///     let persons = [
///       Person("David", "Bowie"),
///       Person("Florence", "Welch"),
///     ]
///
/// We could render it using
///
///     table([],
///         data: persons,
///         columns: [
///           Column(
///             header: Element.text("First Name"),
///             width: fill(),
///             view: fn(person) { Element.text(person.first_name) },
///           ),
///           Column(
///             header: Element.text("Last Name"),
///             width: fill(),
///             view: fn(person) { Element.text(person.last_name) },
///           ),
///         ]),
///
/// **Note:** Sometimes you might not have a list of records directly in your model. In this case it can be really nice to write a function that transforms some part of your model into a list of records before feeding it into `Element.table`.
pub fn table(
  attrs: List(Attribute(msg)),
  data data: List(data),
  columns columns: List(TableColumn(data, msg)),
) -> Element(msg) {
  table_helper(attrs, data, list.map(columns, InternalColumn))
}

pub fn indexed_table(
  attributes: List(Attribute(msg)),
  data data: List(data),
  columns columns: List(IndexedColumn(data, msg)),
) -> Element(msg) {
  table_helper(attributes, data, list.map(columns, InternalIndexedColumn))
}

type Cursor(a) {
  Cursor(elements: List(a), row: Int, column: Int)
}

fn table_helper(
  attrs: List(Attribute(msg)),
  data: List(data),
  columns: List(InternalTableColumn(data, msg)),
) -> Element(msg) {
  let #(s_x, s_y) = model.get_spacing(attrs, #(0, 0))

  let column_header = fn(col) {
    case col {
      InternalIndexedColumn(col_config) -> col_config.header
      InternalColumn(col_config) -> col_config.header
    }
  }

  let column_width = fn(col) {
    case col {
      InternalIndexedColumn(col_config) -> col_config.width
      InternalColumn(col_config) -> col_config.width
    }
  }

  let on_grid = fn(row_level, column_level, elem) {
    model.element(
      model.AsEl,
      model.div,
      [
        model.StyleClass(
          flag.grid_position(),
          model.GridPosition(
            row: row_level,
            col: column_level,
            width: 1,
            height: 1,
          ),
        ),
      ],
      model.Unkeyed([elem]),
    )
  }
  let maybe_headers =
    columns
    |> list.map(column_header)
    |> fn(headers) {
      case list.all(headers, fn(a) { a == model.Empty }) {
        True -> None
        False ->
          Some(
            list.index_map(headers, fn(header, col) {
              on_grid(1, col + 1, header)
            }),
          )
      }
    }

  let template =
    model.StyleClass(
      flag.grid_template(),
      model.GridTemplateStyle(
        spacing: #(px(s_x), px(s_y)),
        columns: list.map(columns, column_width),
        rows: list.repeat(model.Content, list.length(data)),
      ),
    )

  let add = fn(cell, column_config, cursor) {
    case column_config {
      InternalIndexedColumn(col) -> {
        Cursor(
          ..cursor,
          elements: [
            on_grid(
              cursor.row,
              cursor.column,
              col.view(
                case maybe_headers == None {
                  True -> cursor.row - 1
                  False -> cursor.row - 2
                },
                cell,
              ),
            ),
            ..cursor.elements
          ],
          column: cursor.column + 1,
        )
      }
      InternalColumn(col) -> {
        Cursor(
          ..cursor,
          elements: [
            on_grid(cursor.row, cursor.column, col.view(cell)),
            ..cursor.elements
          ],
          column: cursor.column + 1,
        )
      }
    }
  }

  let build = fn(columns) {
    fn(cursor: Cursor(Element(msg)), row_data: data) -> Cursor(Element(msg)) {
      let new_cursor =
        list.fold(columns, cursor, fn(cursor, column) {
          add(row_data, column, cursor)
        })
      Cursor(elements: new_cursor.elements, row: cursor.row + 1, column: 1)
    }
  }
  let starting_row = case maybe_headers == None {
    True -> 1
    False -> 2
  }

  let children =
    list.fold(
      data,
      Cursor(elements: [], row: starting_row, column: 1),
      build(columns),
    )

  model.element(
    model.AsGrid,
    model.div,
    list.append([width(fill()), template], attrs),
    model.Unkeyed(case maybe_headers {
      None -> children.elements
      Some(rendered_headers) ->
        list.append(rendered_headers, list.reverse(children.elements))
    }),
  )
}

/// Both a source and a description are required for images.
///
/// The description is used for people using screen readers.
///
/// Leaving the description blank will cause the image to be ignored by assistive technology. This can make sense for images that are purely decorative and add no additional information.
///
/// So, take a moment to describe your image as you would to someone who has a harder time seeing.
pub fn image(
  attributes: List(Attribute(msg)),
  src src: String,
  description description: String,
) -> Element(msg) {
  let image_attributes =
    list.filter(attributes, fn(a) {
      case a {
        model.Width(_) -> True
        model.Height(_) -> True
        _ -> False
      }
    })

  model.element(
    model.AsEl,
    model.div,
    [model.html_class(style.classes_image_container), ..attributes],
    model.Unkeyed([
      model.element(
        model.AsEl,
        model.NodeName("img"),
        [
          model.Attr(attr.src(src)),
          model.Attr(attr.alt(description)),
          ..image_attributes
        ],
        model.Unkeyed([]),
      ),
    ]),
  )
}

pub fn link(
  attributes: List(Attribute(msg)),
  url url: String,
  label label: Element(msg),
) -> Element(msg) {
  model.element(
    model.AsEl,
    model.NodeName("a"),
    list.append(
      [
        model.Attr(attr.href(url)),
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
    model.Unkeyed([label]),
  )
}

pub fn new_tab_link(
  attributes: List(Attribute(msg)),
  url url: String,
  label label: Element(msg),
) -> Element(msg) {
  model.element(
    model.AsEl,
    model.NodeName("a"),
    list.append(
      [
        model.Attr(attr.href(url)),
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
    model.Unkeyed([label]),
  )
}

// Nearby elements
pub fn below(element: Element(msg)) -> Attribute(msg) {
  model.Nearby(model.Below, element)
}

pub fn attr_none() -> Attribute(msg) {
  model.NoAttribute
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
  case x == y {
    True -> padding(x)
    False -> {
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
  }
}

/// If you find yourself defining unique paddings all the time, you might consider defining
///
///     edges =
///         (
///             top: 0,
///             right: 0,
///             bottom: 0,
///             left: 0,
///         )
///
/// And then just do
///
///     paddingEach(edges |> { .._, right: 5 })
pub fn padding_each(
  top top: Int,
  right right: Int,
  bottom bottom: Int,
  left left: Int,
) -> Attribute(msg) {
  case top == right && top == bottom && top == left {
    True -> {
      let top_float = int.to_float(top)

      model.StyleClass(
        flag.padding(),
        model.PaddingStyle(
          "p-" <> int.to_string(top),
          top_float,
          top_float,
          top_float,
          top_float,
        ),
      )
    }
    False ->
      model.StyleClass(
        flag.padding(),
        model.PaddingStyle(
          model.padding_name(top, right, bottom, left),
          int.to_float(top),
          int.to_float(right),
          int.to_float(bottom),
          int.to_float(left),
        ),
      )
  }
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

pub fn transition(properties, duration_ms) -> Attribute(msg) {
  model.StyleClass(
    flag.transition(),
    model.Single(
      "transition-"
        <> string.join(properties, "-")
        <> "-"
        <> int.to_string(duration_ms),
      "transition",
      string.join(properties, ", ") <> " " <> int.to_string(duration_ms) <> "ms",
    ),
  )
}

// Transparency and opacity
pub fn transparent(is_transparent: Bool) -> Attribute(msg) {
  case is_transparent {
    True -> alpha(0.0)
    False -> alpha(1.0)
  }
}

pub fn alpha(o: Float) -> Attribute(msg) {
  let transparency =
    o
    |> float.max(0.0)
    |> float.min(1.0)
    |> fn(x) { 1.0 -. x }

  model.StyleClass(
    flag.transparency(),
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

pub fn cursor() -> Attribute(msg) {
  model.Class(flag.cursor(), style.classes_cursor_text)
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

pub fn hovered(decs) -> Attribute(msg) {
  model.StyleClass(
    flag.hover(),
    model.PseudoSelector(model.Hover, model.unwrap_decorations(decs)),
  )
}

// HTML integration

pub fn vspace(height_: Int) -> Element(g) {
  el([width(fill()), height(px(height_))], none)
}

pub fn hspace(width_: Int) -> Element(f) {
  el([height(fill()), width(px(width_))], none)
}

// Placeholder types for HTML integration (would need proper HTML library)
pub type Html(msg)

pub type HtmlAttribute(msg)
