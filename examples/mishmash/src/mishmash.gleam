import gleam/result
import gleam/uri
import legos/background
import legos/color
import legos/element as ui
import legos/font
import lustre
import lustre/attribute
import lustre/effect
import lustre/element/html
import mishmash/components
import mishmash/pages/home
import mishmash/pages/page2
import mishmash/route.{type Route}
import modem

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

pub type Model {
  Model(page: Page)
}

pub type Page {
  HomeModel(home.Model)
  Page2Model(page2.Model)
}

pub fn init(_) -> #(Model, effect.Effect(Msg)) {
  let model =
    modem.initial_uri()
    |> result.map(fn(uri) { uri.path_segments(uri.path) })
    |> fn(path) {
      case path {
        // Ok(["wibble"]) -> Wibble
        // Ok(["wobble"]) -> Wobble
        _ -> HomeModel(home.init(Nil))
      }
    }

  echo #(Model(page: model), modem.init(on_url_change))
}

fn on_url_change(uri: uri.Uri) -> Msg {
  OnRouteChange(route.from_uri(uri))
}

pub type Msg {
  OnRouteChange(Route)
  HomeMsg(home.Msg)
  Page2Msg(page2.Msg)
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg, model.page {
    OnRouteChange(route), _ ->
      case route {
        route.Home -> #(Model(HomeModel(home.init(Nil))), effect.none())
        route.Page2 -> #(Model(Page2Model(page2.init(Nil))), effect.none())
      }

    HomeMsg(msg), HomeModel(page) -> #(
      Model(HomeModel(home.update(page, msg))),
      effect.none(),
    )

    Page2Msg(msg), Page2Model(page) -> #(
      Model(Page2Model(page2.update(page, msg))),
      effect.none(),
    )
    _, _ -> #(model, effect.none())
  }
}

fn view(model: Model) {
  html.div([], [
    html.nav([], [
      // html.a([attribute.href("/wobble")], [element.text("Go to wobble")]),
    ]),
    ui.layout(
      [
        ui.height(ui.fill()),
        ui.width(ui.fill()),
        ui.scrollbars(),
        font.family([font.typeface("Plus Jakarta Sans"), font.sans_serif()]),
        background.color(color.neutral_50()),
        font.color(color.neutral_800()),
      ],
      ui.column(
        [
          ui.height(ui.fill()),
          ui.width(ui.fill()),
          // ui.spacing(4),
        ],
        [
          components.view_header(),
          case model.page {
            HomeModel(model) -> home.view(model) |> ui.map(HomeMsg)
            Page2Model(model) -> page2.view(model) |> ui.map(Page2Msg)
            // Wobble -> html.h1([], [element.text("You're on wobble")])
          },
        ],
      ),
    ),
  ])
}
