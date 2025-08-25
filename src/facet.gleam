import facet/background
import facet/border
import facet/color
import facet/element as ui
import facet/font
import facet/input
import gleam/int
import gleam/option.{Some}
import lustre

pub fn main() {
  let app =
    lustre.simple(init, update, fn(model) {
      // ui.layout([ui.height(ui.fill())], ui.el([], view(model)))
      ui.layout(
        [
          ui.height(ui.fill()),
          ui.width(ui.fill()),
          font.family([font.sans_serif()]),
          background.color(color.gray_100()),
        ],
        view(model),
      )
    })
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

fn init(_flags) {
  0
}

type Msg {
  Incr
  Decr
}

fn update(model, msg) {
  case msg {
    Incr -> model + 1
    Decr -> model - 1
  }
}

fn view(model) {
  let count = int.to_string(model)

  ui.row(
    [
      ui.height(ui.fill()),
      ui.width(ui.fill()),
      ui.center_x(),
      ui.center_y(),

      ui.spacing(10),
    ],
    [
      input.button(
        [ui.padding_xy(10, 4), border.width(1), border.color(color.gray_200())],
        on_press: Some(Decr),
        label: ui.text("-"),
      ),
      ui.el(
        [
          border.solid(),
          border.width(1),
          ui.padding_xy(10, 4),
          border.rounded(4),
          background.color(color.white()),
        ],
        ui.text(count),
      ),
      input.button(
        [ui.padding_xy(10, 4), border.width(1), border.color(color.gray_200())],
        on_press: Some(Incr),
        label: ui.text("+"),
      ),
    ],
  )
}
