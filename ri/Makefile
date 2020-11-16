all : lad2gfu solve_ri3

override CXXFLAGS += -O3 -march=native -std=c++14 -I./ -W -Wall -g -ggdb3 -pthread

lad2gfu : lad2gfu.cc
	$(CXX) $(CXXFLAGS) -o $@ $<

solve_ri3 : solve_ri3.cc
	$(CXX) $(CXXFLAGS) -o $@ $< -I RI/include -I RI/rilib
