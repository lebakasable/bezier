use rt;

// Writes the provided ARGB value to every pixel in a [[buffer]].
export fn fill(buf: *buffer, val: u32) void = {
	val = format_convertpixel(format::A8R8G8B8, buf.fmt, val);

	// TODO: buf.buf[..] = [val..];
	switch (format_bpp(buf.fmt)) {
	case 1 =>
		rt::memset(buf.buf: *[*]u8, -(val: u8), len(buf.buf));
	case 2 =>
		// XXX: None of the currently supported formats uses this bpp
		abort("fill: invalid format bpp");
	case 4 =>
		val |= val << 4;
		rt::memset(buf.buf: *[*]u8, val: u8, len(buf.buf));
	case 8 =>
		rt::memset(buf.buf: *[*]u8, val: u8, len(buf.buf));
	case 16 =>
		const npixel = buf.stride / 2 * buf.height;
		let buf = buf.buf: *[*]u16;
		for (let i = 0z; i < npixel; i += 1) {
			buf[i] = val: u16;
		};
	case 24 =>
		const nbyte = len(buf.buf);
		let buf = buf.buf: *[*]u8;
		for (let i = 0z; i < nbyte; i += 3) {
			buf[i + 0] = val: u8;
			buf[i + 1] = (val >> 8): u8;
			buf[i + 2] = (val >> 16): u8;
		};
	case 32 =>
		const npixel = buf.stride / 4 * buf.height;
		let buf = buf.buf: *[*]u32;
		for (let i = 0z; i < npixel; i += 1) {
			buf[i] = val;
		};
	case =>
		abort("fill: invalid format bpp");
	};
};
