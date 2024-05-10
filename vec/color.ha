use ascii;
use math;
use sort;

// Returns a [[color]] from an RGBA value.
export fn from_rgba(rgba: u32) color = {
	const a = ((rgba >> 0) & 0xFF): f32 / 255f32;
	const b = ((rgba >> 8) & 0xFF): f32 / 255f32;
	const g = ((rgba >> 16) & 0xFF): f32 / 255f32;
	const r = ((rgba >> 24) & 0xFF): f32 / 255f32;
	return (r, g, b, a);
};

// Returns an RGBA value from a [[color]].
export fn to_rgba(color: *color) u32 = {
	const (r, g, b, a) = *color;
	return
		((r * 255.0): u32 << 24) |
		((g * 255.0): u32 << 16) |
		((b * 255.0): u32 << 8) |
		((a * 255.0): u32 << 0);
};

fn max(a: *f32, b: *f32, c: *f32) *f32 = {
	let r = a;
	if (*b > *r) {
		r = b;
	};
	if (*c > *r) {
		r = c;
	};
	return r;
};

fn min(a: *f32, b: *f32, c: *f32) *f32 = {
	let r = a;
	if (*b < *r) {
		r = b;
	};
	if (*c < *r) {
		r = c;
	};
	return r;
};

// Returns an [[hsla]] from a [[color]].
export fn to_hsla(color: *color) hsla = {
	const R = color.0, G = color.1, B = color.2, A = color.3;
	const Xmax = max(&R, &G, &B);
	const Xmin = min(&R, &G, &B);
	const C = *Xmax - *Xmin;
	const L = (*Xmax + *Xmin)/2f32;
	let H = 0f32;

	if (*Xmax != *Xmin) {
		if (Xmax == &R) {
			H = 60f32/360f32 * (G-B)/C;
		} else if (Xmax == &G) {
			H = 60f32/360f32 * (2f32 + (B-R)/C);
		} else if (Xmax == &B) {
			H = 60f32/360f32 * (4f32 + (R-G)/C);
		};
	};

	if (H < 0f32) {
		H += 1f32;
	};

	let S = if (L == 0f32 || L == 1f32) 0f32
		else (C/(1f32 - math::absf32(2f32*L - 1f32)));
	return (H, S, L, A);
};

// Returns a [[color]] from an [[hsla]].
export fn from_hsla(color: *hsla) color = {
	const H = color.0, S = color.1, L = color.2, A = color.3;
	const C = (1f32 - math::absf32(2f32*L - 1f32)) * S;
	const Hprime = H/(60f32/360f32);
	const X = C * (1f32 - math::absf32(math::modf64(Hprime, 2.0): f32 - 1f32));
	let R = 0f32, G = 0f32, B = 0f32;

	if (Hprime >= 0f32 && Hprime < 1f32) {
		R = C;
		G = X;
	} else if (Hprime >= 1f32 && Hprime < 2f32) {
		R = X;
		G = C;
	} else if (Hprime >= 2f32 && Hprime < 3f32) {
		G = C;
		B = X;
	} else if (Hprime >= 3f32 && Hprime < 4f32) {
		G = X;
		B = C;
	} else if (Hprime >= 4f32 && Hprime < 5f32) {
		R = X;
		B = C;
	} else if (Hprime >= 5f32 && Hprime < 6f32) {
		R = C;
		B = X;
	};

	const m = L - C/2f32;
	R += m;
	G += m;
	B += m;
	return (R, G, B, A);
};

// Returns a [[color]] from an ARGB value.
export fn from_argb(argb: u32) color = {
	const b = ((argb >> 0) & 0xFF): f32 / 255f32;
	const g = ((argb >> 8) & 0xFF): f32 / 255f32;
	const r = ((argb >> 16) & 0xFF): f32 / 255f32;
	const a = ((argb >> 24) & 0xFF): f32 / 255f32;
	return (r, g, b, a);
};

// Returns an ARGB value from a [[color]].
export fn to_argb(color: *color) u32 = {
	const (r, g, b, a) = *color;
	return
		((a * 255.0): u32 << 24) |
		((r * 255.0): u32 << 16) |
		((g * 255.0): u32 << 8) |
		((b * 255.0): u32 << 0);
};

// Returns a web color given its name. Case insensitive.
export fn color_fromstr(s: const str) (color | void) = {
	const i = match (sort::search(
		colortab, size((const str, *color)),
		&s, &colorcmp)) {
	case let i: size =>
		yield i;
	case void =>
		return;
	};
	return *colortab[i].1;
};

fn colorcmp(a: const *opaque, b: const *opaque) int = {
	const key = a: *str;
	const val = b: *(str, *color);
	return ascii::strcasecmp(*key, val.0);
};

const colortab: [_](const str, *color) = [
	("aliceblue", &ALICEBLUE),
	("antiquewhite", &ANTIQUEWHITE),
	("aqua", &AQUA),
	("aquamarine", &AQUAMARINE),
	("azure", &AZURE),
	("beige", &BEIGE),
	("bisque", &BISQUE),
	("black", &BLACK),
	("blanchedalmond", &BLANCHEDALMOND),
	("blue", &BLUE),
	("blueviolet", &BLUEVIOLET),
	("brown", &BROWN),
	("burlywood", &BURLYWOOD),
	("cadetblue", &CADETBLUE),
	("chartreuse", &CHARTREUSE),
	("chocolate", &CHOCOLATE),
	("coral", &CORAL),
	("cornflowerblue", &CORNFLOWERBLUE),
	("cornsilk", &CORNSILK),
	("crimson", &CRIMSON),
	("cyan", &CYAN),
	("darkblue", &DARKBLUE),
	("darkcyan", &DARKCYAN),
	("darkgoldenrod", &DARKGOLDENROD),
	("darkgray", &DARKGRAY),
	("darkgreen", &DARKGREEN),
	("darkgrey", &DARKGREY),
	("darkkhaki", &DARKKHAKI),
	("darkmagenta", &DARKMAGENTA),
	("darkolivegreen", &DARKOLIVEGREEN),
	("darkorange", &DARKORANGE),
	("darkorchid", &DARKORCHID),
	("darkred", &DARKRED),
	("darksalmon", &DARKSALMON),
	("darkseagreen", &DARKSEAGREEN),
	("darkslateblue", &DARKSLATEBLUE),
	("darkslategray", &DARKSLATEGRAY),
	("darkslategrey", &DARKSLATEGREY),
	("darkturquoise", &DARKTURQUOISE),
	("darkviolet", &DARKVIOLET),
	("deeppink", &DEEPPINK),
	("deepskyblue", &DEEPSKYBLUE),
	("dimgray", &DIMGRAY),
	("dimgrey", &DIMGREY),
	("dodgerblue", &DODGERBLUE),
	("firebrick", &FIREBRICK),
	("floralwhite", &FLORALWHITE),
	("forestgreen", &FORESTGREEN),
	("fuchsia", &FUCHSIA),
	("gainsboro", &GAINSBORO),
	("ghostwhite", &GHOSTWHITE),
	("gold", &GOLD),
	("goldenrod", &GOLDENROD),
	("gray", &GRAY),
	("green", &GREEN),
	("greenyellow", &GREENYELLOW),
	("grey", &GREY),
	("honeydew", &HONEYDEW),
	("hotpink", &HOTPINK),
	("indianred", &INDIANRED),
	("indigo", &INDIGO),
	("ivory", &IVORY),
	("khaki", &KHAKI),
	("lavender", &LAVENDER),
	("lavenderblush", &LAVENDERBLUSH),
	("lawngreen", &LAWNGREEN),
	("lemonchiffon", &LEMONCHIFFON),
	("lightblue", &LIGHTBLUE),
	("lightcoral", &LIGHTCORAL),
	("lightcyan", &LIGHTCYAN),
	("lightgoldenrodyellow", &LIGHTGOLDENRODYELLOW),
	("lightgray", &LIGHTGRAY),
	("lightgreen", &LIGHTGREEN),
	("lightgrey", &LIGHTGREY),
	("lightpink", &LIGHTPINK),
	("lightsalmon", &LIGHTSALMON),
	("lightseagreen", &LIGHTSEAGREEN),
	("lightskyblue", &LIGHTSKYBLUE),
	("lightslategray", &LIGHTSLATEGRAY),
	("lightslategrey", &LIGHTSLATEGREY),
	("lightsteelblue", &LIGHTSTEELBLUE),
	("lightyellow", &LIGHTYELLOW),
	("lime", &LIME),
	("limegreen", &LIMEGREEN),
	("linen", &LINEN),
	("magenta", &MAGENTA),
	("maroon", &MAROON),
	("mediumaquamarine", &MEDIUMAQUAMARINE),
	("mediumblue", &MEDIUMBLUE),
	("mediumorchid", &MEDIUMORCHID),
	("mediumpurple", &MEDIUMPURPLE),
	("mediumseagreen", &MEDIUMSEAGREEN),
	("mediumslateblue", &MEDIUMSLATEBLUE),
	("mediumspringgreen", &MEDIUMSPRINGGREEN),
	("mediumturquoise", &MEDIUMTURQUOISE),
	("mediumvioletred", &MEDIUMVIOLETRED),
	("midnightblue", &MIDNIGHTBLUE),
	("mintcream", &MINTCREAM),
	("mistyrose", &MISTYROSE),
	("moccasin", &MOCCASIN),
	("navajowhite", &NAVAJOWHITE),
	("navy", &NAVY),
	("oldlace", &OLDLACE),
	("olive", &OLIVE),
	("olivedrab", &OLIVEDRAB),
	("orange", &ORANGE),
	("orangered", &ORANGERED),
	("orchid", &ORCHID),
	("palegoldenrod", &PALEGOLDENROD),
	("palegreen", &PALEGREEN),
	("paleturquoise", &PALETURQUOISE),
	("palevioletred", &PALEVIOLETRED),
	("papayawhip", &PAPAYAWHIP),
	("peachpuff", &PEACHPUFF),
	("peru", &PERU),
	("pink", &PINK),
	("plum", &PLUM),
	("powderblue", &POWDERBLUE),
	("purple", &PURPLE),
	("red", &RED),
	("rosybrown", &ROSYBROWN),
	("royalblue", &ROYALBLUE),
	("saddlebrown", &SADDLEBROWN),
	("salmon", &SALMON),
	("sandybrown", &SANDYBROWN),
	("seagreen", &SEAGREEN),
	("seashell", &SEASHELL),
	("sienna", &SIENNA),
	("silver", &SILVER),
	("skyblue", &SKYBLUE),
	("slateblue", &SLATEBLUE),
	("slategray", &SLATEGRAY),
	("slategrey", &SLATEGREY),
	("snow", &SNOW),
	("springgreen", &SPRINGGREEN),
	("steelblue", &STEELBLUE),
	("tan", &TAN),
	("teal", &TEAL),
	("thistle", &THISTLE),
	("tomato", &TOMATO),
	("turquoise", &TURQUOISE),
	("violet", &VIOLET),
	("wheat", &WHEAT),
	("white", &WHITE),
	("whitesmoke", &WHITESMOKE),
	("yellow", &YELLOW),
	("yellowgreen", &YELLOWGREEN),
];

export const ALICEBLUE: color = (240.0 / 255.0, 248.0 / 255.0, 255.0 / 255.0, 1.0);
export const ANTIQUEWHITE: color = (250.0 / 255.0, 235.0 / 255.0, 215.0 / 255.0, 1.0);
export const AQUA: color = (0.0 / 255.0, 255.0 / 255.0, 255.0 / 255.0, 1.0);
export const AQUAMARINE: color = (127.0 / 255.0, 255.0 / 255.0, 212.0 / 255.0, 1.0);
export const AZURE: color = (240.0 / 255.0, 255.0 / 255.0, 255.0 / 255.0, 1.0);
export const BEIGE: color = (245.0 / 255.0, 245.0 / 255.0, 220.0 / 255.0, 1.0);
export const BISQUE: color = (255.0 / 255.0, 228.0 / 255.0, 196.0 / 255.0, 1.0);
export const BLACK: color = (0.0 / 255.0, 0.0 / 255.0, 0.0 / 255.0, 1.0);
export const BLANCHEDALMOND: color = (255.0 / 255.0, 235.0 / 255.0, 205.0 / 255.0, 1.0);
export const BLUE: color = (0.0 / 255.0, 0.0 / 255.0, 255.0 / 255.0, 1.0);
export const BLUEVIOLET: color = (138.0 / 255.0, 43.0 / 255.0, 226.0 / 255.0, 1.0);
export const BROWN: color = (165.0 / 255.0, 42.0 / 255.0, 42.0 / 255.0, 1.0);
export const BURLYWOOD: color = (222.0 / 255.0, 184.0 / 255.0, 135.0 / 255.0, 1.0);
export const CADETBLUE: color = (95.0 / 255.0, 158.0 / 255.0, 160.0 / 255.0, 1.0);
export const CHARTREUSE: color = (127.0 / 255.0, 255.0 / 255.0, 0.0 / 255.0, 1.0);
export const CHOCOLATE: color = (210.0 / 255.0, 105.0 / 255.0, 30.0 / 255.0, 1.0);
export const CORAL: color = (255.0 / 255.0, 127.0 / 255.0, 80.0 / 255.0, 1.0);
export const CORNFLOWERBLUE: color = (100.0 / 255.0, 149.0 / 255.0, 237.0 / 255.0, 1.0);
export const CORNSILK: color = (255.0 / 255.0, 248.0 / 255.0, 220.0 / 255.0, 1.0);
export const CRIMSON: color = (220.0 / 255.0, 20.0 / 255.0, 60.0 / 255.0, 1.0);
export const CYAN: color = (0.0 / 255.0, 255.0 / 255.0, 255.0 / 255.0, 1.0);
export const DARKBLUE: color = (0.0 / 255.0, 0.0 / 255.0, 139.0 / 255.0, 1.0);
export const DARKCYAN: color = (0.0 / 255.0, 139.0 / 255.0, 139.0 / 255.0, 1.0);
export const DARKGOLDENROD: color = (184.0 / 255.0, 134.0 / 255.0, 11.0 / 255.0, 1.0);
export const DARKGRAY: color = (169.0 / 255.0, 169.0 / 255.0, 169.0 / 255.0, 1.0);
export const DARKGREEN: color = (0.0 / 255.0, 100.0 / 255.0, 0.0 / 255.0, 1.0);
export const DARKGREY: color = (169.0 / 255.0, 169.0 / 255.0, 169.0 / 255.0, 1.0);
export const DARKKHAKI: color = (189.0 / 255.0, 183.0 / 255.0, 107.0 / 255.0, 1.0);
export const DARKMAGENTA: color = (139.0 / 255.0, 0.0 / 255.0, 139.0 / 255.0, 1.0);
export const DARKOLIVEGREEN: color = (85.0 / 255.0, 107.0 / 255.0, 47.0 / 255.0, 1.0);
export const DARKORANGE: color = (255.0 / 255.0, 140.0 / 255.0, 0.0 / 255.0, 1.0);
export const DARKORCHID: color = (153.0 / 255.0, 50.0 / 255.0, 204.0 / 255.0, 1.0);
export const DARKRED: color = (139.0 / 255.0, 0.0 / 255.0, 0.0 / 255.0, 1.0);
export const DARKSALMON: color = (233.0 / 255.0, 150.0 / 255.0, 122.0 / 255.0, 1.0);
export const DARKSEAGREEN: color = (143.0 / 255.0, 188.0 / 255.0, 143.0 / 255.0, 1.0);
export const DARKSLATEBLUE: color = (72.0 / 255.0, 61.0 / 255.0, 139.0 / 255.0, 1.0);
export const DARKSLATEGRAY: color = (47.0 / 255.0, 79.0 / 255.0, 79.0 / 255.0, 1.0);
export const DARKSLATEGREY: color = (47.0 / 255.0, 79.0 / 255.0, 79.0 / 255.0, 1.0);
export const DARKTURQUOISE: color = (0.0 / 255.0, 206.0 / 255.0, 209.0 / 255.0, 1.0);
export const DARKVIOLET: color = (148.0 / 255.0, 0.0 / 255.0, 211.0 / 255.0, 1.0);
export const DEEPPINK: color = (255.0 / 255.0, 20.0 / 255.0, 147.0 / 255.0, 1.0);
export const DEEPSKYBLUE: color = (0.0 / 255.0, 191.0 / 255.0, 255.0 / 255.0, 1.0);
export const DIMGRAY: color = (105.0 / 255.0, 105.0 / 255.0, 105.0 / 255.0, 1.0);
export const DIMGREY: color = (105.0 / 255.0, 105.0 / 255.0, 105.0 / 255.0, 1.0);
export const DODGERBLUE: color = (30.0 / 255.0, 144.0 / 255.0, 255.0 / 255.0, 1.0);
export const FIREBRICK: color = (178.0 / 255.0, 34.0 / 255.0, 34.0 / 255.0, 1.0);
export const FLORALWHITE: color = (255.0 / 255.0, 250.0 / 255.0, 240.0 / 255.0, 1.0);
export const FORESTGREEN: color = (34.0 / 255.0, 139.0 / 255.0, 34.0 / 255.0, 1.0);
export const FUCHSIA: color = (255.0 / 255.0, 0.0 / 255.0, 255.0 / 255.0, 1.0);
export const GAINSBORO: color = (220.0 / 255.0, 220.0 / 255.0, 220.0 / 255.0, 1.0);
export const GHOSTWHITE: color = (248.0 / 255.0, 248.0 / 255.0, 255.0 / 255.0, 1.0);
export const GOLD: color = (255.0 / 255.0, 215.0 / 255.0, 0.0 / 255.0, 1.0);
export const GOLDENROD: color = (218.0 / 255.0, 165.0 / 255.0, 32.0 / 255.0, 1.0);
export const GRAY: color = (128.0 / 255.0, 128.0 / 255.0, 128.0 / 255.0, 1.0);
export const GREEN: color = (0.0 / 255.0, 128.0 / 255.0, 0.0 / 255.0, 1.0);
export const GREENYELLOW: color = (173.0 / 255.0, 255.0 / 255.0, 47.0 / 255.0, 1.0);
export const GREY: color = (128.0 / 255.0, 128.0 / 255.0, 128.0 / 255.0, 1.0);
export const HONEYDEW: color = (240.0 / 255.0, 255.0 / 255.0, 240.0 / 255.0, 1.0);
export const HOTPINK: color = (255.0 / 255.0, 105.0 / 255.0, 180.0 / 255.0, 1.0);
export const INDIANRED: color = (205.0 / 255.0, 92.0 / 255.0, 92.0 / 255.0, 1.0);
export const INDIGO: color = (75.0 / 255.0, 0.0 / 255.0, 130.0 / 255.0, 1.0);
export const IVORY: color = (255.0 / 255.0, 255.0 / 255.0, 240.0 / 255.0, 1.0);
export const KHAKI: color = (240.0 / 255.0, 230.0 / 255.0, 140.0 / 255.0, 1.0);
export const LAVENDER: color = (230.0 / 255.0, 230.0 / 255.0, 250.0 / 255.0, 1.0);
export const LAVENDERBLUSH: color = (255.0 / 255.0, 240.0 / 255.0, 245.0 / 255.0, 1.0);
export const LAWNGREEN: color = (124.0 / 255.0, 252.0 / 255.0, 0.0 / 255.0, 1.0);
export const LEMONCHIFFON: color = (255.0 / 255.0, 250.0 / 255.0, 205.0 / 255.0, 1.0);
export const LIGHTBLUE: color = (173.0 / 255.0, 216.0 / 255.0, 230.0 / 255.0, 1.0);
export const LIGHTCORAL: color = (240.0 / 255.0, 128.0 / 255.0, 128.0 / 255.0, 1.0);
export const LIGHTCYAN: color = (224.0 / 255.0, 255.0 / 255.0, 255.0 / 255.0, 1.0);
export const LIGHTGOLDENRODYELLOW: color = (250.0 / 255.0, 250.0 / 255.0, 210.0 / 255.0, 1.0);
export const LIGHTGRAY: color = (211.0 / 255.0, 211.0 / 255.0, 211.0 / 255.0, 1.0);
export const LIGHTGREEN: color = (144.0 / 255.0, 238.0 / 255.0, 144.0 / 255.0, 1.0);
export const LIGHTGREY: color = (211.0 / 255.0, 211.0 / 255.0, 211.0 / 255.0, 1.0);
export const LIGHTPINK: color = (255.0 / 255.0, 182.0 / 255.0, 193.0 / 255.0, 1.0);
export const LIGHTSALMON: color = (255.0 / 255.0, 160.0 / 255.0, 122.0 / 255.0, 1.0);
export const LIGHTSEAGREEN: color = (32.0 / 255.0, 178.0 / 255.0, 170.0 / 255.0, 1.0);
export const LIGHTSKYBLUE: color = (135.0 / 255.0, 206.0 / 255.0, 250.0 / 255.0, 1.0);
export const LIGHTSLATEGRAY: color = (119.0 / 255.0, 136.0 / 255.0, 153.0 / 255.0, 1.0);
export const LIGHTSLATEGREY: color = (119.0 / 255.0, 136.0 / 255.0, 153.0 / 255.0, 1.0);
export const LIGHTSTEELBLUE: color = (176.0 / 255.0, 196.0 / 255.0, 222.0 / 255.0, 1.0);
export const LIGHTYELLOW: color = (255.0 / 255.0, 255.0 / 255.0, 224.0 / 255.0, 1.0);
export const LIME: color = (0.0 / 255.0, 255.0 / 255.0, 0.0 / 255.0, 1.0);
export const LIMEGREEN: color = (50.0 / 255.0, 205.0 / 255.0, 50.0 / 255.0, 1.0);
export const LINEN: color = (250.0 / 255.0, 240.0 / 255.0, 230.0 / 255.0, 1.0);
export const MAGENTA: color = (255.0 / 255.0, 0.0 / 255.0, 255.0 / 255.0, 1.0);
export const MAROON: color = (128.0 / 255.0, 0.0 / 255.0, 0.0 / 255.0, 1.0);
export const MEDIUMAQUAMARINE: color = (102.0 / 255.0, 205.0 / 255.0, 170.0 / 255.0, 1.0);
export const MEDIUMBLUE: color = (0.0 / 255.0, 0.0 / 255.0, 205.0 / 255.0, 1.0);
export const MEDIUMORCHID: color = (186.0 / 255.0, 85.0 / 255.0, 211.0 / 255.0, 1.0);
export const MEDIUMPURPLE: color = (147.0 / 255.0, 112.0 / 255.0, 219.0 / 255.0, 1.0);
export const MEDIUMSEAGREEN: color = (60.0 / 255.0, 179.0 / 255.0, 113.0 / 255.0, 1.0);
export const MEDIUMSLATEBLUE: color = (123.0 / 255.0, 104.0 / 255.0, 238.0 / 255.0, 1.0);
export const MEDIUMSPRINGGREEN: color = (0.0 / 255.0, 250.0 / 255.0, 154.0 / 255.0, 1.0);
export const MEDIUMTURQUOISE: color = (72.0 / 255.0, 209.0 / 255.0, 204.0 / 255.0, 1.0);
export const MEDIUMVIOLETRED: color = (199.0 / 255.0, 21.0 / 255.0, 133.0 / 255.0, 1.0);
export const MIDNIGHTBLUE: color = (25.0 / 255.0, 25.0 / 255.0, 112.0 / 255.0, 1.0);
export const MINTCREAM: color = (245.0 / 255.0, 255.0 / 255.0, 250.0 / 255.0, 1.0);
export const MISTYROSE: color = (255.0 / 255.0, 228.0 / 255.0, 225.0 / 255.0, 1.0);
export const MOCCASIN: color = (255.0 / 255.0, 228.0 / 255.0, 181.0 / 255.0, 1.0);
export const NAVAJOWHITE: color = (255.0 / 255.0, 222.0 / 255.0, 173.0 / 255.0, 1.0);
export const NAVY: color = (0.0 / 255.0, 0.0 / 255.0, 128.0 / 255.0, 1.0);
export const OLDLACE: color = (253.0 / 255.0, 245.0 / 255.0, 230.0 / 255.0, 1.0);
export const OLIVE: color = (128.0 / 255.0, 128.0 / 255.0, 0.0 / 255.0, 1.0);
export const OLIVEDRAB: color = (107.0 / 255.0, 142.0 / 255.0, 35.0 / 255.0, 1.0);
export const ORANGE: color = (255.0 / 255.0, 165.0 / 255.0, 0.0 / 255.0, 1.0);
export const ORANGERED: color = (255.0 / 255.0, 69.0 / 255.0, 0.0 / 255.0, 1.0);
export const ORCHID: color = (218.0 / 255.0, 112.0 / 255.0, 214.0 / 255.0, 1.0);
export const PALEGOLDENROD: color = (238.0 / 255.0, 232.0 / 255.0, 170.0 / 255.0, 1.0);
export const PALEGREEN: color = (152.0 / 255.0, 251.0 / 255.0, 152.0 / 255.0, 1.0);
export const PALETURQUOISE: color = (175.0 / 255.0, 238.0 / 255.0, 238.0 / 255.0, 1.0);
export const PALEVIOLETRED: color = (219.0 / 255.0, 112.0 / 255.0, 147.0 / 255.0, 1.0);
export const PAPAYAWHIP: color = (255.0 / 255.0, 239.0 / 255.0, 213.0 / 255.0, 1.0);
export const PEACHPUFF: color = (255.0 / 255.0, 218.0 / 255.0, 185.0 / 255.0, 1.0);
export const PERU: color = (205.0 / 255.0, 133.0 / 255.0, 63.0 / 255.0, 1.0);
export const PINK: color = (255.0 / 255.0, 192.0 / 255.0, 203.0 / 255.0, 1.0);
export const PLUM: color = (221.0 / 255.0, 160.0 / 255.0, 221.0 / 255.0, 1.0);
export const POWDERBLUE: color = (176.0 / 255.0, 224.0 / 255.0, 230.0 / 255.0, 1.0);
export const PURPLE: color = (128.0 / 255.0, 0.0 / 255.0, 128.0 / 255.0, 1.0);
export const RED: color = (255.0 / 255.0, 0.0 / 255.0, 0.0 / 255.0, 1.0);
export const ROSYBROWN: color = (188.0 / 255.0, 143.0 / 255.0, 143.0 / 255.0, 1.0);
export const ROYALBLUE: color = (65.0 / 255.0, 105.0 / 255.0, 225.0 / 255.0, 1.0);
export const SADDLEBROWN: color = (139.0 / 255.0, 69.0 / 255.0, 19.0 / 255.0, 1.0);
export const SALMON: color = (250.0 / 255.0, 128.0 / 255.0, 114.0 / 255.0, 1.0);
export const SANDYBROWN: color = (244.0 / 255.0, 164.0 / 255.0, 96.0 / 255.0, 1.0);
export const SEAGREEN: color = (46.0 / 255.0, 139.0 / 255.0, 87.0 / 255.0, 1.0);
export const SEASHELL: color = (255.0 / 255.0, 245.0 / 255.0, 238.0 / 255.0, 1.0);
export const SIENNA: color = (160.0 / 255.0, 82.0 / 255.0, 45.0 / 255.0, 1.0);
export const SILVER: color = (192.0 / 255.0, 192.0 / 255.0, 192.0 / 255.0, 1.0);
export const SKYBLUE: color = (135.0 / 255.0, 206.0 / 255.0, 235.0 / 255.0, 1.0);
export const SLATEBLUE: color = (106.0 / 255.0, 90.0 / 255.0, 205.0 / 255.0, 1.0);
export const SLATEGRAY: color = (112.0 / 255.0, 128.0 / 255.0, 144.0 / 255.0, 1.0);
export const SLATEGREY: color = (112.0 / 255.0, 128.0 / 255.0, 144.0 / 255.0, 1.0);
export const SNOW: color = (255.0 / 255.0, 250.0 / 255.0, 250.0 / 255.0, 1.0);
export const SPRINGGREEN: color = (0.0 / 255.0, 255.0 / 255.0, 127.0 / 255.0, 1.0);
export const STEELBLUE: color = (70.0 / 255.0, 130.0 / 255.0, 180.0 / 255.0, 1.0);
export const TAN: color = (210.0 / 255.0, 180.0 / 255.0, 140.0 / 255.0, 1.0);
export const TEAL: color = (0.0 / 255.0, 128.0 / 255.0, 128.0 / 255.0, 1.0);
export const THISTLE: color = (216.0 / 255.0, 191.0 / 255.0, 216.0 / 255.0, 1.0);
export const TOMATO: color = (255.0 / 255.0, 99.0 / 255.0, 71.0 / 255.0, 1.0);
export const TURQUOISE: color = (64.0 / 255.0, 224.0 / 255.0, 208.0 / 255.0, 1.0);
export const VIOLET: color = (238.0 / 255.0, 130.0 / 255.0, 238.0 / 255.0, 1.0);
export const WHEAT: color = (245.0 / 255.0, 222.0 / 255.0, 179.0 / 255.0, 1.0);
export const WHITE: color = (255.0 / 255.0, 255.0 / 255.0, 255.0 / 255.0, 1.0);
export const WHITESMOKE: color = (245.0 / 255.0, 245.0 / 255.0, 245.0 / 255.0, 1.0);
export const YELLOW: color = (255.0 / 255.0, 255.0 / 255.0, 0.0 / 255.0, 1.0);
export const YELLOWGREEN: color = (154.0 / 255.0, 205.0 / 255.0, 50.0 / 255.0, 1.0);
