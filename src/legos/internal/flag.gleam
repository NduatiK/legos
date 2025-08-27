import gleam/float
import gleam/int
import gleam_community/maths

pub type Field {
  Field(one: Int, two: Int)
}

pub type Flag {
  First(Int)
  Second(Int)
}

pub const none: Field = Field(0, 0)

pub fn value(flag: Flag) -> Int {
  case flag {
    First(first) -> float.round(unsafe_log_base_2(first))
    Second(second) -> float.round(unsafe_log_base_2(second)) + 32
  }
}

fn unsafe_log_base_2(num) {
  let assert Ok(r) = maths.logarithm_2(int.to_float(num))
  r
}

// If the query is in the truth, return True
pub fn present(flag: Flag, field: Field) -> Bool {
  case flag, field {
    First(first), Field(field_one, _) ->
      int.bitwise_and(first, field_one) == first
    Second(second), Field(_, field_two) ->
      int.bitwise_and(second, field_two) == second
  }
}

// Add a flag to a field
pub fn add(field: Field, flag: Flag) -> Field {
  case flag {
    First(first) -> Field(..field, one: int.bitwise_or(first, field.one))
    Second(second) -> Field(..field, two: int.bitwise_or(second, field.two))
  }
}

// Merge two fields
pub fn merge(field1: Field, field2: Field) -> Field {
  Field(
    int.bitwise_or(field1.one, field2.one),
    int.bitwise_or(field1.two, field2.two),
  )
}

pub fn flag(i: Int) -> Flag {
  case i > 31 {
    True -> Second(int.bitwise_shift_left(1, i - 32))
    False -> First(int.bitwise_shift_left(1, i))
  }
}

// Constants for flags
// Used for Style invalidation

pub fn transparency() {
  flag(0)
}

pub fn padding() {
  flag(2)
}

pub fn spacing() {
  flag(3)
}

pub fn font_size() {
  flag(4)
}

pub fn font_family() {
  flag(5)
}

pub fn width() {
  flag(6)
}

pub fn height() {
  flag(7)
}

pub fn bg_color() {
  flag(8)
}

pub fn bg_image() {
  flag(9)
}

pub fn bg_gradient() {
  flag(10)
}

pub fn border_style() {
  flag(11)
}

pub fn font_alignment() {
  flag(12)
}

pub fn font_weight() {
  flag(13)
}

pub fn font_color() {
  flag(14)
}

pub fn word_spacing() {
  flag(15)
}

pub fn letter_spacing() {
  flag(16)
}

pub fn border_round() {
  flag(17)
}

pub fn txt_shadows() {
  flag(18)
}

pub fn shadows() {
  flag(19)
}

pub fn overflow() {
  flag(20)
}

pub fn cursor() {
  flag(21)
}

pub fn scale() {
  flag(23)
}

pub fn rotate() {
  flag(24)
}

pub fn move_x() {
  flag(25)
}

pub fn move_y() {
  flag(26)
}

pub fn border_width() {
  flag(27)
}

pub fn border_color() {
  flag(28)
}

pub fn y_align() {
  flag(29)
}

pub fn x_align() {
  flag(30)
}

pub fn focus() {
  flag(31)
}

pub fn active() {
  flag(32)
}

pub fn hover() {
  flag(33)
}

pub fn grid_template() {
  flag(34)
}

pub fn grid_position() {
  flag(35)
}

// Notes

pub fn height_content() {
  flag(36)
}

pub fn height_fill() {
  flag(37)
}

pub fn width_content() {
  flag(38)
}

pub fn width_fill() {
  flag(39)
}

pub fn align_right() {
  flag(40)
}

pub fn align_bottom() {
  flag(41)
}

pub fn center_x() {
  flag(42)
}

pub fn center_y() {
  flag(43)
}

pub fn width_between() {
  flag(44)
}

pub fn height_between() {
  flag(45)
}

pub fn behind() {
  flag(46)
}

pub fn height_text_area_content() {
  flag(47)
}

pub fn font_variant() {
  flag(48)
}

pub fn transition() {
  flag(49)
}
