import legos/background
import legos/border
import legos/color
import legos/ui
import legos/font
import lustre

pub fn main() {
  let app =
    lustre.element(ui.layout(
      [
        ui.height(ui.fill()),
        ui.width(ui.fill()),
        ui.scrollbars(),
        font.family([font.typeface("Inter"), font.sans_serif()]),
        background.color(color.gray_50()),
        font.color(color.gray_800()),
      ],
      my_row_of_stuff(),
    ))
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

pub fn my_row_of_stuff() -> ui.Element(_) {
  ui.row(
    [
      ui.width(ui.fill()),
      ui.center_y(),
      ui.spacing(30),
      ui.padding(20),
    ],
    [
      my_element(),
      my_element(),
      ui.el([ui.align_right()], my_element()),
    ],
  )
}

pub fn my_element() -> ui.Element(_) {
  ui.el(
    [
      background.color(color.blue_500()),
      font.color(color.white()),
      border.rounded(3),
      ui.padding(30),
    ],
    ui.text("stylish!"),
  )
}
