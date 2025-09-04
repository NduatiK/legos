import gleam/pair
import gleam/result
import gleam/uri
import legos/background
import legos/color
import legos/ui
import legos/font
import lustre
import lustre/effect
import lustre/element/html
import mishmash/colors
import mishmash/components
import mishmash/pages/home
import mishmash/pages/page2
import mishmash/route.{type Route}
import modem

pub fn start() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

pub type Model {
  Model(page: Page, other: Int)
}

pub type Page {
  HomeModel(home.Model)
  Page2Model(page2.Model)
}

pub fn init(_) -> #(Model, effect.Effect(Msg)) {
  let #(page, page_effect) =
    modem.initial_uri()
    |> result.map(route.from_uri)
    |> result.unwrap(route.Home)
    |> route_to_page()

  #(
    Model(page:, other: 0),
    effect.batch([modem.init(on_url_change), page_effect]),
  )
}

fn route_to_page(route) {
  case route {
    route.Home ->
      home.init(Nil)
      |> pair.map_first(HomeModel)
      |> pair.map_second(effect.map(_, HomeMsg))
    route.Page2 ->
      page2.init(Nil)
      |> pair.map_first(Page2Model)
      |> pair.map_second(effect.map(_, Page2Msg))
  }
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
    OnRouteChange(route), _ -> {
      let #(page, effect) = route_to_page(route)
      #(Model(..model, page:), effect)
    }

    HomeMsg(msg), HomeModel(page) ->
      model
      |> set_page(HomeModel, HomeMsg, home.update(page, msg))

    Page2Msg(msg), Page2Model(page) ->
      model
      |> set_page(Page2Model, Page2Msg, page2.update(page, msg))

    _, _ -> #(model, effect.none())
  }
}

fn set_page(model, to_model, to_msg, page_and_effect) {
  let #(page, effect) = page_and_effect
  #(Model(..model, page: to_model(page)), effect.map(effect, to_msg))
}

fn view(model: Model) {
  html.div([], [
    html.nav([], [
      // html.a([attribute.href("/wobble")], [ui.text("Go to wobble")]),
    ]),
    ui.layout(
      [
        ui.height(ui.fill()),
        ui.width(ui.fill()),
        ui.scrollbars(),
        font.family([font.typeface("Plus Jakarta Sans"), font.sans_serif()]),
        background.color(colors.background()),
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
            // Wobble -> html.h1([], [ui.text("You're on wobble")])
          },
        ],
      ),
    ),
  ])
}
