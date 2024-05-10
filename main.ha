use fmt;
use sdl;
use sdl = sdl::video;
use sdl = sdl::render;
use sdl = sdl::events;
use sdl = sdl::pixels;
use sdl = sdl::rect;
use sdl = sdl::timer;
use sdl = sdl::keycode;
use vec;
use math;

def SCREEN_WIDTH = 800;
def SCREEN_HEIGHT = 600;
def SCREEN_FPS = 60;
def DELTA_TIME_SEC = 1.0 / SCREEN_FPS: f32;
def DELTA_TIME_MS = (DELTA_TIME_SEC * 1000.0): u32;
def MARKER_SIZE = 15f32;

// https://catppuccin.com/palette
def BACKGROUND_COLOR = 0x11111b; // #11111b
def PEACH_COLOR      = 0xfab387; // #fab387
def TEAL_COLOR       = 0x94e2d5; // #94e2d5
def MAUVE_COLOR      = 0xcba6f7; // #cba6f7

type hex_color = u32;

fn to_rgba(color: hex_color) sdl::color =
	sdl::color {
		r = ((color >> 16) & 0xff): u8,
		g = ((color >> 8) & 0xff): u8,
		b = (color & 0xff): u8,
		a = 0xff,
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

	const rect = sdl::rect {
		x = pos.0: int,
		y = pos.1: int,
		w = _size.0: int,
		h = _size.1: int,
	};

	sdl::render_fill_rect(renderer, &rect)!;
};

fn render_marker(renderer: *sdl::renderer, pos: vec::point, color: hex_color) void = {
	const _size = (MARKER_SIZE, MARKER_SIZE);
	fill_rect(
		renderer,
		vec::sub(vec::scale(_size, 0.5), pos),
		_size, color);
};

fn render_bezier_markers(
	renderer: *sdl::renderer,
	a: vec::point,
	b: vec::point,
	c: vec::point,
	d: vec::point,
	s: f32,
	color: hex_color
) void = {
	for (let f = 0f32; f <= 1.0; f += s) {
		const ab = vec::lerpp(a, b, f);
		const bc = vec::lerpp(b, c, f);
		const cd = vec::lerpp(c, d, f);
		const abc = vec::lerpp(ab, bc, f);
		const bcd = vec::lerpp(bc, cd, f);
		const abcd = vec::lerpp(abc, bcd, f);
		render_marker(renderer, abcd, color);
	};
};

let ps: []vec::point = [];
let ps_selected: (size | void) = void;

fn ps_at(pos: vec::point) (size | void) = {
	const ps_size = (MARKER_SIZE: f32, MARKER_SIZE: f32);
	for (let i = 0z; i < len(ps); i += 1) {
		const ps_begin = vec::sub(vec::scale(ps_size, 0.5), ps[i]);
		const ps_end = vec::add(ps_begin, ps_size);
		if (ps_begin.0 <= pos.0 && pos.0 <= ps_end.0 &&
			ps_begin.1 <= pos.1 && pos.1 <= ps_end.1) {
			return i: size;
		};
	};
	return void;
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

	let t = 0f32;
	for :loop (true) {
		for (true) match (sdl::poll_event()) {
		case void =>
			break;
		case sdl::quit_requested =>
			break :loop;
		case let key: sdl::key_pressed =>
			switch (key.keysym.sym) {
			case sdl::keycode::RETURN =>
				ps = [];
			case => void;
			};
		case let mouse: sdl::mouse_button_pressed =>
			switch (mouse.button) {
			case 1 =>
				const mouse_pos = (mouse.x: f32, mouse.y: f32);
				if (len(ps) < 4) {
					append(ps, mouse_pos);
				} else {
					ps_selected = ps_at(mouse_pos);
				};
			case => void;
			};
		case let mouse: sdl::mouse_button_released =>
			if (mouse.button == 1) {
				ps_selected = void;
			};
		case let mouse: sdl::mouse_moved =>
			const mouse_pos = (mouse.x: f32, mouse.y: f32);
			if (!(ps_selected is void)) {
				ps[ps_selected as size] = mouse_pos;
			};
		case => void;
		};

		set_render_draw_color(renderer, BACKGROUND_COLOR);
		sdl::render_clear(renderer)!;

		for (let i = 0z; i < len(ps); i += 1) {
			render_marker(renderer, ps[i], PEACH_COLOR);
		};

		if (len(ps) >= 4) {
			render_bezier_markers(renderer, ps[0], ps[1], ps[2], ps[3], 0.1, TEAL_COLOR);
		};

		sdl::render_present(renderer);

		sdl::delay(DELTA_TIME_MS);
		t += DELTA_TIME_SEC;
	};
};
