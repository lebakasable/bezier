// Converts a pixel buffer to the desired format, returning a new pixel buffer.
// The return value must be freed with [[buffer_finish]]. A new buffer is always
// allocated, even if the two pixel formats were the same.
export fn convert(buf: const *buffer, dest: format) buffer = {
	let new = newbuffer(dest, buffer_width(buf), buffer_height(buf), buffer_stride(buf));
	let rect = buffer_dimensions(buf);
	copy(&new, &rect, buf, &rect);
	return new;
};

// Converts a pixel buffer to the desired format, writing to an existing pixel
// buffer. The source and destination buffers must have the same dimensions.
export fn convert_static(
	dest: *buffer,
	src: const *buffer,
) void = {
	assert(buffer_width(src) == buffer_width(dest),
		"pixbuf::convert_static: buffer dimensions do not match");
	assert(buffer_height(src) == buffer_height(dest),
		"pixbuf::convert_static: buffer dimensions do not match");
	let rect = buffer_dimensions(src);
	copy(dest, &rect, src, &rect);
};
