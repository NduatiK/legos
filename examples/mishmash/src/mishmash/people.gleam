import legos/border
import legos/element as ui
import legos/font

type Person {
  Person(first_name: String, last_name: String)
}

pub fn view() {
  let persons = [
    Person("David", "Bowie"),
    Person("Florence", "Welch"),
  ]
  // ui.row(
  //   [
  //     ui.align_left(),
  //     font.medium(),
  //     font.size(18),
  //     ui.width(ui.fill()),
  //     ui.spacing(30),
  //   ],
  //   [
  ui.el(
    [ui.padding_xy(20, 0)],
    ui.table(
      [
        ui.padding(4),
        ui.spacing(10),
        font.size(14),
        border.width(1),
      ],
      data: persons,
      columns: [
        ui.TableColumn(
          header: ui.none,
          width: ui.shrink(),
          view: fn(person: Person) {
            ui.image(
              [
                border.rounded(25),
                border.rounded(25),
                ui.clip(),
              ],
              src: "https://testingbot.com/free-online-tools/random-avatar/50?u="
                <> person.first_name,
              description: person.first_name <> "'s avatar",
            )
          },
        ),
        ui.TableColumn(
          header: ui.text("First Name"),
          width: ui.shrink(),
          view: fn(person: Person) {
            ui.el(
              [
                ui.center_y(),
              ],
              ui.text(person.first_name),
            )
          },
        ),
        ui.TableColumn(
          header: ui.text("Last Name"),
          width: ui.shrink(),
          view: fn(person: Person) {
            ui.el(
              [
                ui.center_y(),
              ],
              ui.text(person.last_name),
            )
          },
        ),
      ],
    ),
  )
}
