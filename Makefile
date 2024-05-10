LIBS=-lSDL2

main: main.ha
	hare build $(LIBS) -o $@ $<
