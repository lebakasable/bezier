use pixbuf;

// Clears the entire canvas to a solid color.
export fn clear(
	p: *painter,
	c: color,
) void = {
	const val = to_argb(&c);
	pixbuf::fill(p.buf, val);
};
