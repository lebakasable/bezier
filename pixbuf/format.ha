// XXX: All of this would probably benefit from @inline
// and/or we could use more LUTs

// Pixel formats supported by pixbuf. The values defined in this structure are
// compatible with pixman.
export type format = enum u32 {
	RGBA_FLOAT = 0x10CB4444,
	RGB_FLOAT = 0xCCB0444,
	A8R8G8B8 = 0x20028888,
	X8R8G8B8 = 0x20020888,
	A8B8G8R8 = 0x20038888,
	X8B8G8R8 = 0x20030888,
	B8G8R8A8 = 0x20088888,
	B8G8R8X8 = 0x20080888,
	R8G8B8A8 = 0x20098888,
	R8G8B8X8 = 0x20090888,
	X14R6G6B6 = 0x20020666,
	X2R10G10B10 = 0x20020AAA,
	A2R10G10B10 = 0x20022AAA,
	X2B10G10R10 = 0x20030AAA,
	A2B10G10R10 = 0x20032AAA,
	A8R8G8B8_SRGB = 0x200A8888,
	R8G8B8 = 0x18020888,
	B8G8R8 = 0x18030888,
	R5G6B5 = 0x10020565,
	B5G6R5 = 0x10030565,
	A1R5G5B5 = 0x10021555,
	X1R5G5B5 = 0x10020555,
	A1B5G5R5 = 0x10031555,
	X1B5G5R5 = 0x10030555,
	A4R4G4B4 = 0x10024444,
	X4R4G4B4 = 0x10020444,
	A4B4G4R4 = 0x10034444,
	X4B4G4R4 = 0x10030444,
	A8 = 0x8018000,
	R3G3B2 = 0x8020332,
	B2G3R3 = 0x8030332,
	A2R2G2B2 = 0x8022222,
	A2B2G2R2 = 0x8032222,
	C8 = 0x8040000,
	G8 = 0x8050000,
	X4A4 = 0x8014000,
	X4C4 = 0x8040000,
	X4G4 = 0x8050000,
	A4 = 0x4014000,
	R1G2B1 = 0x4020121,
	B1G2R1 = 0x4030121,
	A1R1G1B1 = 0x4021111,
	A1B1G1R1 = 0x4031111,
	C4 = 0x4040000,
	G4 = 0x4050000,
	A1 = 0x1011000,
	G1 = 0x1050000,
	YUY2 = 0x10060000,
	YV12 = 0xC070000,
};

// The general format class of a [[format]].
export type fmttype = enum {
	OTHER,
	A,
	ARGB,
	ABGR,
	COLOR,
	GRAY,
	YUY2,
	YV12,
	BGRA,
	RGBA,
	ARGB_SRGB,
	RGBA_FLOAT,
};

// Returns true if this color format uses a color palette.
export fn format_isindexed(fmt: format) bool = {
	return format_type(fmt) == fmttype::COLOR
		|| format_type(fmt) == fmttype::GRAY;
};

// Returns the stride of a pixel buffer in the given format of the given width.
export fn format_stride(fmt: format, width: size) size = {
	const bpp = format_bpp(fmt);
	let stride = width * bpp / 8;
	if (width * bpp % 8 != 0) {
		stride += 1;
	};
	return stride;
};

def BPP_SHIFT: u32 = 24;
def A_SHIFT: u32 = 12;
def R_SHIFT: u32 = 8;
def G_SHIFT: u32 = 4;
def B_SHIFT: u32 = 0;

def BPP_NBITS: u32 = 8;
def CHAN_NBITS: u32 = 4;

// Returns the bits-per-pixel for a given [[format]].
export fn format_bpp(fmt: format) u8 =
	(((fmt >> BPP_SHIFT) & ((1 << BPP_NBITS) - 1)) << ((fmt >> 22) & 3)): u8;

// Returns the format type for a given [[format]].
export fn format_type(fmt: format) fmttype =
	((fmt >> 16) & 0x3F): fmttype;

// Returns true if the given pixel format represents color pixels.
export fn format_color(fmt: format) bool = {
	const ftype = format_type(fmt);
	switch (ftype) {
	case fmttype::ARGB, fmttype::ABGR, fmttype::BGRA,
			fmttype::RGBA, fmttype::RGBA_FLOAT =>
		return true;
	case =>
		return false;
	};
};

// Returns the number of bits in the alpha channel of this format.
export fn format_adepth(fmt: format) u8 =
	(((fmt >> A_SHIFT) & ((1 << CHAN_NBITS) - 1)) << ((fmt >> 22) & 3)): u8;

// Returns the number of bits in the red channel of this format.
export fn format_rdepth(fmt: format) u8 =
	(((fmt >> R_SHIFT) & ((1 << CHAN_NBITS) - 1)) << ((fmt >> 22) & 3)): u8;

// Returns the number of bits in the green channel of this format.
export fn format_gdepth(fmt: format) u8 =
	(((fmt >> G_SHIFT) & ((1 << CHAN_NBITS) - 1)) << ((fmt >> 22) & 3)): u8;

// Returns the number of bits in the blue channel of this format.
export fn format_bdepth(fmt: format) u8 =
	(((fmt >> B_SHIFT) & ((1 << CHAN_NBITS) - 1)) << ((fmt >> 22) & 3)): u8;

// Returns the bit depth of the red, green, and blue components of this format.
export fn format_rgbdepth(fmt: format) u8 = (fmt & 0xFFF): u8;

// Returns the bit depth of this format.
export fn format_bitdepth(fmt: format) u8 =
	(((fmt >> A_SHIFT) & ((1 << CHAN_NBITS) - 1)) << ((fmt >> 22) & 3)): u8 +
	(((fmt >> R_SHIFT) & ((1 << CHAN_NBITS) - 1)) << ((fmt >> 22) & 3)): u8 +
	(((fmt >> G_SHIFT) & ((1 << CHAN_NBITS) - 1)) << ((fmt >> 22) & 3)): u8 +
	(((fmt >> B_SHIFT) & ((1 << CHAN_NBITS) - 1)) << ((fmt >> 22) & 3)): u8;

// Re-generate me with:
// https://paste.sr.ht/~sircmpwn/896db65f0557d77ecf361355a5979b262a2a3626
const shifts: [_](format, (u32, u32, u32, u32)) = [
	(format::A8R8G8B8, (24, 16, 8, 0)),
	(format::X8R8G8B8, (24, 16, 8, 0)),
	(format::A8B8G8R8, (24, 0, 8, 16)),
	(format::X8B8G8R8, (24, 0, 8, 16)),
	(format::B8G8R8A8, (0, 8, 16, 24)),
	(format::B8G8R8X8, (8, 8, 16, 24)),
	(format::R8G8B8A8, (0, 24, 16, 8)),
	(format::R8G8B8X8, (0, 24, 16, 8)),
	(format::X14R6G6B6, (18, 12, 6, 0)),
	(format::X2R10G10B10, (30, 20, 10, 0)),
	(format::A2R10G10B10, (30, 20, 10, 0)),
	(format::X2B10G10R10, (30, 0, 10, 20)),
	(format::A2B10G10R10, (30, 0, 10, 20)),
	(format::A8R8G8B8_SRGB, (24, 16, 8, 0)),
	(format::R8G8B8, (24, 16, 8, 0)),
	(format::B8G8R8, (24, 0, 8, 16)),
	(format::R5G6B5, (16, 11, 5, 0)),
	(format::B5G6R5, (16, 0, 5, 11)),
	(format::A1R5G5B5, (15, 10, 5, 0)),
	(format::X1R5G5B5, (15, 10, 5, 0)),
	(format::A1B5G5R5, (15, 0, 5, 10)),
	(format::X1B5G5R5, (15, 0, 5, 10)),
	(format::A4R4G4B4, (12, 8, 4, 0)),
	(format::X4R4G4B4, (12, 8, 4, 0)),
	(format::A4B4G4R4, (12, 0, 4, 8)),
	(format::X4B4G4R4, (12, 0, 4, 8)),
	(format::A8, (0, 0, 0, 0)),
	(format::R3G3B2, (8, 5, 2, 0)),
	(format::B2G3R3, (8, 0, 3, 6)),
	(format::A2R2G2B2, (6, 4, 2, 0)),
	(format::A2B2G2R2, (6, 0, 2, 4)),
	(format::X4A4, (0, 0, 0, 0)),
	(format::A4, (0, 0, 0, 0)),
	(format::R1G2B1, (4, 3, 1, 0)),
	(format::B1G2R1, (4, 0, 1, 3)),
	(format::A1R1G1B1, (3, 2, 1, 0)),
	(format::A1B1G1R1, (3, 0, 1, 2)),
	(format::A1, (0, 0, 0, 0)),
];

fn format_shifts(fmt: format) (u32, u32, u32, u32) = {
	for (let i = 0z; i < len(shifts); i += 1) {
		const (cand, shifts) = shifts[i];
		if (cand == fmt) {
			return shifts;
		};
	};
	abort();
};

fn unorm_convert(val: u32, nfrom: u32, nto: u32) u32 = {
	val &= (1 << nfrom) - 1;
	if (nfrom >= nto) {
		return val >> (nfrom - nto);
	};

	// XXX: Consider unrolling this, pixman style
	let new = val << (nto - nfrom);
	for (let i = 0z; i < 5; i += 1) {
		if (nfrom < nto) {
			new |= new >> nfrom;
			nfrom *= 2;
		};
	};

	return new;
};

fn chanconvert(
	pixel: u32,
	default: u32,
	nfrom: u32,
	sfrom: u32,
	nto: u32,
	sto: u32,
) u32 = {
	let val: u32 = if (nfrom != 0 && nto != 0) {
		yield unorm_convert(pixel >> sfrom, nfrom, nto);
	} else if (nto != 0) {
		yield default;
	} else {
		yield 0;
	};
	return (val & ((1 << nto) - 1)) << sto;
};

// Converts a pixel from one format to another.
fn format_convertpixel(from: format, to: format, pixel: u32) u32 = {
	if (to == from) {
		return pixel;
	};

	const (fashift, frshift, fgshift, fbshift) = format_shifts(from);
	const (tashift, trshift, tgshift, tbshift) = format_shifts(to);
	const a = chanconvert(pixel, ~0,
		format_adepth(from), fashift,
		format_adepth(to), tashift);
	const r = chanconvert(pixel, ~0,
		format_rdepth(from), frshift,
		format_rdepth(to), trshift);
	const g = chanconvert(pixel, ~0,
		format_gdepth(from), fgshift,
		format_gdepth(to), tgshift);
	const b = chanconvert(pixel, ~0,
		format_bdepth(from), fbshift,
		format_bdepth(to), tbshift);
	return a | r | g | b;
};

// These tests are just to make sure my bit munging is correct.
@test fn format_bpp() void = {
	assert(format_bpp(format::RGBA_FLOAT) == 128);
	assert(format_bpp(format::RGB_FLOAT) == 96);
	assert(format_bpp(format::A8R8G8B8) == 32);
	assert(format_bpp(format::X8R8G8B8) == 32);
	assert(format_bpp(format::A8B8G8R8) == 32);
	assert(format_bpp(format::X8B8G8R8) == 32);
	assert(format_bpp(format::B8G8R8A8) == 32);
	assert(format_bpp(format::B8G8R8X8) == 32);
	assert(format_bpp(format::R8G8B8A8) == 32);
	assert(format_bpp(format::R8G8B8X8) == 32);
	assert(format_bpp(format::X14R6G6B6) == 32);
	assert(format_bpp(format::X2R10G10B10) == 32);
	assert(format_bpp(format::A2R10G10B10) == 32);
	assert(format_bpp(format::X2B10G10R10) == 32);
	assert(format_bpp(format::A2B10G10R10) == 32);
	assert(format_bpp(format::A8R8G8B8_SRGB) == 32);
	assert(format_bpp(format::R8G8B8) == 24);
	assert(format_bpp(format::B8G8R8) == 24);
	assert(format_bpp(format::R5G6B5) == 16);
	assert(format_bpp(format::B5G6R5) == 16);
	assert(format_bpp(format::A1R5G5B5) == 16);
	assert(format_bpp(format::X1R5G5B5) == 16);
	assert(format_bpp(format::A1B5G5R5) == 16);
	assert(format_bpp(format::X1B5G5R5) == 16);
	assert(format_bpp(format::A4R4G4B4) == 16);
	assert(format_bpp(format::X4R4G4B4) == 16);
	assert(format_bpp(format::A4B4G4R4) == 16);
	assert(format_bpp(format::X4B4G4R4) == 16);
	assert(format_bpp(format::A8) == 8);
	assert(format_bpp(format::R3G3B2) == 8);
	assert(format_bpp(format::B2G3R3) == 8);
	assert(format_bpp(format::A2R2G2B2) == 8);
	assert(format_bpp(format::A2B2G2R2) == 8);
	assert(format_bpp(format::C8) == 8);
	assert(format_bpp(format::G8) == 8);
	assert(format_bpp(format::X4A4) == 8);
	assert(format_bpp(format::X4C4) == 8);
	assert(format_bpp(format::X4G4) == 8);
	assert(format_bpp(format::A4) == 4);
	assert(format_bpp(format::R1G2B1) == 4);
	assert(format_bpp(format::B1G2R1) == 4);
	assert(format_bpp(format::A1R1G1B1) == 4);
	assert(format_bpp(format::A1B1G1R1) == 4);
	assert(format_bpp(format::C4) == 4);
	assert(format_bpp(format::G4) == 4);
	assert(format_bpp(format::A1) == 1);
	assert(format_bpp(format::G1) == 1);
	assert(format_bpp(format::YUY2) == 16);
	assert(format_bpp(format::YV12) == 12);
};

@test fn format_type() void = {
	assert(format_type(format::RGBA_FLOAT) == fmttype::RGBA_FLOAT);
	assert(format_type(format::RGB_FLOAT) == fmttype::RGBA_FLOAT);
	assert(format_type(format::A8R8G8B8) == fmttype::ARGB);
	assert(format_type(format::X8R8G8B8) == fmttype::ARGB);
	assert(format_type(format::A8B8G8R8) == fmttype::ABGR);
	assert(format_type(format::X8B8G8R8) == fmttype::ABGR);
	assert(format_type(format::B8G8R8A8) == fmttype::BGRA);
	assert(format_type(format::B8G8R8X8) == fmttype::BGRA);
	assert(format_type(format::R8G8B8A8) == fmttype::RGBA);
	assert(format_type(format::R8G8B8X8) == fmttype::RGBA);
	assert(format_type(format::X14R6G6B6) == fmttype::ARGB);
	assert(format_type(format::X2R10G10B10) == fmttype::ARGB);
	assert(format_type(format::A2R10G10B10) == fmttype::ARGB);
	assert(format_type(format::X2B10G10R10) == fmttype::ABGR);
	assert(format_type(format::A2B10G10R10) == fmttype::ABGR);
	assert(format_type(format::A8R8G8B8_SRGB) == fmttype::ARGB_SRGB);
	assert(format_type(format::R8G8B8) == fmttype::ARGB);
	assert(format_type(format::B8G8R8) == fmttype::ABGR);
	assert(format_type(format::R5G6B5) == fmttype::ARGB);
	assert(format_type(format::B5G6R5) == fmttype::ABGR);
	assert(format_type(format::A1R5G5B5) == fmttype::ARGB);
	assert(format_type(format::X1R5G5B5) == fmttype::ARGB);
	assert(format_type(format::A1B5G5R5) == fmttype::ABGR);
	assert(format_type(format::X1B5G5R5) == fmttype::ABGR);
	assert(format_type(format::A4R4G4B4) == fmttype::ARGB);
	assert(format_type(format::X4R4G4B4) == fmttype::ARGB);
	assert(format_type(format::A4B4G4R4) == fmttype::ABGR);
	assert(format_type(format::X4B4G4R4) == fmttype::ABGR);
	assert(format_type(format::A8) == fmttype::A);
	assert(format_type(format::R3G3B2) == fmttype::ARGB);
	assert(format_type(format::B2G3R3) == fmttype::ABGR);
	assert(format_type(format::A2R2G2B2) == fmttype::ARGB);
	assert(format_type(format::A2B2G2R2) == fmttype::ABGR);
	assert(format_type(format::C8) == fmttype::COLOR);
	assert(format_type(format::G8) == fmttype::GRAY);
	assert(format_type(format::X4A4) == fmttype::A);
	assert(format_type(format::X4C4) == fmttype::COLOR);
	assert(format_type(format::X4G4) == fmttype::GRAY);
	assert(format_type(format::A4) == fmttype::A);
	assert(format_type(format::R1G2B1) == fmttype::ARGB);
	assert(format_type(format::B1G2R1) == fmttype::ABGR);
	assert(format_type(format::A1R1G1B1) == fmttype::ARGB);
	assert(format_type(format::A1B1G1R1) == fmttype::ABGR);
	assert(format_type(format::C4) == fmttype::COLOR);
	assert(format_type(format::G4) == fmttype::GRAY);
	assert(format_type(format::A1) == fmttype::A);
	assert(format_type(format::G1) == fmttype::GRAY);
	assert(format_type(format::YUY2) == fmttype::YUY2);
	assert(format_type(format::YV12) == fmttype::YV12);
};

@test fn format_adepth() void = {
	assert(format_adepth(format::RGBA_FLOAT) == 32);
	assert(format_adepth(format::RGB_FLOAT) == 0);
	assert(format_adepth(format::A8R8G8B8) == 8);
	assert(format_adepth(format::X8R8G8B8) == 0);
	assert(format_adepth(format::A8B8G8R8) == 8);
	assert(format_adepth(format::X8B8G8R8) == 0);
	assert(format_adepth(format::B8G8R8A8) == 8);
	assert(format_adepth(format::B8G8R8X8) == 0);
	assert(format_adepth(format::R8G8B8A8) == 8);
	assert(format_adepth(format::R8G8B8X8) == 0);
	assert(format_adepth(format::X14R6G6B6) == 0);
	assert(format_adepth(format::X2R10G10B10) == 0);
	assert(format_adepth(format::A2R10G10B10) == 2);
	assert(format_adepth(format::X2B10G10R10) == 0);
	assert(format_adepth(format::A2B10G10R10) == 2);
	assert(format_adepth(format::A8R8G8B8_SRGB) == 8);
	assert(format_adepth(format::R8G8B8) == 0);
	assert(format_adepth(format::B8G8R8) == 0);
	assert(format_adepth(format::R5G6B5) == 0);
	assert(format_adepth(format::B5G6R5) == 0);
	assert(format_adepth(format::A1R5G5B5) == 1);
	assert(format_adepth(format::X1R5G5B5) == 0);
	assert(format_adepth(format::A1B5G5R5) == 1);
	assert(format_adepth(format::X1B5G5R5) == 0);
	assert(format_adepth(format::A4R4G4B4) == 4);
	assert(format_adepth(format::X4R4G4B4) == 0);
	assert(format_adepth(format::A4B4G4R4) == 4);
	assert(format_adepth(format::X4B4G4R4) == 0);
	assert(format_adepth(format::A8) == 8);
	assert(format_adepth(format::R3G3B2) == 0);
	assert(format_adepth(format::B2G3R3) == 0);
	assert(format_adepth(format::A2R2G2B2) == 2);
	assert(format_adepth(format::A2B2G2R2) == 2);
	assert(format_adepth(format::C8) == 0);
	assert(format_adepth(format::G8) == 0);
	assert(format_adepth(format::X4A4) == 4);
	assert(format_adepth(format::X4C4) == 0);
	assert(format_adepth(format::X4G4) == 0);
	assert(format_adepth(format::A4) == 4);
	assert(format_adepth(format::R1G2B1) == 0);
	assert(format_adepth(format::B1G2R1) == 0);
	assert(format_adepth(format::A1R1G1B1) == 1);
	assert(format_adepth(format::A1B1G1R1) == 1);
	assert(format_adepth(format::C4) == 0);
	assert(format_adepth(format::G4) == 0);
	assert(format_adepth(format::A1) == 1);
	assert(format_adepth(format::G1) == 0);
	assert(format_adepth(format::YUY2) == 0);
	assert(format_adepth(format::YV12) == 0);
};

@test fn format_rdepth() void = {
	assert(format_rdepth(format::RGBA_FLOAT) == 32);
	assert(format_rdepth(format::RGB_FLOAT) == 32);
	assert(format_rdepth(format::A8R8G8B8) == 8);
	assert(format_rdepth(format::X8R8G8B8) == 8);
	assert(format_rdepth(format::A8B8G8R8) == 8);
	assert(format_rdepth(format::X8B8G8R8) == 8);
	assert(format_rdepth(format::B8G8R8A8) == 8);
	assert(format_rdepth(format::B8G8R8X8) == 8);
	assert(format_rdepth(format::R8G8B8A8) == 8);
	assert(format_rdepth(format::R8G8B8X8) == 8);
	assert(format_rdepth(format::X14R6G6B6) == 6);
	assert(format_rdepth(format::X2R10G10B10) == 10);
	assert(format_rdepth(format::A2R10G10B10) == 10);
	assert(format_rdepth(format::X2B10G10R10) == 10);
	assert(format_rdepth(format::A2B10G10R10) == 10);
	assert(format_rdepth(format::A8R8G8B8_SRGB) == 8);
	assert(format_rdepth(format::R8G8B8) == 8);
	assert(format_rdepth(format::B8G8R8) == 8);
	assert(format_rdepth(format::R5G6B5) == 5);
	assert(format_rdepth(format::B5G6R5) == 5);
	assert(format_rdepth(format::A1R5G5B5) == 5);
	assert(format_rdepth(format::X1R5G5B5) == 5);
	assert(format_rdepth(format::A1B5G5R5) == 5);
	assert(format_rdepth(format::X1B5G5R5) == 5);
	assert(format_rdepth(format::A4R4G4B4) == 4);
	assert(format_rdepth(format::X4R4G4B4) == 4);
	assert(format_rdepth(format::A4B4G4R4) == 4);
	assert(format_rdepth(format::X4B4G4R4) == 4);
	assert(format_rdepth(format::A8) == 0);
	assert(format_rdepth(format::R3G3B2) == 3);
	assert(format_rdepth(format::B2G3R3) == 3);
	assert(format_rdepth(format::A2R2G2B2) == 2);
	assert(format_rdepth(format::A2B2G2R2) == 2);
	assert(format_rdepth(format::C8) == 0);
	assert(format_rdepth(format::G8) == 0);
	assert(format_rdepth(format::X4A4) == 0);
	assert(format_rdepth(format::X4C4) == 0);
	assert(format_rdepth(format::X4G4) == 0);
	assert(format_rdepth(format::A4) == 0);
	assert(format_rdepth(format::R1G2B1) == 1);
	assert(format_rdepth(format::B1G2R1) == 1);
	assert(format_rdepth(format::A1R1G1B1) == 1);
	assert(format_rdepth(format::A1B1G1R1) == 1);
	assert(format_rdepth(format::C4) == 0);
	assert(format_rdepth(format::G4) == 0);
	assert(format_rdepth(format::A1) == 0);
	assert(format_rdepth(format::G1) == 0);
	assert(format_rdepth(format::YUY2) == 0);
	assert(format_rdepth(format::YV12) == 0);
};

@test fn format_gdepth() void = {
	assert(format_gdepth(format::RGBA_FLOAT) == 32);
	assert(format_gdepth(format::RGB_FLOAT) == 32);
	assert(format_gdepth(format::A8R8G8B8) == 8);
	assert(format_gdepth(format::X8R8G8B8) == 8);
	assert(format_gdepth(format::A8B8G8R8) == 8);
	assert(format_gdepth(format::X8B8G8R8) == 8);
	assert(format_gdepth(format::B8G8R8A8) == 8);
	assert(format_gdepth(format::B8G8R8X8) == 8);
	assert(format_gdepth(format::R8G8B8A8) == 8);
	assert(format_gdepth(format::R8G8B8X8) == 8);
	assert(format_gdepth(format::X14R6G6B6) == 6);
	assert(format_gdepth(format::X2R10G10B10) == 10);
	assert(format_gdepth(format::A2R10G10B10) == 10);
	assert(format_gdepth(format::X2B10G10R10) == 10);
	assert(format_gdepth(format::A2B10G10R10) == 10);
	assert(format_gdepth(format::A8R8G8B8_SRGB) == 8);
	assert(format_gdepth(format::R8G8B8) == 8);
	assert(format_gdepth(format::B8G8R8) == 8);
	assert(format_gdepth(format::R5G6B5) == 6);
	assert(format_gdepth(format::B5G6R5) == 6);
	assert(format_gdepth(format::A1R5G5B5) == 5);
	assert(format_gdepth(format::X1R5G5B5) == 5);
	assert(format_gdepth(format::A1B5G5R5) == 5);
	assert(format_gdepth(format::X1B5G5R5) == 5);
	assert(format_gdepth(format::A4R4G4B4) == 4);
	assert(format_gdepth(format::X4R4G4B4) == 4);
	assert(format_gdepth(format::A4B4G4R4) == 4);
	assert(format_gdepth(format::X4B4G4R4) == 4);
	assert(format_gdepth(format::A8) == 0);
	assert(format_gdepth(format::R3G3B2) == 3);
	assert(format_gdepth(format::B2G3R3) == 3);
	assert(format_gdepth(format::A2R2G2B2) == 2);
	assert(format_gdepth(format::A2B2G2R2) == 2);
	assert(format_gdepth(format::C8) == 0);
	assert(format_gdepth(format::G8) == 0);
	assert(format_gdepth(format::X4A4) == 0);
	assert(format_gdepth(format::X4C4) == 0);
	assert(format_gdepth(format::X4G4) == 0);
	assert(format_gdepth(format::A4) == 0);
	assert(format_gdepth(format::R1G2B1) == 2);
	assert(format_gdepth(format::B1G2R1) == 2);
	assert(format_gdepth(format::A1R1G1B1) == 1);
	assert(format_gdepth(format::A1B1G1R1) == 1);
	assert(format_gdepth(format::C4) == 0);
	assert(format_gdepth(format::G4) == 0);
	assert(format_gdepth(format::A1) == 0);
	assert(format_gdepth(format::G1) == 0);
	assert(format_gdepth(format::YUY2) == 0);
	assert(format_gdepth(format::YV12) == 0);
};

@test fn format_bdepth() void = {
	assert(format_bdepth(format::RGBA_FLOAT) == 32);
	assert(format_bdepth(format::RGB_FLOAT) == 32);
	assert(format_bdepth(format::A8R8G8B8) == 8);
	assert(format_bdepth(format::X8R8G8B8) == 8);
	assert(format_bdepth(format::A8B8G8R8) == 8);
	assert(format_bdepth(format::X8B8G8R8) == 8);
	assert(format_bdepth(format::B8G8R8A8) == 8);
	assert(format_bdepth(format::B8G8R8X8) == 8);
	assert(format_bdepth(format::R8G8B8A8) == 8);
	assert(format_bdepth(format::R8G8B8X8) == 8);
	assert(format_bdepth(format::X14R6G6B6) == 6);
	assert(format_bdepth(format::X2R10G10B10) == 10);
	assert(format_bdepth(format::A2R10G10B10) == 10);
	assert(format_bdepth(format::X2B10G10R10) == 10);
	assert(format_bdepth(format::A2B10G10R10) == 10);
	assert(format_bdepth(format::A8R8G8B8_SRGB) == 8);
	assert(format_bdepth(format::R8G8B8) == 8);
	assert(format_bdepth(format::B8G8R8) == 8);
	assert(format_bdepth(format::R5G6B5) == 5);
	assert(format_bdepth(format::B5G6R5) == 5);
	assert(format_bdepth(format::A1R5G5B5) == 5);
	assert(format_bdepth(format::X1R5G5B5) == 5);
	assert(format_bdepth(format::A1B5G5R5) == 5);
	assert(format_bdepth(format::X1B5G5R5) == 5);
	assert(format_bdepth(format::A4R4G4B4) == 4);
	assert(format_bdepth(format::X4R4G4B4) == 4);
	assert(format_bdepth(format::A4B4G4R4) == 4);
	assert(format_bdepth(format::X4B4G4R4) == 4);
	assert(format_bdepth(format::A8) == 0);
	assert(format_bdepth(format::R3G3B2) == 2);
	assert(format_bdepth(format::B2G3R3) == 2);
	assert(format_bdepth(format::A2R2G2B2) == 2);
	assert(format_bdepth(format::A2B2G2R2) == 2);
	assert(format_bdepth(format::C8) == 0);
	assert(format_bdepth(format::G8) == 0);
	assert(format_bdepth(format::X4A4) == 0);
	assert(format_bdepth(format::X4C4) == 0);
	assert(format_bdepth(format::X4G4) == 0);
	assert(format_bdepth(format::A4) == 0);
	assert(format_bdepth(format::R1G2B1) == 1);
	assert(format_bdepth(format::B1G2R1) == 1);
	assert(format_bdepth(format::A1R1G1B1) == 1);
	assert(format_bdepth(format::A1B1G1R1) == 1);
	assert(format_bdepth(format::C4) == 0);
	assert(format_bdepth(format::G4) == 0);
	assert(format_bdepth(format::A1) == 0);
	assert(format_bdepth(format::G1) == 0);
	assert(format_bdepth(format::YUY2) == 0);
	assert(format_bdepth(format::YV12) == 0);
};

@test fn format_bitdepth() void = {
	assert(format_bitdepth(format::RGBA_FLOAT) == 128);
	assert(format_bitdepth(format::RGB_FLOAT) == 96);
	assert(format_bitdepth(format::A8R8G8B8) == 32);
	assert(format_bitdepth(format::X8R8G8B8) == 24);
	assert(format_bitdepth(format::A8B8G8R8) == 32);
	assert(format_bitdepth(format::X8B8G8R8) == 24);
	assert(format_bitdepth(format::B8G8R8A8) == 32);
	assert(format_bitdepth(format::B8G8R8X8) == 24);
	assert(format_bitdepth(format::R8G8B8A8) == 32);
	assert(format_bitdepth(format::R8G8B8X8) == 24);
	assert(format_bitdepth(format::X14R6G6B6) == 18);
	assert(format_bitdepth(format::X2R10G10B10) == 30);
	assert(format_bitdepth(format::A2R10G10B10) == 32);
	assert(format_bitdepth(format::X2B10G10R10) == 30);
	assert(format_bitdepth(format::A2B10G10R10) == 32);
	assert(format_bitdepth(format::A8R8G8B8_SRGB) == 32);
	assert(format_bitdepth(format::R8G8B8) == 24);
	assert(format_bitdepth(format::B8G8R8) == 24);
	assert(format_bitdepth(format::R5G6B5) == 16);
	assert(format_bitdepth(format::B5G6R5) == 16);
	assert(format_bitdepth(format::A1R5G5B5) == 16);
	assert(format_bitdepth(format::X1R5G5B5) == 15);
	assert(format_bitdepth(format::A1B5G5R5) == 16);
	assert(format_bitdepth(format::X1B5G5R5) == 15);
	assert(format_bitdepth(format::A4R4G4B4) == 16);
	assert(format_bitdepth(format::X4R4G4B4) == 12);
	assert(format_bitdepth(format::A4B4G4R4) == 16);
	assert(format_bitdepth(format::X4B4G4R4) == 12);
	assert(format_bitdepth(format::A8) == 8);
	assert(format_bitdepth(format::R3G3B2) == 8);
	assert(format_bitdepth(format::B2G3R3) == 8);
	assert(format_bitdepth(format::A2R2G2B2) == 8);
	assert(format_bitdepth(format::A2B2G2R2) == 8);
	assert(format_bitdepth(format::C8) == 0);
	assert(format_bitdepth(format::G8) == 0);
	assert(format_bitdepth(format::X4A4) == 4);
	assert(format_bitdepth(format::X4C4) == 0);
	assert(format_bitdepth(format::X4G4) == 0);
	assert(format_bitdepth(format::A4) == 4);
	assert(format_bitdepth(format::R1G2B1) == 4);
	assert(format_bitdepth(format::B1G2R1) == 4);
	assert(format_bitdepth(format::A1R1G1B1) == 4);
	assert(format_bitdepth(format::A1B1G1R1) == 4);
	assert(format_bitdepth(format::C4) == 0);
	assert(format_bitdepth(format::G4) == 0);
	assert(format_bitdepth(format::A1) == 1);
	assert(format_bitdepth(format::G1) == 0);
	assert(format_bitdepth(format::YUY2) == 0);
	assert(format_bitdepth(format::YV12) == 0);
};
