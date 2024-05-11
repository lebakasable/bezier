LIBS=-lSDL2

build: bezier.ha
	hare build $(LIBS) $<

release: bezier.ha
	hare build $(LIBS) -R $<
	tar -czvf linux-x86_64.tar.gz $(<:.ha=)
