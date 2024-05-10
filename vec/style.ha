// A color sample as a tuple of four floating-point RGBA colors from 0..1.
export type color = (f32, f32, f32, f32);

// A color in HSLA format
export type hsla = (f32, f32, f32, f32);

// A linear gradient from two colors and two points.
export type linear = (color, color, point, point);

// A radial gradient from two colors and two points.
export type radial = (color, color, point, point);

// A color sampling strategy.
export type style = (color | linear | radial);

// Creates a linear gradient style.
export fn lineargradient(c0: color, c1: color, p0: point, p1: point) style = {
	return (c0, c1, p0, p1): linear;
};

// Creates a radial gradient style.
export fn radialgradient(c0: color, c1: color, p0: point, p1: point) style = {
	return (c0, c1, p0, p1): radial;
};

// Samples a color from a [[style]], returning an RGBA value.
fn sample(style: *style, x: uint, y: uint) u32 = {
	match (*style) {
	case let c: color =>
		return to_argb(&c);
	case let l: linear =>
		const (c0, c1, p0, p1) = l;
		const dir = sub(p1, p0);
		const pt: point = (x: f32, y: f32);
		const delta = sub(pt, p0);
		const dot0 = dot(dir, delta);
		if (dot0 <= 0.0) {
			return to_argb(&c0);
		};
		const dot1 = dot(dir, sub(pt, p1));
		if (dot1 >= 0.0) {
			return to_argb(&c1);
		};
		const zero: point = (0.0, 0.0);
		const glen = length(dir);
		const gpos = length(project_on_line(zero, dir, delta));
		return to_argb(&lerp_sRGB(c0, c1, gpos / glen));
	case let r: radial =>
		const (c0, c1, p0, p1) = r;
		const pt: point = (x: f32, y: f32);
		const dmax = distance(p0, p1);
		const dactual = distance(p0, pt);
		return to_argb(&lerp_sRGB(c0, c1, dactual / dmax));
	};
};

fn project_on_line(v1: point, v2: point, p: point) point = {
	const l1 = sub(v2, v1);
	const l2 = sub(p, v1);
	const proj = dot(l1, l2) / dot(l1, l1);
	return add(v1, scale(l1, proj));
};
