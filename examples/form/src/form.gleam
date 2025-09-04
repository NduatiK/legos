import gleam/float
import gleam/option.{Some}
import legos/background
import legos/border
import legos/color
import legos/ui
import legos/font
import legos/input
import legos/region
import lustre

pub fn main() {
  let app =
    lustre.simple(init, update, fn(model) {
      // ui.layout([ui.height(ui.fill())], ui.el([], view(model)))
      ui.layout(
        [
          ui.height(ui.fill()),
          ui.width(ui.fill()),
          ui.scrollbars(),
          font.family([font.typeface("Plus Jakarta Sans"), font.sans_serif()]),
          background.color(color.gray_50()),
          font.color(color.gray_800()),
        ],
        view(model),
      )
    })
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

pub type Form {
  Form(
    username: String,
    password: String,
    agree_tos: Bool,
    comment: String,
    lunch: Lunch,
    spiciness: Float,
  )
}

pub type Lunch {
  Burrito
  Taco
  Gyro
}

pub fn init(_) {
  Form(
    username: "",
    password: "",
    agree_tos: False,
    comment: "",
    lunch: Burrito,
    spiciness: 0.0,
  )
}

pub type Msg {
  Update(Form)
}

pub fn update(_model: Form, msg: Msg) -> Form {
  case msg {
    Update(new) -> new
  }
}

pub fn view(form: Form) {
  [
    ui.width(ui.maximum(ui.fill(), 800)),
    ui.center_x(),
    ui.center_y(),
    ui.spacing(36),
    ui.padding(36),
    font.size(16),
  ]
  |> ui.column([
    ui.el(
      [
        region.heading(1),
        ui.align_left(),
        font.size(36),
      ],
      ui.text("Welcome to the Stylish Elephants Lunch Emporium"),
    ),
    input.radio(
      [
        ui.spacing(12),
        background.color(color.gray_200()),
      ],
      selected: Some(form.lunch),
      on_change: fn(new) { Update(Form(..form, lunch: new)) },
      label: input.label_above(
        [
          font.size(14),
          ui.padding_xy(0, 12),
        ],
        ui.text("What would you like for lunch?"),
      ),
      options: [
        input.option(Gyro, ui.text("Gyro")),
        input.option(Burrito, ui.text("Burrito")),
        input.option(Taco, ui.text("Taco")),
      ],
    ),
    input.username(
      [
        ui.spacing(12),
        ui.below(ui.el(
          [
            font.color(color.red_500()),
            font.size(14),
            ui.align_right(),
            ui.move_down(6.0),
          ],
          ui.text("This one is wrong"),
        )),
      ],
      text: form.username,
      placeholder: Some(input.placeholder([], ui.text("username"))),
      on_change: fn(new) { Update(Form(..form, username: new)) },
      label: input.label_above([font.size(14)], ui.text("Username")),
    ),
    input.current_password(
      [ui.spacing(12)],
      text: form.password,
      placeholder: option.None,
      on_change: fn(new) { Update(Form(..form, password: new)) },
      label: input.label_above([font.size(14)], ui.text("Password")),
      show: False,
    ),
    input.multiline(
      [
        ui.height(ui.shrink()),
        ui.spacing(12),
        // -- , padding 6
      ],
      text: form.comment,
      placeholder: option.Some(input.placeholder(
        [],
        ui.text("Extra hot sauce?\n\n\nYes pls"),
      )),
      on_change: fn(new) { Update(Form(..form, comment: new)) },
      label: input.label_above([font.size(14)], ui.text("Leave a comment!")),
      spellcheck: False,
    ),
    input.checkbox(
      [],
      checked: form.agree_tos,
      on_change: fn(new) { Update(Form(..form, agree_tos: new)) },
      icon: input.default_checkbox,
      label: input.label_right([], ui.text("Agree to Terms of Service")),
    ),
    input.slider(
      [
        ui.height(ui.px(30)),
        ui.behind_content(ui.el(
          [
            ui.width(ui.fill()),
            ui.height(ui.px(2)),
            ui.center_y(),
            background.color(color.gray_300()),
            border.rounded(2),
          ],
          ui.none,
        )),
      ],
      on_change: fn(new) { Update(Form(..form, spiciness: new)) },
      label: input.label_above(
        [],
        ui.text("Spiciness: " <> float.to_string(form.spiciness)),
      ),
      min: 0.0,
      max: 3.2,
      step: option.None,
      value: form.spiciness,
      thumb: input.default_thumb(),
    ),
    input.slider(
      [
        ui.width(ui.px(40)),
        ui.height(ui.px(200)),
        ui.behind_content(ui.el(
          [
            ui.height(ui.fill()),
            ui.width(ui.px(2)),
            ui.center_x(),
            background.color(color.gray_300()),
            border.rounded(2),
          ],
          ui.none,
        )),
      ],
      on_change: fn(new) { Update(Form(..form, spiciness: new)) },
      label: input.label_above(
        [],
        ui.text("Spiciness: " <> float.to_string(form.spiciness)),
      ),
      min: 0.0,
      max: 3.2,
      step: option.None,
      value: form.spiciness,
      thumb: input.default_thumb(),
    ),
  ])
}
