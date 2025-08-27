import facet/element.{type Attribute, type Element, height, shrink, width}
import facet/internal/model as internal
import facet/internal/style

/// Create a keyed element that helps optimize cases where children are getting
/// added, moved, removed, etc. Common examples include:
///
/// - The user can delete items from a list
/// - The user can create new items in a list
/// - You can sort a list based on name or date or whatever
///
/// When you use a keyed element, every child is paired with a string identifier.
/// This makes it possible for the underlying diffing algorithm to reuse nodes
/// more efficiently.
///
/// This means if a key is changed between renders, then the diffing step will
/// be skipped and the node will be forced to rerender.
pub fn el(
  attrs: List(Attribute(msg)),
  child: #(String, Element(msg)),
) -> Element(msg) {
  internal.element(
    internal.AsEl,
    internal.div,
    [width(shrink()), height(shrink()), ..attrs],
    internal.Keyed([child]),
  )
}

/// Create a keyed row layout with a list of keyed children.
/// Each child is paired with a string key for efficient diffing.
pub fn row(
  attrs: List(Attribute(msg)),
  children: List(#(String, Element(msg))),
) -> Element(msg) {
  internal.element(
    internal.AsRow,
    internal.div,
    [
      internal.html_class(
        style.classes_content_left <> " " <> style.classes_content_center_y,
      ),
      width(shrink()),
      height(shrink()),
      ..attrs
    ],
    internal.Keyed(children),
  )
}

/// Create a keyed column layout with a list of keyed children.
/// Each child is paired with a string key for efficient diffing.
pub fn column(
  attrs: List(Attribute(msg)),
  children: List(#(String, Element(msg))),
) -> Element(msg) {
  internal.element(
    internal.AsColumn,
    internal.div,
    [
      internal.html_class(
        style.classes_content_top <> " " <> style.classes_content_left,
      ),
      height(shrink()),
      width(shrink()),
      ..attrs
    ],
    internal.Keyed(children),
  )
}
