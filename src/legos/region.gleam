import legos/internal/model as internal
import legos/ui.{type Attribute}

/// Mark an element as the main content area
pub fn main_content() -> Attribute(msg) {
  internal.Describe(internal.Main)
}

/// Mark an element as an aside/complementary content
pub fn aside() -> Attribute(msg) {
  internal.Describe(internal.Complementary)
}

/// Mark an element as navigation
pub fn navigation() -> Attribute(msg) {
  internal.Describe(internal.Navigation)
}

/// Mark an element as a footer/content info
pub fn footer() -> Attribute(msg) {
  internal.Describe(internal.ContentInfo)
}

/// Mark an element as a heading with the specified level (h1, h2, etc.)
/// This is smart enough to not conflict with existing nodes.
///
/// For example:
/// ```gleam
/// link([region.heading(1)], LinkConfig(url: "http://fruits.com", label: text("Best site ever")))
/// ```
///
/// will generate:
/// ```html
/// <a href="http://fruits.com">
///   <h1>Best site ever</h1>
/// </a>
/// ```
pub fn heading(level: Int) -> Attribute(msg) {
  internal.Describe(internal.Heading(level))
}

/// Screen readers will announce changes to this element urgently,
/// potentially interrupting other announcements
pub fn announce_urgently() -> Attribute(msg) {
  internal.Describe(internal.LiveAssertive)
}

/// Screen readers will announce changes to this element politely,
/// waiting for other announcements to finish
pub fn announce() -> Attribute(msg) {
  internal.Describe(internal.LivePolite)
}

/// Adds an aria-label for accessibility software to identify
/// otherwise unlabeled elements.
///
/// Common use case: labeling buttons that only have an icon.
pub fn description(desc: String) -> Attribute(msg) {
  internal.Describe(internal.Label(desc))
}
