CC      = cc
CFLAGS  = -std=c99 -Wall -Wextra -march=native -O3 -ggdb3 -fopenmp
LDFLAGS =
LDLIBS  = -lm -ldl

compile: prospector genetic hillclimb hp16

prospector: prospector.c
	$(CC) $(LDFLAGS) $(CFLAGS) -o $@ prospector.c $(LDLIBS)

evalpow2: evalpow2.c
	$(CC) $(LDFLAGS) $(CFLAGS) -o $@ evalpow2.c $(LDLIBS)

genetic: genetic.c
	$(CC) $(LDFLAGS) $(CFLAGS) -o $@ genetic.c $(LDLIBS)

hillclimb: hillclimb.c
	$(CC) $(LDFLAGS) $(CFLAGS) -o $@ hillclimb.c $(LDLIBS)

hp16: hp16.c
	$(CC) $(LDFLAGS) $(CFLAGS) -o $@ hp16.c $(LDLIBS)

tests/degski64.so: tests/degski64.c
tests/h2hash32.so: tests/h2hash32.c
tests/hash32shift.so: tests/hash32shift.c
tests/splitmix64.so: tests/splitmix64.c

hashes = \
    tests/degski64.so \
    tests/h2hash32.so \
    tests/hash32shift.so \
    tests/murmurhash3_finalizer32.so \
    tests/splitmix64.so

check: prospector $(hashes)
	./prospector -E -8 -l tests/degski64.so
	./prospector -E -4 -l tests/h2hash32.so
	./prospector -E -4 -l tests/hash32shift.so
	./prospector -E -4 -l tests/murmurhash3_finalizer32.so
	./prospector -E -8 -l tests/splitmix64.so

tests/kensler.so: tests/kensler.c
tests/kensler-splitmix64.so: tests/kensler-splitmix64.c
tests/camel-cdr.so: tests/camel-cdr.c

xhashes = \
    tests/kensler.so \
    tests/kensler-splitmix64.so \
    tests/camel-cdr.so

xcheck: evalpow2 $(xhashes)
	./evalpow2 -v -n 32 -l tests/kensler.so && printf "\n"
	./evalpow2 -v -n 64 -l tests/kensler-splitmix64.so && printf "\n"
	./evalpow2 -v -n 64 -l tests/camel-cdr.so

clean:
	rm -f prospector evalpow2 genetic hillclimb hp16 $(hashes) $(xhashes)

.SUFFIXES: .so .c
.c.so:
	$(CC) -shared $(LDFLAGS) -fPIC $(CFLAGS) -o $@ $<
