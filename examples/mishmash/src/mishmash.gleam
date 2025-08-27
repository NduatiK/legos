import gleam/int
import gleam/list
import legos/background
import legos/border
import legos/color
import legos/element as ui
import legos/font
import lustre
import mishmash/colors
import mishmash/components.{button, card, card_text, divider, primary_button}
import mishmash/fonts

const max_width = 1560

const gutter_x = 20

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
          background.color(color.neutral_50()),
          font.color(color.neutral_800()),
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
      ui.vspace(100),
      view_about_3(),
      ui.vspace(100),
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
      ui.width(ui.fill() |> ui.maximum(max_width)),
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
      ui.padding_xy(gutter_x, 0),
      ui.width(ui.fill() |> ui.maximum(max_width)),
      ui.height(ui.shrink() |> ui.minimum(860)),
      ui.center_x(),
    ],
    [
      ui.el(
        [
          border.rounded(12),
          ui.height(ui.fill()),
          ui.width(ui.fill_portion(3)),
          background.gradient(background.ToDegrees(-20), [
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
          background.color(color.neutral_300()),
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
      ui.padding_xy(20, 15),
      border.rounded_pct(50),
      font.size(11),
      font.medium(),
      font.letter_spacing(1.0),
    ],
    ui.text("NEW"),
  )
}

fn title_and_description() {
  ui.column(
    [
      ui.spacing(8),
    ],
    [
      ui.el([ui.align_left(), ..fonts.heading_3()], ui.text("Memopad")),
      ui.el(
        list.append(fonts.heading_3(), [
          ui.align_left(),
          font.medium(),
          font.color(color.neutral_400()),
        ]),
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
      font.size(18),
    ],
    [
      ui.el(
        [
          ui.align_left(),
          font.color(color.neutral_500()),
          font.letter_spacing(1.0),
        ],
        ui.text("Size:"),
      ),
      ui.el(
        [
          ui.align_left(),
        ],
        ui.text("7.5 x 7.5 cm"),
      ),
    ],
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
      ui.padding_xy(gutter_x, 0),
      ui.width(ui.fill() |> ui.maximum(max_width)),
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
          ui.paragraph([ui.spacing(8), ..fonts.heading_2()], [
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
              font.color(color.neutral_800()),
              ui.spacing(14),
              ui.align_bottom(),
              ui.width(ui.fill()),
            ],
            [
              ui.text("Post-industrial waste"),
              divider(border.dashed(), color.neutral_400()),
              ui.text("From mishmash notebooks"),
              divider(border.dashed(), color.neutral_400()),
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
      border.shadow(
        color: color.neutral_100(),
        offset: #(0, 3),
        blur: 3,
        size: 0,
      ),
    ],
    ui.row(
      [
        ui.padding_xy(gutter_x, 36),
        ui.width(ui.fill() |> ui.maximum(max_width)),
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

fn view_about_3() {
  ui.column(
    [
      ui.padding_xy(gutter_x, 36),
      ui.width(ui.fill() |> ui.maximum(max_width)),
      ui.center_x(),
    ],
    [
      ui.el(fonts.heading_2(), ui.text("They're loving our products")),
      ui.vspace(140),
      ui.row([ui.spacing(50)], [
        testimonial(
          "Erika Ashford",
          "Customer",
          "I think you all have a super unique product that is great for students, especially in mathematics and STEM where we use so many graphs.",
        ),
        testimonial(
          "Lauren Brown",
          "Customer",
          "Don't think I've ever entered my card details as quickly as I just did for Emma Gannon's new writing journal. What a beautiful and useful object.",
        ),
        testimonial(
          "Sara Henriques",
          "Customer",
          "Hello, I just wanted to congratulate you on your products! I bought a Planner and I love the simplicity, design and colours! It was the first order of many!",
        ),
      ]),
    ],
  )
}

fn testimonial(name, role, quote) {
  ui.column([ui.width(ui.fill()), font.size(24), font.medium()], [
    ui.el([font.size(14)], ui.text(name)),
    ui.vspace(4),
    ui.el([font.size(14), font.color(colors.secondary_text())], ui.text(role)),
    ui.vspace(50),
    ui.el([font.color(colors.secondary_text())], ui.text("“")),
    ui.vspace(4),
    ui.paragraph([ui.spacing(10)], [
      ui.text(quote),
    ]),
  ])
}



