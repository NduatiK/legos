import gleam/dynamic/decode.{type Decoder}
import legos/internal/model as internal
import legos/ui.{type Attribute}
import lustre/event

// MOUSE EVENTS ----------------------------------------------------------------

/// Handle mouse down events
pub fn on_mouse_down(msg: msg) -> Attribute(msg) {
  internal.Attr(event.on_mouse_down(msg))
}

/// Handle mouse up events
pub fn on_mouse_up(msg: msg) -> Attribute(msg) {
  internal.Attr(event.on_mouse_up(msg))
}

/// Handle click events
pub fn on_click(msg: msg) -> Attribute(msg) {
  internal.Attr(event.on_click(msg))
}

/// Handle double click events
pub fn on_double_click(msg: msg) -> Attribute(msg) {
  internal.Attr(event.on("dblclick", decode.success(msg)))
}

/// Handle mouse enter events
pub fn on_mouse_enter(msg: msg) -> Attribute(msg) {
  internal.Attr(event.on_mouse_enter(msg))
}

/// Handle mouse leave events
pub fn on_mouse_leave(msg: msg) -> Attribute(msg) {
  internal.Attr(event.on_mouse_leave(msg))
}

/// Handle mouse move events
pub fn on_mouse_move(msg: msg) -> Attribute(msg) {
  internal.Attr(event.on("mousemove", decode.success(msg)))
}

// COORDINATE EVENTS -----------------------------------------------------------

pub type Coords {
  Coords(x: Int, y: Int)
}

/// Handle click events with local coordinates (relative to element)
pub fn on_click_coords(msg: fn(Coords) -> msg) -> Attribute(msg) {
  internal.Attr(
    event.on("click", {
      use x <- decode.field("offsetX", decode.int)
      use y <- decode.field("offsetY", decode.int)
      decode.success(msg(Coords(x: x, y: y)))
    }),
  )
}

/// Handle click events with screen coordinates
pub fn on_click_screen_coords(msg: fn(Coords) -> msg) -> Attribute(msg) {
  internal.Attr(
    event.on("click", {
      use x <- decode.field("screenX", decode.int)
      use y <- decode.field("screenY", decode.int)
      decode.success(msg(Coords(x: x, y: y)))
    }),
  )
}

/// Handle click events with page coordinates
pub fn on_click_page_coords(msg: fn(Coords) -> msg) -> Attribute(msg) {
  internal.Attr(
    event.on("click", {
      use x <- decode.field("pageX", decode.int)
      use y <- decode.field("pageY", decode.int)
      decode.success(msg(Coords(x: x, y: y)))
    }),
  )
}

/// Handle mouse move events with local coordinates (relative to element)
pub fn on_mouse_coords(msg: fn(Coords) -> msg) -> Attribute(msg) {
  internal.Attr(
    event.on("mousemove", {
      use x <- decode.field("offsetX", decode.int)
      use y <- decode.field("offsetY", decode.int)
      decode.success(msg(Coords(x: x, y: y)))
    }),
  )
}

/// Handle mouse move events with screen coordinates
pub fn on_mouse_screen_coords(msg: fn(Coords) -> msg) -> Attribute(msg) {
  internal.Attr(
    event.on("mousemove", {
      use x <- decode.field("screenX", decode.int)
      use y <- decode.field("screenY", decode.int)
      decode.success(msg(Coords(x: x, y: y)))
    }),
  )
}

/// Handle mouse move events with page coordinates
pub fn on_mouse_page_coords(msg: fn(Coords) -> msg) -> Attribute(msg) {
  internal.Attr(
    event.on("mousemove", {
      use x <- decode.field("pageX", decode.int)
      use y <- decode.field("pageY", decode.int)
      decode.success(msg(Coords(x: x, y: y)))
    }),
  )
}

// FOCUS EVENTS ----------------------------------------------------------------

/// Handle focus events (when element gains focus)
pub fn on_focus(msg: msg) -> Attribute(msg) {
  internal.Attr(event.on_focus(msg))
}

/// Handle blur events (when element loses focus)
pub fn on_lose_focus(msg: msg) -> Attribute(msg) {
  internal.Attr(event.on_blur(msg))
}

// CUSTOM EVENTS ---------------------------------------------------------------

/// Create a custom event listener with a decoder
/// This is equivalent to Html.Events.on in Elm
pub fn on(event_name: String, decoder: Decoder(msg)) -> Attribute(msg) {
  internal.Attr(event.on(event_name, decoder))
}

// COMMON DECODERS -------------------------------------------------------------

/// Decoder for getting the target value (event.target.value)
/// Useful for input events
pub fn target_value() -> Decoder(String) {
  decode.at(["target", "value"], decode.string)
}

/// Decoder for getting the target checked state (event.target.checked)
/// Useful for checkbox events
pub fn target_checked() -> Decoder(Bool) {
  decode.at(["target", "checked"], decode.bool)
}

/// Decoder for getting the key code (event.keyCode)
/// Note: This is deprecated in favor of event.key in modern browsers
pub fn key_code() -> Decoder(Int) {
  decode.at(["keyCode"], decode.int)
}

/// Decoder for getting the key name (event.key)
/// This is the modern way to handle keyboard events
pub fn key() -> Decoder(String) {
  decode.at(["key"], decode.string)
}

// CONVENIENCE FUNCTIONS -------------------------------------------------------

/// Handle input events with automatic value extraction
pub fn on_input(msg: fn(String) -> msg) -> Attribute(msg) {
  internal.Attr(event.on_input(msg))
}

/// Handle change events with automatic value extraction
pub fn on_change(msg: fn(String) -> msg) -> Attribute(msg) {
  internal.Attr(event.on_change(msg))
}

/// Handle checkbox change events with automatic checked state extraction
pub fn on_check(msg: fn(Bool) -> msg) -> Attribute(msg) {
  internal.Attr(event.on_check(msg))
}

/// Handle key press events with automatic key extraction
pub fn on_key_press(msg: fn(String) -> msg) -> Attribute(msg) {
  internal.Attr(event.on_keypress(msg))
}

/// Handle key down events with automatic key extraction
pub fn on_key_down(msg: fn(String) -> msg) -> Attribute(msg) {
  internal.Attr(event.on_keydown(msg))
}

/// Handle key up events with automatic key extraction
pub fn on_key_up(msg: fn(String) -> msg) -> Attribute(msg) {
  internal.Attr(event.on_keyup(msg))
}

/// Handle form submit events with automatic form data extraction
pub fn on_submit(msg: fn(List(#(String, String))) -> msg) -> Attribute(msg) {
  internal.Attr(event.on_submit(msg))
}
