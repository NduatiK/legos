import gleam/list
import gleam/option.{None, Some}
import legos/background
import legos/border
import legos/color
import legos/ui
import legos/font
import legos/input
import mishmash/colors
import mishmash/route

pub fn divider(border_style, color) {
  ui.el(
    [
      border.color(color),
      border_style,
      ui.width(ui.fill()),
      border.width_each(bottom: 1, left: 0, right: 0, top: 0),
    ],
    ui.none,
  )
}

pub fn card(children) {
  ui.column(
    [
      background.color(color.gray_100()),
      border.color(colors.border()),
      border.width(1),
      ui.padding(14),
      border.rounded(8),
      ui.width(ui.fill()),
    ],
    children,
  )
}

pub fn card_text(label) {
  ui.el(
    [
      font.medium(),
      font.size(14),
      font.letter_spacing(0.2),
    ],
    ui.text(label),
  )
}

pub fn button(msg, label, enabled enabled) {
  input.button(
    [
      ui.padding_xy(16, 8),
      ui.hovered(case enabled {
        True -> [background.color(color.gray_200())]
        False -> []
      }),
      ui.transition(["background"], 200),
      border.rounded(5),
      ..case enabled {
        True -> []
        False -> [
          ui.cursor(),
        ]
      }
    ],
    on_press: case enabled {
      True -> Some(msg)
      False -> None
    },
    label: ui.el(
      [
        ui.center_x(),
        ui.center_y(),
        case list.contains(["+", "-"], label) {
          True -> ui.move_up(1.0)
          False -> ui.attr_none()
        },
      ],
      ui.text(label),
    ),
  )
}

pub fn primary_button(msg, label) {
  input.button(
    [
      ui.padding_xy(16, 8),
      ui.hovered([background.color(color.gray_800())]),
      background.color(color.gray_900()),
      font.color(color.white()),
      border.rounded(8),
      font.size(14),
      font.letter_spacing(0.3),
    ],
    on_press: Some(msg),
    label: ui.el(
      [
        ui.center_x(),
        ui.center_y(),
      ],
      ui.text(label),
    ),
  )
}

pub const max_width = 1560

pub const gutter_x = 20

pub fn view_header() {
  ui.row(
    [
      ui.align_left(),
      font.medium(),
      font.size(18),
      ui.space_evenly(),
      ui.padding_xy(gutter_x, 25),
      ui.width(ui.fill() |> ui.maximum(max_width)),
      ui.center_x(),
    ],
    [
      ui.row([ui.spacing(20)], [
        ui.link([], url: route.to_path(route.Home), label: ui.text("Shop")),
        ui.link([], url: route.to_path(route.Page2), label: ui.text("Search")),
      ]),
      ui.row([ui.spacing(20)], [
        ui.link(
          [font.semi_bold()],
          url: route.to_path(route.Home),
          label: ui.text("Sign In"),
        ),
      ]),
    ],
  )
}
