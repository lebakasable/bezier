use math;

export fn add(p0: *point, p1: *point) point = {
	const (x0, y0) = *p0;
	const (x1, y1) = *p1;
	return (x1 + x0, y1 + y0);
};

export fn sub(p0: *point, p1: *point) point = {
	const (x0, y0) = *p0;
	const (x1, y1) = *p1;
	return (x1 - x0, y1 - y0);
};

export fn dot(p0: *point, p1: *point) f32 = {
	return p0.0 * p1.0 + p0.1 * p1.1;
};

export fn cross(p0: *point, p1: *point) f32 = {
	return p0.0 * p1.1 - p0.1 * p1.0;
};

export fn length(p: *point) f32 = {
	// XXX: sqrtf32?
	return math::sqrtf64(dot(p, p)): f32;
};

export fn scale(p: *point, s: f32) point = {
	return (p.0 * s, p.1 * s);
};

export fn distance(p1: *point, p2: *point) f32 = {
	return length(&sub(p1, p2));
};

def sRGB_gamma: f32 = 2.2;

export fn gamma2linear(v: f32) f32 = {
	assert(v >= 0.0 && v <= 1.0);
	return 255.0 * math::powf64(v, 1.0 / sRGB_gamma): f32;
};

export fn linear2gamma(v: f32) f32 = {
	return math::powf64(v / 255.0, sRGB_gamma): f32;
};

export fn lerpf(a: f32, b: f32, f: f32) f32 = a + (b - a) * f;

export fn lerpp(a: point, b: point, f: f32) point =
	add(&a, &scale(&sub(&a, &b), f));

export fn lerp_sRGB(c0: *color, c1: *color, f: f32) color = {
	const f: f32 = if (f < 0.0) 0.0 else if (f > 1.0) 1.0 else f;
	return (
		gamma2linear(lerpf(linear2gamma(c0.0), linear2gamma(c1.0), f)),
		gamma2linear(lerpf(linear2gamma(c0.1), linear2gamma(c1.1), f)),
		gamma2linear(lerpf(linear2gamma(c0.2), linear2gamma(c1.2), f)),
		lerpf(c0.3, c1.3, f),
	);
};
