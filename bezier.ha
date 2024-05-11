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

fn render_line(renderer: *sdl::renderer, begin: vec::v2f, end: vec::v2f, color: hex_color) void = {
	set_render_draw_color(renderer, color);
	sdl::render_draw_line(renderer, begin.x: int, begin.y: int, end.x: int, end.y: int)!;
};

fn fill_rect(renderer: *sdl::renderer, pos: vec::v2f, _size: vec::v2f, color: hex_color) void = {
	set_render_draw_color(renderer, color);

	const rect = sdl::rect {
		x = pos.x: int,
		y = pos.y: int,
		w = _size.x: int,
		h = _size.y: int,
	};

	sdl::render_fill_rect(renderer, &rect)!;
};

fn render_marker(renderer: *sdl::renderer, pos: vec::v2f, color: hex_color) void = {
	const _size = vec::vec2f(MARKER_SIZE: f32, MARKER_SIZE: f32);
	fill_rect(renderer, vec::sub(pos, vec::scale(_size, 0.5)), _size, color);
};

fn bezier_sample(ps: []vec::v2f, xs: []vec::v2f, t: f32) vec::v2f = {
	xs[0..] = ps[0..];

	let n = len(xs);
	for (n > 1) {
		for (let i = 0z; i < n - 1; i += 1) {
			xs[i] = vec::lerp(xs[i], xs[i + 1], t);
		};
		n -= 1;
	};

	return xs[0];
};

fn render_bezier_markers(
	renderer: *sdl::renderer,
	ps: []vec::v2f,
	xs: []vec::v2f,
	s: f32,
	color: hex_color,
) void = {
	for (let t = 0f32; t <= 1.0; t += s) {
		render_marker(renderer, bezier_sample(ps, xs, t), color);
	};
};

fn render_bezier_curve(
	renderer: *sdl::renderer,
	ps: []vec::v2f,
	xs: []vec::v2f,
	s: f32,
	color: hex_color,
) void = {
	for (let t = 0f32; t + s <= 1.0; t += s) {
		const begin = bezier_sample(ps, xs, t);
		const end = bezier_sample(ps, xs, t + s);
		render_line(renderer, begin, end, color);
	};
};

let ps: []vec::v2f = [];
let xs: []vec::v2f = [];
let ps_selected: (size | void) = void;

fn ps_at(pos: vec::v2f) (size | void) = {
	const ps_size = vec::vec2f(MARKER_SIZE, MARKER_SIZE);
	for (let i = 0z; i < len(ps); i += 1) {
		const ps_begin = vec::sub(ps[i], vec::scale(ps_size, 0.5));
		const ps_end = vec::add(ps_begin, ps_size);
		if (ps_begin.x <= pos.x && pos.x <= ps_end.x &&
			ps_begin.y <= pos.y && pos.y <= ps_end.y) {
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

	let markers = false;
	let step = 0.05f32;
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
			case sdl::keycode::TAB =>
				markers = !markers;
			case => void;
			};
		case let mouse: sdl::mouse_button_pressed =>
			switch (mouse.button) {
			case 1 =>
				const mouse_pos = vec::vec2f(mouse.x: f32, mouse.y: f32);
				ps_selected = ps_at(mouse_pos);
				if (ps_selected is void) {
					append(ps, mouse_pos);
					append(xs, mouse_pos);
				};
			case => void;
			};
		case let mouse: sdl::mouse_button_released =>
			if (mouse.button == 1) {
				ps_selected = void;
			};
		case let mouse: sdl::mouse_moved =>
			const mouse_pos = vec::vec2f(mouse.x: f32, mouse.y: f32);
			if (!(ps_selected is void)) {
				ps[ps_selected as size] = mouse_pos;
			};
		case let mouse: sdl::mouse_wheel_scrolled =>
			if (mouse.y > 0) {
				if (step <= 1.0) {
					step += 0.001;
				};
			} else if (mouse.y < 0) {
				if (step > 0.001) {
					step -= 0.001;
				};
			};
		case => void;
		};

		set_render_draw_color(renderer, BACKGROUND_COLOR);
		sdl::render_clear(renderer)!;

		if (len(ps) > 0) {
			if (markers) {
				render_bezier_markers(renderer, ps, xs, step, TEAL_COLOR);
			} else {
				render_bezier_curve(renderer, ps, xs, step, TEAL_COLOR);
			};
		};

		for (let i = 0z; i < len(ps); i += 1) {
			render_marker(renderer, ps[i], PEACH_COLOR);
			if (i < len(ps) - 1) {
				render_line(renderer, ps[i], ps[i + 1], MAUVE_COLOR);
			};
		};

		sdl::render_present(renderer);

		sdl::delay(DELTA_TIME_MS);
		t += DELTA_TIME_SEC;
	};
};

@fini fn fini() void = {
	free(ps);
	free(xs);
};
