use fmt;
use sdl;
use sdl = sdl::video;
use sdl = sdl::render;
use sdl = sdl::events;

fn lerp(a: f64, b: f64, t: f64) f64 = {
	return a + t * (b - a);
};

export fn main() void = {
	sdl::init(sdl::init_flags::VIDEO)!;
	defer sdl::quit();

	const window = sdl::create_window("hi",
		sdl::WINDOWPOS_UNDEFINED, sdl::WINDOWPOS_UNDEFINED,
		800, 600, sdl::window_flags::MINIMIZED)!;
	defer sdl::destroy_window(window);

	const renderer = sdl::create_renderer(window, -1,
		sdl::renderer_flags::ACCELERATED)!;
	defer sdl::destroy_renderer(renderer);

	for :loop (true) {
		for (true) match (sdl::poll_event()) {
		case void =>
			break;
		case sdl::quit_requested =>
			break :loop;
		case => void;
		};

		sdl::set_render_draw_color(renderer, 17, 17, 27, 255)!;
		sdl::render_clear(renderer)!;
		sdl::render_present(renderer);
	};
};
