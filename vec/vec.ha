export type v2f = struct {
	x: f32,
	y: f32,
};

export fn add(a: v2f, b: v2f) v2f = {
	return v2f {
		x = a.x + b.x,
		y = a.y + b.y,
	};
};

export fn sub(a: v2f, b: v2f) v2f = {
	return v2f {
		x = a.x - b.x,
		y = a.y - b.y,
	};
};

export fn mul(a: v2f, b: v2f) v2f = {
	return v2f {
		x = a.x * b.x,
		y = a.y * b.y,
	};
};

export fn div(a: v2f, b: v2f) v2f = {
	return v2f {
		x = a.x / b.x,
		y = a.y / b.y,
	};
};

export fn scale(a: v2f, n: f32) v2f = {
	return v2f {
		x = a.x * n,
		y = a.y * n,
	};
};

export fn lerp(a: v2f, b: v2f, f: f32) v2f = {
	return v2f {
		x = a.x + (b.x - a.x) * f,
		y = a.y + (b.y - a.y) * f,
	};
};
