@test fn buffer_readpixel() void = {
	const vectors: [_](format, []u8, size, size, u32) = [
		// format::A1
		(format::A1, [0b00001111], 0, 0, 0xFFFFFFFF),
		(format::A1, [0b00001111], 1, 0, 0xFFFFFFFF),
		(format::A1, [0b00001111], 2, 0, 0xFFFFFFFF),
		(format::A1, [0b00001111], 3, 0, 0xFFFFFFFF),
		(format::A1, [0b00001111], 4, 0, 0x00FFFFFF),
		(format::A1, [0b00001111], 5, 0, 0x00FFFFFF),
		(format::A1, [0b00001111], 6, 0, 0x00FFFFFF),
		(format::A1, [0b00001111], 7, 0, 0x00FFFFFF),
		// format::A4
		(format::A4, [0, 0b10001111], 0, 0, 0x00FFFFFF),
		(format::A4, [0, 0b10001111], 2, 0, 0x88FFFFFF),
		(format::A4, [0, 0b10001111], 3, 0, 0xFFFFFFFF),
		// format::A8
		(format::A8, [0x00, 0x80, 0xFF], 0, 0, 0x00FFFFFF),
		(format::A8, [0x00, 0x80, 0xFF], 1, 0, 0x80FFFFFF),
		(format::A8, [0x00, 0x80, 0xFF], 2, 0, 0xFFFFFFFF),
		// format::R5G6B5
		(format::R5G6B5, [
			0b00000000, 0b00000000,
			0b00011111, 0b11111000,
			0b00011111, 0b11111100,
			0b11111111, 0b11111111,
		], 0, 0, 0xFF000000),
		(format::R5G6B5, [
			0b00000000, 0b00000000,
			0b00011111, 0b11111000,
			0b00011111, 0b11111100,
			0b11111111, 0b11111111,
		], 1, 0, 0xFFFF00FF),
		(format::R5G6B5, [
			0b00000000, 0b00000000,
			0b00011111, 0b11111000,
			0b00011111, 0b11111100,
			0b11111111, 0b11111111,
		], 2, 0, 0xFFFF82FF),
		(format::R5G6B5, [
			0b00000000, 0b00000000,
			0b00011111, 0b11111000,
			0b00011111, 0b11111100,
			0b11111111, 0b11111111,
		], 3, 0, 0xFFFFFFFF),
		// format::R8G8B8
		(format::R8G8B8, [
			0x00, 0x00, 0x00,
			0x80, 0x40, 0x20,
			0xFF, 0xFF, 0xFF,
		], 0, 0, 0xFF000000),
		(format::R8G8B8, [
			0x00, 0x00, 0x00,
			0x80, 0x40, 0x20,
			0xFF, 0xFF, 0xFF,
		], 1, 0, 0xFF204080),
		(format::R8G8B8, [
			0x00, 0x00, 0x00,
			0x80, 0x40, 0x20,
			0xFF, 0xFF, 0xFF,
		], 2, 0, 0xFFFFFFFF),
		// format::A8R8G8B8
		(format::A8R8G8B8, [
			0x00, 0x00, 0x00, 0x00,
			0x80, 0x40, 0x20, 0x10,
			0xFF, 0xFF, 0xFF, 0xFF,
		], 0, 0, 0x00000000),
		(format::A8R8G8B8, [
			0x00, 0x00, 0x00, 0x00,
			0x80, 0x40, 0x20, 0x10,
			0xFF, 0xFF, 0xFF, 0xFF,
		], 1, 0, 0x10204080),
		(format::A8R8G8B8, [
			0x00, 0x00, 0x00, 0x00,
			0x80, 0x40, 0x20, 0x10,
			0xFF, 0xFF, 0xFF, 0xFF,
		], 2, 0, 0xFFFFFFFF),
	];
	for (let i = 0z; i < len(vectors); i += 1) {
		const (fmt, input, x, y, expect) = vectors[i];
		const bpp = format_bpp(fmt);
		const width = len(input) * 8 / bpp;
		const buf = newbuffer_static(fmt, width, 1, format_stride(fmt, width), input);
		const pixel = buffer_readpixel(&buf, x, y);
		assert(pixel == expect);
	};
};

@test fn buffer_writepixel() void = {
	const formats = [
		format::A1,
		format::A8,
		format::R5G6B5,
		format::R8G8B8,
		format::B8G8R8,
		format::A8R8G8B8,
		format::A8B8G8R8,
		format::X1R5G5B5,
		format::X4B4G4R4,
		format::R3G3B2,
		format::X2R10G10B10,
	];
	for (let i = 0z; i < len(formats); i += 1) {
		let buf = newbuffer(formats[i], 8, 8, format_stride(formats[i], 8));
		defer buffer_finish(&buf);
		buffer_test_roundtrip(&buf);
	};
};

@test fn convert() void = {
	let src = newbuffer(format::R8G8B8, 8, 8, 8 * 3);
	defer buffer_finish(&src);
	fill(&src, 0xFF00FF00);

	let dest = convert(&src, format::A8B8G8R8);
	defer buffer_finish(&dest);
	buffer_test_uniform(&dest, 0xFF00FF00);
};

@test fn convert_static() void = {
	let src = newbuffer(format::R8G8B8, 8, 8, 8 * 3);
	defer buffer_finish(&src);
	fill(&src, 0xFF00FF00);

	let dest = newbuffer(format::A8B8G8R8, 8, 8, 8 * 4);
	defer buffer_finish(&dest);
	convert_static(&dest, &src);

	buffer_test_uniform(&dest, 0xFF00FF00);
};

@test fn copy_slow() void = {
	// TODO: Test lossy copies (i.e. with incompatible bit depths)
	test_copy(format::A8R8G8B8, format::A8B8G8R8);
	test_copy(format::X2R10G10B10, format::A8B8G8R8);
	test_copy(format::R8G8B8, format::X4B4G4R4);
};

@test fn copy_fast() void = {
	test_copy(format::A8R8G8B8, format::A8R8G8B8);
	test_copy(format::A8B8G8R8, format::A8B8G8R8);
	test_copy(format::X2R10G10B10, format::X2R10G10B10);
	test_copy(format::R8G8B8, format::R8G8B8);
};

@test fn fill() void = {
	const formats = [
		format::A1,
		format::A8,
		format::R5G6B5,
		format::R8G8B8,
		format::B8G8R8,
		format::A8R8G8B8,
		format::A8B8G8R8,
		format::X1R5G5B5,
		format::X4B4G4R4,
		format::R3G3B2,
		format::X2R10G10B10,
	];
	const colors: [_]u32 = [
		0x00000000,
		0x10204080,
		0x11223344,
		0x12345678,
		0xFFFFFFFF,
	];
	for (let i = 0z; i < len(formats); i += 1)
	for (let j = 0z; j < len(colors); j += 1) {
		const format = formats[i];
		const color = colors[j];
		let buf = newbuffer(format, 8, 8, format_stride(format, 8));
		defer buffer_finish(&buf);

		fill(&buf, color);
		buffer_test_uniform(&buf, color);
	};
};

fn buffer_test_roundtrip(buf: *buffer) void = {
	// Test value:
	const test = 0x12345678u32;
	// Converted to the buffer's pixel format:
	const writein = format_convertpixel(format::A8R8G8B8, buf.fmt, test);
	// And read back to ARGB:
	const readback = format_convertpixel(buf.fmt, format::A8R8G8B8, writein);

	for (let x = 0z; x < buffer_width(buf); x += 1)
	for (let y = 0z; y < buffer_height(buf); y += 1) {
		buffer_writepixel(buf, x, y, test);
		assert(buffer_readpixel(buf, x, y) == readback);
	};
};

fn buffer_test_uniform(buf: *buffer, color: u32) void = {
	const writein = format_convertpixel(format::A8R8G8B8, buf.fmt, color);
	const readback = format_convertpixel(buf.fmt, format::A8R8G8B8, writein);

	for (let x = 0z; x < buffer_width(buf); x += 1)
	for (let y = 0z; y < buffer_height(buf); y += 1) {
		assert(buffer_readpixel(buf, x, y) == readback);
	};
};

fn test_copy(fmt_a: format, fmt_b: format) void = {
	let src = newbuffer(fmt_a, 4, 4, format_stride(fmt_a, 4));
	defer buffer_finish(&src);
	fill(&src, 0xFFFF0000);

	let dest = newbuffer(fmt_b, 8, 8, format_stride(fmt_b, 8));
	defer buffer_finish(&dest);
	fill(&dest, 0xFFFFFFFF);

	const srcrect = buffer_dimensions(&src);
	const destrect = rect {
		x = 2,
		y = 2,
		w = 4,
		h = 4,
	};
	copy(&dest, &destrect, &src, &srcrect);

	for (let x = 0z; x < buffer_width(&dest); x += 1)
	for (let y = 0z; y < buffer_height(&dest); y += 1) {
		const pixel = buffer_readpixel(&dest, x, y);
		if (x < 2 || y < 2 || x >= 6 || y >= 6) {
			assert(pixel == 0xFFFFFFFF);
		} else {
			assert(pixel == 0xFFFF0000);
		};
	};
};
