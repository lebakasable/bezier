use pixbuf;

// Paints a filled rectangle.
export fn fill_rect(
	p: *painter,
	style: const *style,
	rect: const *rect,
) void = {
	// XXX: This could be made faster in certain situations
	for (let y = rect.y; y < rect.y + rect.h; y += 1.0)
	for (let x = rect.x; x < rect.x + rect.w; x += 1.0) {
		const (x, y) = (x: uint, y: uint);
		const color = sample(style, x, y);
		pixbuf::buffer_writepixel(p.buf, x, y, color);
	};
};
