import gleam/int
import legos/internal/model.{Oklch, Rgba}

pub fn transparent(color) {
  case color {
    Rgba(r:, g:, b:, a: _) -> Rgba(r:, g:, b:, a: 0.0)
    Oklch(l:, c:, h:, alpha: _) -> Oklch(l:, c:, h:, alpha: 0.0)
  }
}

pub fn dark_grey() {
  rgb(186.0 /. 255.0, 189.0 /. 255.0, 182.0 /. 255.0)
}

pub fn charcoal() {
  rgb(136.0 /. 255.0, 138.0 /. 255.0, 133.0 /. 255.0)
}

//
pub fn red_50() {
  oklch(0.971, 0.013, 17.38, 1.0)
}

pub fn red_100() {
  oklch(0.936, 0.032, 17.717, 1.0)
}

pub fn red_200() {
  oklch(0.885, 0.062, 18.334, 1.0)
}

pub fn red_300() {
  oklch(0.808, 0.114, 19.571, 1.0)
}

pub fn red_400() {
  oklch(0.704, 0.191, 22.216, 1.0)
}

pub fn red_500() {
  oklch(0.637, 0.237, 25.331, 1.0)
}

pub fn red_600() {
  oklch(0.577, 0.245, 27.325, 1.0)
}

pub fn red_700() {
  oklch(0.505, 0.213, 27.518, 1.0)
}

pub fn red_800() {
  oklch(0.444, 0.177, 26.899, 1.0)
}

pub fn red_900() {
  oklch(0.396, 0.141, 25.723, 1.0)
}

pub fn red_950() {
  oklch(0.258, 0.092, 26.042, 1.0)
}

pub fn orange_50() {
  oklch(0.98, 0.016, 73.684, 1.0)
}

pub fn orange_100() {
  oklch(0.954, 0.038, 75.164, 1.0)
}

pub fn orange_200() {
  oklch(0.901, 0.076, 70.697, 1.0)
}

pub fn orange_300() {
  oklch(0.837, 0.128, 66.29, 1.0)
}

pub fn orange_400() {
  oklch(0.75, 0.183, 55.934, 1.0)
}

pub fn orange_500() {
  oklch(0.705, 0.213, 47.604, 1.0)
}

pub fn orange_600() {
  oklch(0.646, 0.222, 41.116, 1.0)
}

pub fn orange_700() {
  oklch(0.553, 0.195, 38.402, 1.0)
}

pub fn orange_800() {
  oklch(0.47, 0.157, 37.304, 1.0)
}

pub fn orange_900() {
  oklch(0.408, 0.123, 38.172, 1.0)
}

pub fn orange_950() {
  oklch(0.266, 0.079, 36.259, 1.0)
}

pub fn amber_50() {
  oklch(0.987, 0.022, 95.277, 1.0)
}

pub fn amber_100() {
  oklch(0.962, 0.059, 95.617, 1.0)
}

pub fn amber_200() {
  oklch(0.924, 0.12, 95.746, 1.0)
}

pub fn amber_300() {
  oklch(0.879, 0.169, 91.605, 1.0)
}

pub fn amber_400() {
  oklch(0.828, 0.189, 84.429, 1.0)
}

pub fn amber_500() {
  oklch(0.769, 0.188, 70.08, 1.0)
}

pub fn amber_600() {
  oklch(0.666, 0.179, 58.318, 1.0)
}

pub fn amber_700() {
  oklch(0.555, 0.163, 48.998, 1.0)
}

pub fn amber_800() {
  oklch(0.473, 0.137, 46.201, 1.0)
}

pub fn amber_900() {
  oklch(0.414, 0.112, 45.904, 1.0)
}

pub fn amber_950() {
  oklch(0.279, 0.077, 45.635, 1.0)
}

pub fn yellow_50() {
  oklch(0.987, 0.026, 102.212, 1.0)
}

pub fn yellow_100() {
  oklch(0.973, 0.071, 103.193, 1.0)
}

pub fn yellow_200() {
  oklch(0.945, 0.129, 101.54, 1.0)
}

pub fn yellow_300() {
  oklch(0.905, 0.182, 98.111, 1.0)
}

pub fn yellow_400() {
  oklch(0.852, 0.199, 91.936, 1.0)
}

pub fn yellow_500() {
  oklch(0.795, 0.184, 86.047, 1.0)
}

pub fn yellow_600() {
  oklch(0.681, 0.162, 75.834, 1.0)
}

pub fn yellow_700() {
  oklch(0.554, 0.135, 66.442, 1.0)
}

pub fn yellow_800() {
  oklch(0.476, 0.114, 61.907, 1.0)
}

pub fn yellow_900() {
  oklch(0.421, 0.095, 57.708, 1.0)
}

pub fn yellow_950() {
  oklch(0.286, 0.066, 53.813, 1.0)
}

pub fn lime_50() {
  oklch(0.986, 0.031, 120.757, 1.0)
}

pub fn lime_100() {
  oklch(0.967, 0.067, 122.328, 1.0)
}

pub fn lime_200() {
  oklch(0.938, 0.127, 124.321, 1.0)
}

pub fn lime_300() {
  oklch(0.897, 0.196, 126.665, 1.0)
}

pub fn lime_400() {
  oklch(0.841, 0.238, 128.85, 1.0)
}

pub fn lime_500() {
  oklch(0.768, 0.233, 130.85, 1.0)
}

pub fn lime_600() {
  oklch(0.648, 0.2, 131.684, 1.0)
}

pub fn lime_700() {
  oklch(0.532, 0.157, 131.589, 1.0)
}

pub fn lime_800() {
  oklch(0.453, 0.124, 130.933, 1.0)
}

pub fn lime_900() {
  oklch(0.405, 0.101, 131.063, 1.0)
}

pub fn lime_950() {
  oklch(0.274, 0.072, 132.109, 1.0)
}

pub fn green_50() {
  oklch(0.982, 0.018, 155.826, 1.0)
}

pub fn green_100() {
  oklch(0.962, 0.044, 156.743, 1.0)
}

pub fn green_200() {
  oklch(0.925, 0.084, 155.995, 1.0)
}

pub fn green_300() {
  oklch(0.871, 0.15, 154.449, 1.0)
}

pub fn green_400() {
  oklch(0.792, 0.209, 151.711, 1.0)
}

pub fn green_500() {
  oklch(0.723, 0.219, 149.579, 1.0)
}

pub fn green_600() {
  oklch(0.627, 0.194, 149.214, 1.0)
}

pub fn green_700() {
  oklch(0.527, 0.154, 150.069, 1.0)
}

pub fn green_800() {
  oklch(0.448, 0.119, 151.328, 1.0)
}

pub fn green_900() {
  oklch(0.393, 0.095, 152.535, 1.0)
}

pub fn green_950() {
  oklch(0.266, 0.065, 152.934, 1.0)
}

pub fn emerald_50() {
  oklch(0.979, 0.021, 166.113, 1.0)
}

pub fn emerald_100() {
  oklch(0.95, 0.052, 163.051, 1.0)
}

pub fn emerald_200() {
  oklch(0.905, 0.093, 164.15, 1.0)
}

pub fn emerald_300() {
  oklch(0.845, 0.143, 164.978, 1.0)
}

pub fn emerald_400() {
  oklch(0.765, 0.177, 163.223, 1.0)
}

pub fn emerald_500() {
  oklch(0.696, 0.17, 162.48, 1.0)
}

pub fn emerald_600() {
  oklch(0.596, 0.145, 163.225, 1.0)
}

pub fn emerald_700() {
  oklch(0.508, 0.118, 165.612, 1.0)
}

pub fn emerald_800() {
  oklch(0.432, 0.095, 166.913, 1.0)
}

pub fn emerald_900() {
  oklch(0.378, 0.077, 168.94, 1.0)
}

pub fn emerald_950() {
  oklch(0.262, 0.051, 172.552, 1.0)
}

pub fn teal_50() {
  oklch(0.984, 0.014, 180.72, 1.0)
}

pub fn teal_100() {
  oklch(0.953, 0.051, 180.801, 1.0)
}

pub fn teal_200() {
  oklch(0.91, 0.096, 180.426, 1.0)
}

pub fn teal_300() {
  oklch(0.855, 0.138, 181.071, 1.0)
}

pub fn teal_400() {
  oklch(0.777, 0.152, 181.912, 1.0)
}

pub fn teal_500() {
  oklch(0.704, 0.14, 182.503, 1.0)
}

pub fn teal_600() {
  oklch(0.6, 0.118, 184.704, 1.0)
}

pub fn teal_700() {
  oklch(0.511, 0.096, 186.391, 1.0)
}

pub fn teal_800() {
  oklch(0.437, 0.078, 188.216, 1.0)
}

pub fn teal_900() {
  oklch(0.386, 0.063, 188.416, 1.0)
}

pub fn teal_950() {
  oklch(0.277, 0.046, 192.524, 1.0)
}

pub fn cyan_50() {
  oklch(0.984, 0.019, 200.873, 1.0)
}

pub fn cyan_100() {
  oklch(0.956, 0.045, 203.388, 1.0)
}

pub fn cyan_200() {
  oklch(0.917, 0.08, 205.041, 1.0)
}

pub fn cyan_300() {
  oklch(0.865, 0.127, 207.078, 1.0)
}

pub fn cyan_400() {
  oklch(0.789, 0.154, 211.53, 1.0)
}

pub fn cyan_500() {
  oklch(0.715, 0.143, 215.221, 1.0)
}

pub fn cyan_600() {
  oklch(0.609, 0.126, 221.723, 1.0)
}

pub fn cyan_700() {
  oklch(0.52, 0.105, 223.128, 1.0)
}

pub fn cyan_800() {
  oklch(0.45, 0.085, 224.283, 1.0)
}

pub fn cyan_900() {
  oklch(0.398, 0.07, 227.392, 1.0)
}

pub fn cyan_950() {
  oklch(0.302, 0.056, 229.695, 1.0)
}

pub fn sky_50() {
  oklch(0.977, 0.013, 236.62, 1.0)
}

pub fn sky_100() {
  oklch(0.951, 0.026, 236.824, 1.0)
}

pub fn sky_200() {
  oklch(0.901, 0.058, 230.902, 1.0)
}

pub fn sky_300() {
  oklch(0.828, 0.111, 230.318, 1.0)
}

pub fn sky_400() {
  oklch(0.746, 0.16, 232.661, 1.0)
}

pub fn sky_500() {
  oklch(0.685, 0.169, 237.323, 1.0)
}

pub fn sky_600() {
  oklch(0.588, 0.158, 241.966, 1.0)
}

pub fn sky_700() {
  oklch(0.5, 0.134, 242.749, 1.0)
}

pub fn sky_800() {
  oklch(0.443, 0.11, 240.79, 1.0)
}

pub fn sky_900() {
  oklch(0.391, 0.09, 240.876, 1.0)
}

pub fn sky_950() {
  oklch(0.293, 0.066, 243.157, 1.0)
}

pub fn blue_50() {
  oklch(0.97, 0.014, 254.604, 1.0)
}

pub fn blue_100() {
  oklch(0.932, 0.032, 255.585, 1.0)
}

pub fn blue_200() {
  oklch(0.882, 0.059, 254.128, 1.0)
}

pub fn blue_300() {
  oklch(0.809, 0.105, 251.813, 1.0)
}

pub fn blue_400() {
  oklch(0.707, 0.165, 254.624, 1.0)
}

pub fn blue_500() {
  oklch(0.623, 0.214, 259.815, 1.0)
}

pub fn blue_600() {
  oklch(0.546, 0.245, 262.881, 1.0)
}

pub fn blue_700() {
  oklch(0.488, 0.243, 264.376, 1.0)
}

pub fn blue_800() {
  oklch(0.424, 0.199, 265.638, 1.0)
}

pub fn blue_900() {
  oklch(0.379, 0.146, 265.522, 1.0)
}

pub fn blue_950() {
  oklch(0.282, 0.091, 267.935, 1.0)
}

pub fn indigo_50() {
  oklch(0.962, 0.018, 272.314, 1.0)
}

pub fn indigo_100() {
  oklch(0.93, 0.034, 272.788, 1.0)
}

pub fn indigo_200() {
  oklch(0.87, 0.065, 274.039, 1.0)
}

pub fn indigo_300() {
  oklch(0.785, 0.115, 274.713, 1.0)
}

pub fn indigo_400() {
  oklch(0.673, 0.182, 276.935, 1.0)
}

pub fn indigo_500() {
  oklch(0.585, 0.233, 277.117, 1.0)
}

pub fn indigo_600() {
  oklch(0.511, 0.262, 276.966, 1.0)
}

pub fn indigo_700() {
  oklch(0.457, 0.24, 277.023, 1.0)
}

pub fn indigo_800() {
  oklch(0.398, 0.195, 277.366, 1.0)
}

pub fn indigo_900() {
  oklch(0.359, 0.144, 278.697, 1.0)
}

pub fn indigo_950() {
  oklch(0.257, 0.09, 281.288, 1.0)
}

pub fn violet_50() {
  oklch(0.969, 0.016, 293.756, 1.0)
}

pub fn violet_100() {
  oklch(0.943, 0.029, 294.588, 1.0)
}

pub fn violet_200() {
  oklch(0.894, 0.057, 293.283, 1.0)
}

pub fn violet_300() {
  oklch(0.811, 0.111, 293.571, 1.0)
}

pub fn violet_400() {
  oklch(0.702, 0.183, 293.541, 1.0)
}

pub fn violet_500() {
  oklch(0.606, 0.25, 292.717, 1.0)
}

pub fn violet_600() {
  oklch(0.541, 0.281, 293.009, 1.0)
}

pub fn violet_700() {
  oklch(0.491, 0.27, 292.581, 1.0)
}

pub fn violet_800() {
  oklch(0.432, 0.232, 292.759, 1.0)
}

pub fn violet_900() {
  oklch(0.38, 0.189, 293.745, 1.0)
}

pub fn violet_950() {
  oklch(0.283, 0.141, 291.089, 1.0)
}

pub fn purple_50() {
  oklch(0.977, 0.014, 308.299, 1.0)
}

pub fn purple_100() {
  oklch(0.946, 0.033, 307.174, 1.0)
}

pub fn purple_200() {
  oklch(0.902, 0.063, 306.703, 1.0)
}

pub fn purple_300() {
  oklch(0.827, 0.119, 306.383, 1.0)
}

pub fn purple_400() {
  oklch(0.714, 0.203, 305.504, 1.0)
}

pub fn purple_500() {
  oklch(0.627, 0.265, 303.9, 1.0)
}

pub fn purple_600() {
  oklch(0.558, 0.288, 302.321, 1.0)
}

pub fn purple_700() {
  oklch(0.496, 0.265, 301.924, 1.0)
}

pub fn purple_800() {
  oklch(0.438, 0.218, 303.724, 1.0)
}

pub fn purple_900() {
  oklch(0.381, 0.176, 304.987, 1.0)
}

pub fn purple_950() {
  oklch(0.291, 0.149, 302.717, 1.0)
}

pub fn fuchsia_50() {
  oklch(0.977, 0.017, 320.058, 1.0)
}

pub fn fuchsia_100() {
  oklch(0.952, 0.037, 318.852, 1.0)
}

pub fn fuchsia_200() {
  oklch(0.903, 0.076, 319.62, 1.0)
}

pub fn fuchsia_300() {
  oklch(0.833, 0.145, 321.434, 1.0)
}

pub fn fuchsia_400() {
  oklch(0.74, 0.238, 322.16, 1.0)
}

pub fn fuchsia_500() {
  oklch(0.667, 0.295, 322.15, 1.0)
}

pub fn fuchsia_600() {
  oklch(0.591, 0.293, 322.896, 1.0)
}

pub fn fuchsia_700() {
  oklch(0.518, 0.253, 323.949, 1.0)
}

pub fn fuchsia_800() {
  oklch(0.452, 0.211, 324.591, 1.0)
}

pub fn fuchsia_900() {
  oklch(0.401, 0.17, 325.612, 1.0)
}

pub fn fuchsia_950() {
  oklch(0.293, 0.136, 325.661, 1.0)
}

pub fn pink_50() {
  oklch(0.971, 0.014, 343.198, 1.0)
}

pub fn pink_100() {
  oklch(0.948, 0.028, 342.258, 1.0)
}

pub fn pink_200() {
  oklch(0.899, 0.061, 343.231, 1.0)
}

pub fn pink_300() {
  oklch(0.823, 0.12, 346.018, 1.0)
}

pub fn pink_400() {
  oklch(0.718, 0.202, 349.761, 1.0)
}

pub fn pink_500() {
  oklch(0.656, 0.241, 354.308, 1.0)
}

pub fn pink_600() {
  oklch(0.592, 0.249, 0.584, 1.0)
}

pub fn pink_700() {
  oklch(0.525, 0.223, 3.958, 1.0)
}

pub fn pink_800() {
  oklch(0.459, 0.187, 3.815, 1.0)
}

pub fn pink_900() {
  oklch(0.408, 0.153, 2.432, 1.0)
}

pub fn pink_950() {
  oklch(0.284, 0.109, 3.907, 1.0)
}

pub fn rose_50() {
  oklch(0.969, 0.015, 12.422, 1.0)
}

pub fn rose_100() {
  oklch(0.941, 0.03, 12.58, 1.0)
}

pub fn rose_200() {
  oklch(0.892, 0.058, 10.001, 1.0)
}

pub fn rose_300() {
  oklch(0.81, 0.117, 11.638, 1.0)
}

pub fn rose_400() {
  oklch(0.712, 0.194, 13.428, 1.0)
}

pub fn rose_500() {
  oklch(0.645, 0.246, 16.439, 1.0)
}

pub fn rose_600() {
  oklch(0.586, 0.253, 17.585, 1.0)
}

pub fn rose_700() {
  oklch(0.514, 0.222, 16.935, 1.0)
}

pub fn rose_800() {
  oklch(0.455, 0.188, 13.697, 1.0)
}

pub fn rose_900() {
  oklch(0.41, 0.159, 10.272, 1.0)
}

pub fn rose_950() {
  oklch(0.271, 0.105, 12.094, 1.0)
}

pub fn slate_50() {
  oklch(0.984, 0.003, 247.858, 1.0)
}

pub fn slate_100() {
  oklch(0.968, 0.007, 247.896, 1.0)
}

pub fn slate_200() {
  oklch(0.929, 0.013, 255.508, 1.0)
}

pub fn slate_300() {
  oklch(0.869, 0.022, 252.894, 1.0)
}

pub fn slate_400() {
  oklch(0.704, 0.04, 256.788, 1.0)
}

pub fn slate_500() {
  oklch(0.554, 0.046, 257.417, 1.0)
}

pub fn slate_600() {
  oklch(0.446, 0.043, 257.281, 1.0)
}

pub fn slate_700() {
  oklch(0.372, 0.044, 257.287, 1.0)
}

pub fn slate_800() {
  oklch(0.279, 0.041, 260.031, 1.0)
}

pub fn slate_900() {
  oklch(0.208, 0.042, 265.755, 1.0)
}

pub fn slate_950() {
  oklch(0.129, 0.042, 264.695, 1.0)
}

pub fn gray_50() {
  oklch(0.985, 0.002, 247.839, 1.0)
}

pub fn gray_100() {
  oklch(0.967, 0.003, 264.542, 1.0)
}

pub fn gray_200() {
  oklch(0.928, 0.006, 264.531, 1.0)
}

pub fn gray_300() {
  oklch(0.872, 0.01, 258.338, 1.0)
}

pub fn gray_400() {
  oklch(0.707, 0.022, 261.325, 1.0)
}

pub fn gray_500() {
  oklch(0.551, 0.027, 264.364, 1.0)
}

pub fn gray_600() {
  oklch(0.446, 0.03, 256.802, 1.0)
}

pub fn gray_700() {
  oklch(0.373, 0.034, 259.733, 1.0)
}

pub fn gray_800() {
  oklch(0.278, 0.033, 256.848, 1.0)
}

pub fn gray_900() {
  oklch(0.21, 0.034, 264.665, 1.0)
}

pub fn gray_950() {
  oklch(0.13, 0.028, 261.692, 1.0)
}

pub fn zinc_50() {
  oklch(0.985, 0.0, 0.0, 1.0)
}

pub fn zinc_100() {
  oklch(0.967, 0.001, 286.375, 1.0)
}

pub fn zinc_200() {
  oklch(0.92, 0.004, 286.32, 1.0)
}

pub fn zinc_300() {
  oklch(0.871, 0.006, 286.286, 1.0)
}

pub fn zinc_400() {
  oklch(0.705, 0.015, 286.067, 1.0)
}

pub fn zinc_500() {
  oklch(0.552, 0.016, 285.938, 1.0)
}

pub fn zinc_600() {
  oklch(0.442, 0.017, 285.786, 1.0)
}

pub fn zinc_700() {
  oklch(0.37, 0.013, 285.805, 1.0)
}

pub fn zinc_800() {
  oklch(0.274, 0.006, 286.033, 1.0)
}

pub fn zinc_900() {
  oklch(0.21, 0.006, 285.885, 1.0)
}

pub fn zinc_950() {
  oklch(0.141, 0.005, 285.823, 1.0)
}

pub fn neutral_50() {
  oklch(0.985, 0.0, 0.0, 1.0)
}

pub fn neutral_100() {
  oklch(0.97, 0.0, 0.0, 1.0)
}

pub fn neutral_200() {
  oklch(0.922, 0.0, 0.0, 1.0)
}

pub fn neutral_300() {
  oklch(0.87, 0.0, 0.0, 1.0)
}

pub fn neutral_400() {
  oklch(0.708, 0.0, 0.0, 1.0)
}

pub fn neutral_500() {
  oklch(0.556, 0.0, 0.0, 1.0)
}

pub fn neutral_600() {
  oklch(0.439, 0.0, 0.0, 1.0)
}

pub fn neutral_700() {
  oklch(0.371, 0.0, 0.0, 1.0)
}

pub fn neutral_800() {
  oklch(0.269, 0.0, 0.0, 1.0)
}

pub fn neutral_900() {
  oklch(0.205, 0.0, 0.0, 1.0)
}

pub fn neutral_950() {
  oklch(0.145, 0.0, 0.0, 1.0)
}

pub fn stone_50() {
  oklch(0.985, 0.001, 106.423, 1.0)
}

pub fn stone_100() {
  oklch(0.97, 0.001, 106.424, 1.0)
}

pub fn stone_200() {
  oklch(0.923, 0.003, 48.717, 1.0)
}

pub fn stone_300() {
  oklch(0.869, 0.005, 56.366, 1.0)
}

pub fn stone_400() {
  oklch(0.709, 0.01, 56.259, 1.0)
}

pub fn stone_500() {
  oklch(0.553, 0.013, 58.071, 1.0)
}

pub fn stone_600() {
  oklch(0.444, 0.011, 73.639, 1.0)
}

pub fn stone_700() {
  oklch(0.374, 0.01, 67.558, 1.0)
}

pub fn stone_800() {
  oklch(0.268, 0.007, 34.298, 1.0)
}

pub fn stone_900() {
  oklch(0.216, 0.006, 56.043, 1.0)
}

pub fn stone_950() {
  oklch(0.147, 0.004, 49.25, 1.0)
}

pub fn black() {
  rgb(0.0, 0.0, 0.0)
}

pub fn white() {
  rgb(1.0, 1.0, 1.0)
}

pub fn rgb(red: Float, green: Float, blue: Float) -> model.Color {
  Rgba(red, green, blue, 1.0)
}

pub fn oklch(l: Float, c: Float, h: Float, alpha: Float) -> model.Color {
  Oklch(l, c, h, alpha)
}

pub fn rgba(red: Float, green: Float, blue: Float, alpha: Float) -> model.Color {
  Rgba(red, green, blue, alpha)
}

pub fn rgb255(red: Int, green: Int, blue: Int) -> model.Color {
  Rgba(
    int.to_float(red) /. 255.0,
    int.to_float(green) /. 255.0,
    int.to_float(blue) /. 255.0,
    1.0,
  )
}

pub fn rgba255(red: Int, green: Int, blue: Int, alpha: Float) -> model.Color {
  Rgba(
    int.to_float(red) /. 255.0,
    int.to_float(green) /. 255.0,
    int.to_float(blue) /. 255.0,
    alpha,
  )
}

pub fn from_rgb(color: #(Float, Float, Float, Float)) -> model.Color {
  let #(r, g, b, a) = color
  Rgba(r, g, b, a)
}

pub fn from_rgb255(color: #(Int, Int, Int, Float)) -> model.Color {
  let #(r, g, b, a) = color
  rgba255(r, g, b, a)
}
