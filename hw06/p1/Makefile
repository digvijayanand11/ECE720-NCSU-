CXXFLAGS=-MMD -MP -Wall -DSC_INCLUDE_DYNAMIC_PROCESSES -Wno-unused -std=c++11 
EXE_NAME=main.x

all: rel

rel: OPTFLAGS = -O3

rel: $(EXE_NAME)

dbg: OPTFLAGS = -O0 -g

dbg: $(EXE_NAME)

.PHONY: dbg rel


CXXFLAGS+=$(OPTFLAGS)


SRC = $(wildcard *.cpp)
OBJ = $(addsuffix .o, $(basename $(SRC)))
INCLUDES= -I. -I$(SYSTEMC_HOME)/include
LIBS= -L. -L$(SYSTEMC_HOME)/lib-linux64 -lstdc++ -lsystemc -lm -lpthread 

REBUILDABLES=$(OBJ) $(EXE_NAME)

#   $@ target name, $^ target deps, $< matched pattern
$(EXE_NAME): $(OBJ)
	$(CXX) $(CXXFLAGS) $(LIBS) -o $@ $^ 
	@echo "Built $@ successfully" 

#include the autogenerated dependency files for each .o file
-include $(OBJ:.o=.d)

# build dependency list via gcc -M and save to a .d file
%.d : %.cpp
	@$(CXX) -M $(CXXFLAGS) $(INCLUDES) $< 

# build all .cpp files to .o files
%.o : %.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -o $@ -c $<

clean: 
	-rm -f $(REBUILDABLES) *.d

sim:
	./$(EXE_NAME)

gdb:
	gdb ./$(EXE_NAME)
