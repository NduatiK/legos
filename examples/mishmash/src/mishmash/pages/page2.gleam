import legos/background
import legos/border
import legos/color
import legos/ui
import legos/font
import lustre/effect
import mishmash/colors
import mishmash/components.{divider, gutter_x, max_width}
import mishmash/fonts

pub opaque type Model {
  Model(count: Int)
}

pub fn init(_flags) {
  #(Model(0), effect.none())
}

pub opaque type Msg {
  Incr
  Decr
}

pub fn update(model: Model, msg) {
  case msg {
    Incr -> #(Model(count: model.count + 1), effect.none())
    Decr -> #(Model(count: model.count - 1), effect.none())
  }
}

pub fn view(_model: Model) {
  ui.column(
    [
      ui.height(ui.fill()),
      ui.width(ui.fill()),
      // ui.spacing(4),
    ],
    [
      // view_product(model.count),
      // ui.vspace(100),
      view_about(),
      ui.vspace(100),
      view_about_2(),
      ui.vspace(100),
      view_about_3(),
      ui.vspace(100),
    ],
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
