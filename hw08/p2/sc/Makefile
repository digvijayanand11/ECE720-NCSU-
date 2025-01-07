
include cmod_Makefile

all: sim.x

sim:
	./sim.x

sim.x: $(wildcard *.h) $(wildcard *.cpp) nvhls_pch.h.gch
	$(CC) -o $@ $(CFLAGS) $(USER_FLAGS) $(wildcard *.cpp) $(BOOSTLIBS) $(LIBS)

nvhls_pch.h.gch: nvhls_pch.h
	$(CC) -o $@ $(CFLAGS) $(USER_FLAGS) -x c++-header -c nvhls_pch.h

clean:
	-rm *.o *.txt *.vcd sim.x ucli.key
	-rm *.gch

