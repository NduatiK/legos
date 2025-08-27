import gleam/uri

pub type Route {
  Home
  Page2
}

pub fn from_uri(uri: uri.Uri) {
  case uri.path_segments(uri.path) {
    ["s"] -> Page2
    _ -> Home
  }
}

pub fn to_path(route) {
  case route {
    Page2 -> "/s"
    Home -> "/"
  }
}
