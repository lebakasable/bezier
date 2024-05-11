export type v2f = struct {
	x: f32,
	y: f32,
};

export fn vec2f(x: f32, y: f32) v2f = v2f { x = x, y = y };
export fn add(a: v2f, b: v2f) v2f = vec2f(a.x + b.x, a.y + b.y);
export fn sub(a: v2f, b: v2f) v2f = vec2f(a.x - b.x, a.y - b.y);
export fn mul(a: v2f, b: v2f) v2f = vec2f(a.x * b.x, a.y * b.y);
export fn div(a: v2f, b: v2f) v2f = vec2f(a.x / b.x, a.y / b.y);
export fn scale(a: v2f, n: f32) v2f = vec2f(a.x * n, a.y * n);
export fn lerp(a: v2f, b: v2f, f: f32) v2f =
	vec2f(a.x + (b.x - a.x) * f, a.y + (b.y - a.y) * f);

