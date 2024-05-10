use endian;

export type buffer = struct {
	fmt: format,
	buf: []u8,
	width: size,
	height: size,
	stride: size,
};

// Creates a new pixel [[buffer]] with the given properties. Free the result
// with [[buffer_finish]], or use [[newbuffer_static]] to provide the underlying
// storage.
export fn newbuffer(
	fmt: format,
	width: size,
	height: size,
	stride: size,
) buffer = {
	const length = height * stride;
	assert(length != 0);
	let buf: []u8 = alloc([0...], length);
	return newbuffer_static(fmt, width, height, stride, buf);
};

// Frees resources associated with a pixel [[buffer]].
export fn buffer_finish(buf: *buffer) void = {
	free(buf.buf);
};

// Initializes a new pixel [[buffer]] with the given parameters and the provided
// pixel storage buffer. Calling [[buffer_finish]] will free this buffer; don't
// call it if you don't want to free this memory.
export fn newbuffer_static(
	fmt: format,
	width: size,
	height: size,
	stride: size,
	buf: []u8,
) buffer = {
	assert(len(buf) >= height * stride);
	return buffer {
		fmt = fmt,
		buf = buf,
		width = width,
		height = height,
		stride = stride,
	};
};

// Returns the width of this image buffer.
export fn buffer_width(buf: *buffer) size = buf.width;

// Returns the height of this image buffer.
export fn buffer_height(buf: *buffer) size = buf.height;

// Returns the stride of this image buffer.
export fn buffer_stride(buf: *buffer) size = buf.stride;

// Returns the pixel format of this image buffer.
export fn buffer_format(buf: *buffer) format = buf.fmt;

// Returns the raw pixel buffer for this [[buffer]].
export fn buffer_data(buf: *buffer) []u8 = buf.buf;

// Returns a scanline from the internal pixel buffer of a [[buffer]]. The
// scanline is unconverted from its native format. The given Y value must be
// less than the image height, or an assertion will be thrown. The length of the
// scanline buffer is equal to the buffer's stride.
export fn buffer_scanline_raw(buf: *buffer, y: size) []u8 = {
	const offs = buf.stride * y;
	return buf.buf[offs..offs + buf.stride];
};

// Reads a scanline from an image [[buffer]] into an array of ARGB pixels, doing
// any necessary format conversions along the way. The "out" parameter must have
// a length equal to the width of the image.
export fn buffer_scanline32(buf: *buffer, out: []u32, y: size) void = {
	assert(len(out) == buf.width, "buffer_scanline32: invalid width");
	for (let x = 0z; x < buf.width; x += 1) {
		out[x] = buffer_readpixel(buf, x, y);
	};
};

@test fn buffer_scanline32() void = {
	const data: [_]u8 = [
		0x00, 0x00, 0x00,
		0x80, 0x40, 0x20,
		0xFF, 0xFF, 0xFF,
	];
	const buf = newbuffer_static(format::R8G8B8, 3, 1, 3 * 3, data);
	let out: [3]u32 = [0...];
	buffer_scanline32(&buf, out, 0);
	assert(out[0] == 0xFF000000);
	assert(out[1] == 0xFF204080);
	assert(out[2] == 0xFFFFFFFF);
};

// Fetches a specific pixel from a [[buffer]] as an ARGB value.
export fn buffer_readpixel(buf: *buffer, x: size, y: size) u32 = {
	assert(endian::host == &endian::little); // TODO

	const scanline = buffer_scanline_raw(buf, y);
	const pixel: u32 = switch (format_bpp(buf.fmt)) {
	case 1 =>
		yield ((scanline[x >> 3] >> (x & 7)) & 1): u32;
	case 2 =>
		// XXX: None of the currently supported formats uses this bpp
		abort("readpixel: invalid format bpp");
	case 4 =>
		yield if ((4 * x) & 4 != 0) {
			yield scanline[(4 * x) >> 3] & 0xF;
		} else {
			yield scanline[(4 * x) >> 3] >> 4;
		};
	case 8 =>
		yield scanline[x];
	case 16 =>
		let scanline = (scanline: *[*]u8: *[*]u16)[..buf.width];
		yield scanline[x];
	case 24 =>
		yield scanline[3 * x + 0] << 0u32
			| scanline[3 * x + 1] << 8u32
			| scanline[3 * x + 2] << 16u32;
	case 32 =>
		let scanline = (scanline: *[*]u8: *[*]u32)[..buf.width];
		yield scanline[x];
	case =>
		abort("readpixel: invalid format bpp");
	};

	return pixel_toa8r8g8b8(buf.fmt, pixel);
};

fn pixel_toa8r8g8b8(fmt: format, pixel: u32) u32 = {
	assert(!format_isindexed(fmt)); // TODO
	return format_convertpixel(fmt, format::A8R8G8B8, pixel);
};

// Writes a pixel to a [[buffer]] from an ARGB value.
export fn buffer_writepixel(buf: *buffer, x: size, y: size, pixel: u32) void = {
	assert(!format_isindexed(buf.fmt)); // TODO
	pixel = format_convertpixel(format::A8R8G8B8, buf.fmt, pixel);

	let scanline = buffer_scanline_raw(buf, y);
	switch (format_bpp(buf.fmt)) {
	case 1 =>
		scanline[x / 8] &= ~(1 << (x % 8)): u8;
		scanline[x / 8] |= ((pixel & 1) << (x % 8)): u8;
	case 2 =>
		// XXX: None of the currently supported formats uses this bpp
		abort("readpixel: invalid format bpp");
	case 4 =>
		if ((4 * x) & 4 != 0) {
			scanline[(4 * x) >> 3] &= 0xF;
			scanline[(4 * x) >> 3] |= (pixel & 0xF): u8;
		} else {
			scanline[(4 * x) >> 3] &= 0xF0;
			scanline[(4 * x) >> 3] |= (pixel >> 4): u8;
		};
	case 8 =>
		scanline[x] = pixel: u8;
	case 16 =>
		let scanline = (scanline: *[*]u8: *[*]u16)[..buf.width];
		scanline[x] = pixel: u16;
	case 24 =>
		scanline[3 * x + 0] = (pixel >> 0): u8;
		scanline[3 * x + 1] = (pixel >> 8): u8;
		scanline[3 * x + 2] = (pixel >> 16): u8;
	case 32 =>
		let scanline = (scanline: *[*]u8: *[*]u32)[..buf.width];
		scanline[x] = pixel;
	case =>
		abort("readpixel: invalid format bpp");
	};
};
