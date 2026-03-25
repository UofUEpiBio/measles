EPIWORLD_INCLUDE := $(shell Rscript -e "cat(system.file('include', package = 'epiworldR'))")

CXX      := g++
CXXFLAGS := -std=gnu++17 -fopenmp -O2 -g -Wall -pedantic
INCLUDES := -I$(EPIWORLD_INCLUDE)

all: shortcreek

shortcreek: shortcreek.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -o $@ $<

clean:
	rm -f shortcreek

.PHONY: all clean
