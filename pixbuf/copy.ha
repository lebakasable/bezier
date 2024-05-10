// The dimensions of a rectangle within a [[buffer]].
export type rect = struct {
	x: size,
	y: size,
	w: size,
	h: size,
};

// Returns a [[rect]] enclosing an entire [[buffer]].
export fn buffer_dimensions(buf: *buffer) rect = {
	return rect {
		x = 0,
		y = 0,
		w = buf.width,
		h = buf.height,
	};
};

// Copies pixels from one [[buffer]] to another. The [[rect]]s provided must be
// entirely within the bounds of their respective buffers, or an assertion will
// fire. Pixel format conversions will be performed automatically, if necessary,
// at a cost to performance.
//
// The width and height of the two rectangles must be equal to one another.
export fn copy(
	dest: *buffer,
	destrect: const *rect,
	src: const *buffer,
	srcrect: const *rect,
) void = {
	assert(srcrect.w == destrect.w && srcrect.h == destrect.h,
		"pixbuf::copy: source dimensions do not match destination");
	if (src.fmt != dest.fmt) {
		copy_slow(dest, destrect, src, srcrect);
	} else {
		copy_fast(dest, destrect, src, srcrect);
	};
};

fn copy_slow(
	dest: *buffer,
	destrect: const *rect,
	src: const *buffer,
	srcrect: const *rect,
) void = {
	for (let x = 0z; x < srcrect.w; x += 1)
	for (let y = 0z; y < srcrect.h; y += 1) {
		const pixel = buffer_readpixel(src, srcrect.x + x, srcrect.y + y);
		buffer_writepixel(dest, destrect.x + x, destrect.y + y, pixel);
	};
};

fn copy_fast(
	dest: *buffer,
	destrect: const *rect,
	src: const *buffer,
	srcrect: const *rect,
) void = {
	const fmt = dest.fmt;
	assert(format_bpp(fmt) >= 8); // TODO
	let bytepp = format_bpp(fmt) / 8;
	if (bytepp == 0) {
		bytepp = 1;
	};

	for (let y = 0z; y < srcrect.h; y += 1) {
		const src_scanln = buffer_scanline_raw(src, srcrect.y + y);
		let dest_scanln = buffer_scanline_raw(dest, destrect.y + y);

		const src_start = srcrect.x * bytepp;
		const src_end = (srcrect.x + srcrect.w) * bytepp;

		const dest_start = destrect.x * bytepp;
		const dest_end = (destrect.x + destrect.w) * bytepp;

		dest_scanln[dest_start..dest_end] =
			src_scanln[src_start..src_end];
	};
};
