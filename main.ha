use fmt;
use sdl;
use sdl = sdl::video;
use sdl = sdl::render;
use sdl = sdl::events;
use sdl = sdl::pixels;
use sdl = sdl::rect;
use vec;

def SCREEN_WIDTH = 800;
def SCREEN_HEIGHT = 600;

// https://catppuccin.com/palette
def BACKGROUND_COLOR = 0x11111b; // #11111b
def LINE_COLOR       = 0xfab387; // #fab387
def RECT_COLOR       = 0x94e2d5; // #94e2d5

type hex_color = u32;

fn to_rgba(color: hex_color) sdl::color = {
	return sdl::color {
		r = ((color >> 16) & 0xff): u8,
		g = ((color >> 8) & 0xff): u8,
		b = (color & 0xff): u8,
		a = 0xff,
	};
};

fn set_render_draw_color(renderer: *sdl::renderer, color: hex_color) void = {
	const color = to_rgba(color);
	sdl::set_render_draw_color(renderer, color.r, color.g, color.b, color.a)!;
};

fn render_line(renderer: *sdl::renderer, begin: vec::point, end: vec::point, color: hex_color) void = {
	set_render_draw_color(renderer, color);
	sdl::render_draw_line(renderer, begin.0: int, begin.1: int, end.0: int, end.1: int)!;
};

fn fill_rect(renderer: *sdl::renderer, pos: vec::point, _size: vec::point, color: hex_color) void = {
	set_render_draw_color(renderer, color);

	let rect = sdl::rect {
		x = pos.0: int,
		y = pos.1: int,
		w = _size.0: int,
		h = _size.1: int,
	};

	sdl::render_fill_rect(renderer, &rect)!;
};

export fn main() void = {
	sdl::init(sdl::init_flags::VIDEO)!;
	defer sdl::quit();

	const window = sdl::create_window("Bézier Curve",
		sdl::WINDOWPOS_UNDEFINED, sdl::WINDOWPOS_UNDEFINED,
		SCREEN_WIDTH, SCREEN_HEIGHT, sdl::window_flags::MINIMIZED)!;
	defer sdl::destroy_window(window);

	const renderer = sdl::create_renderer(window, -1,
		sdl::renderer_flags::ACCELERATED)!;
	defer sdl::destroy_renderer(renderer);

	sdl::render_set_logical_size(renderer, SCREEN_WIDTH, SCREEN_HEIGHT)!;

	for :loop (true) {
		for (true) match (sdl::poll_event()) {
		case void =>
			break;
		case sdl::quit_requested =>
			break :loop;
		case => void;
		};

		set_render_draw_color(renderer, BACKGROUND_COLOR);
		sdl::render_clear(renderer)!;

		render_line(renderer, (0.0, 0.0), (SCREEN_WIDTH: f32, SCREEN_HEIGHT: f32), LINE_COLOR);
		render_line(renderer, (SCREEN_WIDTH: f32, 0.0), (0.0, SCREEN_HEIGHT: f32), LINE_COLOR);

		fill_rect(renderer, (0.0, 0.0), (100.0, 100.0), RECT_COLOR);

		sdl::render_present(renderer);
	};
};
