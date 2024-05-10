use pixbuf;

export type painter = struct {
	buf: *pixbuf::buffer,
};

// Creates a new [[painter]], which may be used to perform drawing operations.
// The provided buffer is borrowed for the lifetime of the painter.
export fn newpainter(buf: *pixbuf::buffer) painter = {
	return painter {
		buf = buf,
	};
};
