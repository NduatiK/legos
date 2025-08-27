import facet/background
import facet/border
import facet/color
import facet/element as ui
import facet/font
import facet/input
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import lustre
import mishmash/colors

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

type Model {
  Model(count: Int)
}

fn init(_flags) {
  Model(0)
}

type Msg {
  Incr
  Decr
}

fn update(model: Model, msg) {
  case msg {
    Incr -> Model(count: model.count + 1)
    Decr -> Model(count: model.count - 1)
  }
}

fn view(model: Model) {
  ui.column(
    [
      ui.height(ui.fill()),
      ui.width(ui.fill()),
      // ui.spacing(4),
    ],
    [
      view_header(),
      view_product(model.count),
      ui.vspace(100),
      view_about(),
      ui.vspace(100),
      view_about_2(),
    ],
  )
}

fn view_header() {
  ui.row(
    [
      ui.align_left(),
      font.medium(),
      font.size(18),
      ui.space_evenly(),
      ui.padding_xy(20, 25),
      ui.width(ui.fill() |> ui.maximum(1300)),
      ui.center_x(),
    ],
    [
      ui.row([ui.spacing(20)], [
        ui.link([], url: "", label: ui.text("Shop")),
        ui.link([], url: "", label: ui.text("Search")),
      ]),
      ui.row([ui.spacing(20)], [
        ui.link([font.semi_bold()], url: "", label: ui.text("Sign In")),
      ]),
    ],
  )
}

fn view_product(count) {
  ui.row(
    [
      ui.align_left(),
      font.medium(),
      font.size(18),
      ui.spacing(30),
      ui.padding_xy(20, 0),
      ui.width(ui.fill() |> ui.maximum(1300)),
      ui.center_x(),
    ],
    [
      ui.el(
        [
          border.rounded(12),
          ui.height(ui.fill()),
          ui.width(ui.fill_portion(3)),
          background.gradient(background.ToDegrees(320), [
            background.percent(0, colors.vibrant_yellow()),
            background.percent(60, colors.vibrant_yellow()),
            background.percent(60, colors.peach()),
          ]),
        ],
        ui.none,
      ),
      ui.el(
        [
          border.rounded(12),
          ui.height(ui.fill()),
          ui.width(ui.fill_portion(3)),
          background.color(color.gray_300()),
        ],
        ui.none,
      ),
      view_product_info(count),
    ],
  )
}

fn view_product_info(count) {
  ui.el(
    [
      border.rounded(12),
      ui.width(ui.fill_portion(2)),
      // ui.height(ui.pct_screen(80)),
    ],
    ui.column(
      [
        ui.align_left(),
        ui.width(ui.fill()),
      ],
      [
        new_badge_oval(),
        ui.vspace(30),
        title_and_description(),
        ui.vspace(30),
        product_dimensions(),
        divider(border.solid(), colors.border()),
        ui.vspace(20),
        cart_buttons(count),
        ui.vspace(20),
        product_details_card(),
        ui.vspace(16),
        sustainability_card(),
      ],
    ),
  )
}

fn new_badge_oval() {
  ui.el(
    [
      background.color(color.sky_200()),
      ui.padding_xy(15, 10),
      border.rounded_pct(50),
      font.size(10),
    ],
    ui.text("NEW"),
  )
}

fn title_and_description() {
  ui.column(
    [
      ui.spacing(4),
    ],
    [
      ui.el(
        [
          ui.align_left(),
          font.medium(),
          font.size(24),
        ],
        ui.text("Memopad"),
      ),
      ui.el(
        [
          ui.align_left(),
          font.medium(),
          font.color(color.gray_500()),
          font.size(24),
        ],
        ui.text("Our kind of waste."),
      ),
    ],
  )
}

fn product_dimensions() {
  ui.column(
    [
      ui.spacing(4),
      ui.width(ui.fill()),
      ui.padding_each(top: 0, right: 0, bottom: 15, left: 0),
    ],
    [
      ui.el(
        [
          ui.align_left(),
          font.medium(),
          font.color(color.gray_500()),
          font.size(14),
        ],
        ui.text("Size:"),
      ),
      ui.el(
        [
          ui.align_left(),
          font.semi_bold(),
          font.size(14),
        ],
        ui.text("7.5 x 7.5 cm"),
      ),
    ],
  )
}

fn divider(border_style, color) {
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

fn cart_buttons(count) {
  ui.row([ui.padding_xy(0, 15), ui.space_evenly(), ui.width(ui.fill())], [
    ui.row(
      [
        border.color(colors.border()),
        border.width(1),
        border.rounded(8),
        font.size(16),
        ui.padding(3),
        ui.spacing(16),
      ],
      [
        button(Decr, "-", enabled: count != 0),
        ui.el(
          [
            ui.center_x(),
            ui.center_y(),
            font.variant(font.tabular_numbers()),
          ],
          ui.text(int.to_string(count)),
        ),
        button(Incr, "+", enabled: True),
      ],
    ),
    primary_button(Incr, "Add to cart"),
  ])
}

fn product_details_card() {
  card([
    card_text("Product details."),
    ui.vspace(40),
    card_text("Post-industrial waste."),
    ui.vspace(16),
    card_text("Multiple sizes."),
    ui.vspace(16),
    card_text("Each one is unique."),
  ])
}

fn sustainability_card() {
  card([
    card_text("Sustainability."),
    ui.vspace(40),
    card_text("From mishmash notebooks."),
    ui.vspace(16),
    card_text("Responsible design production."),
    ui.vspace(16),
    card_text("Handmade in Portugal."),
  ])
}

fn card(children) {
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

fn card_text(label) {
  ui.el(
    [
      font.medium(),
      font.size(14),
      font.letter_spacing(0.2),
    ],
    ui.text(label),
  )
}

fn button(msg, label, enabled enabled) {
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

fn primary_button(msg, label) {
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

fn view_about() {
  let circle =
    ui.el(
      [
        ui.padding_each(top: 0, bottom: 0, left: 0, right: 4),
      ],
      ui.el(
        [
          background.color(color.sky_200()),
          ui.width(ui.px(36)),
          ui.height(ui.px(36)),
          border.rounded_pct(50),
          ui.move_down(5.0),
        ],
        ui.none,
      ),
    )

  ui.column(
    [
      ui.padding_xy(20, 0),
      ui.width(ui.fill() |> ui.maximum(1300)),
      ui.center_x(),
    ],
    [
      ui.paragraph([font.size(38), font.medium(), ui.spacing(16)], [
        ui.text(
          "One man's trash is another man's treasure. An authentic mishmash of ",
        ),
        circle,
        ui.el([font.semi_bold()], ui.text(" papers")),
        ui.text(
          ". From hard to soft, colorful to monochrome, the Memopads
    are 100% made from our production paper waste.",
        ),
      ]),
    ],
  )
}

fn view_about_2() {
  let ambassador_text =
    ui.el(
      [ui.width(ui.fill()), ui.height(ui.fill())],
      ui.column(
        [
          ui.width(ui.maximum(ui.fill(), 250)),
          ui.height(ui.fill()),
        ],
        [
          ui.paragraph([font.size(32), font.semi_bold(), ui.spacing(8)], [
            ui.text("A miscellaneous ambassador."),
          ]),
          ui.vspace(24),
          ui.paragraph(
            [
              font.size(18),

              font.medium(),
              ui.spacing(8),
            ],
            [
              ui.text(
                "Detachable sheets that result in an extrovert desk item. Ready for every phone call that might surprise you.",
              ),
            ],
          ),
          ui.column(
            [
              font.size(14),
              font.color(color.gray_800()),
              ui.spacing(14),
              ui.align_bottom(),
              ui.width(ui.fill()),
            ],
            [
              ui.text("Post-industrial waste"),
              divider(border.dashed(), color.gray_400()),
              ui.text("From mishmash notebooks"),
              divider(border.dashed(), color.gray_400()),
              ui.text(" Handmade in Portugal"),
            ],
          ),
        ],
      ),
    )

  ui.el(
    [
      ui.width(ui.fill()),
      background.color(color.sky_100()),
    ],
    ui.row(
      [
        ui.padding_xy(20, 28),
        ui.width(ui.fill() |> ui.maximum(1300)),
        ui.center_x(),
        ui.spacing(20),
      ],
      [
        ambassador_text,
        ui.el(
          [
            border.rounded(12),
            background.color(colors.vibrant_yellow()),
            ui.align_right(),
            ui.width(ui.fill()),
            ui.height(ui.pct(65)),
          ],
          ui.none,
        ),
        ui.el(
          [
            border.rounded(12),
            background.color(colors.vibrant_yellow()),
            ui.align_right(),
            ui.width(ui.fill()),
            ui.height(ui.px(600)),
          ],
          ui.none,
        ),
      ],
    ),
  )
}
