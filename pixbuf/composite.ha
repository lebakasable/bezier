// The blending mode used for [[copy]] operations.
export type blendmode = enum {
	NONE,
	ADD,
	SUBTRACT,
	ALPHA,
};

// Copies pixels from one [[buffer]] to another using a specified [[blendmode]].
// The [[rect]]s provided must be entirely within the bounds of their respective
// buffers, or an assertion will fire. Pixel format conversions will be
// performed automatically, if necessary, at a cost to performance.
//
// The width and height of the two rectangles must be equal to one another.
export fn composite(
	dest: *buffer,
	destrect: const *rect,
	src: const *buffer,
	srcrect: const *rect,
	blendmode: blendmode,
) void = {
	assert(srcrect.w == destrect.w && srcrect.h == destrect.h,
		"pixbuf::copy: source dimensions do not match destination");
	switch (blendmode) {
	case blendmode::NONE =>
		copy(dest, destrect, src, srcrect);
	case blendmode::ADD =>
		composite_add(dest, destrect, src, srcrect);
	case blendmode::SUBTRACT =>
		composite_subtract(dest, destrect, src, srcrect);
	case blendmode::ALPHA =>
		composite_alpha(dest, destrect, src, srcrect);
	case =>
		abort("requested blending mode not implemented");
	};
};

fn composite_add(
	dest: *buffer,
	destrect: const *rect,
	src: const *buffer,
	srcrect: const *rect,
) void = {
	for (let x = 0z; x < srcrect.w; x += 1)
	for (let y = 0z; y < srcrect.h; y += 1) {
		const p0 = buffer_readpixel(src, srcrect.x + x, srcrect.y + y);
		const p1 = buffer_readpixel(dest, destrect.x + x, destrect.y + y);
		let a: u32 = p1 >> 24;
		let r: u32 = ((p0 >> 16) & 0xff) + ((p1 >> 16) & 0xff);
		if (r > 0xFF) r = 0xFF;
		let g: u32 = ((p0 >> 8) & 0xff) + ((p1 >> 8) & 0xff);
		if (g > 0xFF) g = 0xFF;
		let b: u32 = (p0 & 0xff) + (p1 & 0xff);
		if (b > 0xFF) b = 0xFF;
		const p: u32 =
			(a << 24) |
			(r << 16) |
			(g << 8) |
			b;
		buffer_writepixel(dest, destrect.x + x, destrect.y + y, p);
	};
};

fn composite_subtract(
	dest: *buffer,
	destrect: const *rect,
	src: const *buffer,
	srcrect: const *rect,
) void = {
	for (let x = 0z; x < srcrect.w; x += 1)
	for (let y = 0z; y < srcrect.h; y += 1) {
		const p0 = buffer_readpixel(src, srcrect.x + x, srcrect.y + y);
		const p1 = buffer_readpixel(dest, destrect.x + x, destrect.y + y);
		let a: u32 = p1 >> 24;
		let r: i64 = ((p1 >> 16) & 0xff): i64 - ((p0 >> 16) & 0xff): i64;
		if (r < 0) r = 0;
		let g: i64 = ((p1 >> 8) & 0xff): i64 - ((p0 >> 8) & 0xff): i64;
		if (g < 0) g = 0;
		let b: i64 = (p1 & 0xff): i64 - (p0 & 0xff): i64;
		if (b < 0) b = 0;
		const p: u32 =
			(a: u32 << 24) |
			(r: u32 << 16) |
			(g: u32 << 8) |
			b: u32;
		buffer_writepixel(dest, destrect.x + x, destrect.y + y, p);
	};
};

fn composite_alpha(
	dest: *buffer,
	destrect: const *rect,
	src: const *buffer,
	srcrect: const *rect,
) void = {
	for (let x = 0z; x < srcrect.w; x += 1)
	for (let y = 0z; y < srcrect.h; y += 1) {
		const p0 = buffer_readpixel(src, srcrect.x + x, srcrect.y + y);
		const p0_a = chan_to_float((p0 >> 24): u8);
		const p0_r = chan_to_float((p0 >> 16): u8);
		const p0_g = chan_to_float((p0 >> 8): u8);
		const p0_b = chan_to_float(p0: u8);
		const p1 = buffer_readpixel(dest, destrect.x + x, destrect.y + y);
		const p1_a = chan_to_float((p1 >> 24): u8);
		const p1_r = chan_to_float((p1 >> 16): u8);
		const p1_g = chan_to_float((p1 >> 8): u8);
		const p1_b = chan_to_float(p1: u8);
		const a = float_to_chan(blend_alpha(p0_a, p1_a));
		const r = float_to_chan(blend_chan(p0_r, p0_a, p1_r));
		const g = float_to_chan(blend_chan(p0_g, p0_a, p1_g));
		const b = float_to_chan(blend_chan(p0_b, p0_a, p1_b));
		const p: u32 =
			(a: u32 << 24) |
			(r: u32 << 16) |
			(g: u32 << 8) |
			b: u32;
		buffer_writepixel(dest, destrect.x + x, destrect.y + y, p);
	};
};

fn chan_to_float(x: u8) f32 = {
	return x: f32 / 255.0f32;
};

fn float_to_chan(x: f32) u8 = {
	return (x * 255.0f32): u8;
};

fn blend_chan(src_r: f32, src_a: f32, dest_r: f32) f32 = {
	return (src_r * src_a) + (dest_r * (1.0 - src_a));
};

fn blend_alpha(src_a: f32, dest_a: f32) f32 = {
	return src_a + (dest_a * (1.0 - src_a));
};
