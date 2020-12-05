SHELL := /bin/bash
FILTER := -1
MODULUS := 1
CATTER := cat
INSTANCES_FILE := instances.txt
INSTANCES := $(shell cat $(INSTANCES_FILE) | $(CATTER) | cut -d' ' -f1 | if [[ $(FILTER) == -1 ]] ; then cat ; else awk "(NR %$(MODULUS)) == ($(FILTER) % $(MODULUS))" ; fi)
TIMEOUT := 1000
TODAY := 20201201
TOMORROW := 20201203
YESTERDAY := 20201117

ALGORITHMS := \
    si-noninduced-gss-$(TODAY) \
    si-parity-gss-$(TODAY) \
    si-moreoddthaneven-gss-$(TODAY) \
    si-lessthreeodd-gss-$(TODAY) \
    $(foreach problem,noninduced moreoddthaneven lessthreeodd parity, \
        $(foreach preprocess,gac, \
            si-$(problem)-minion-preprocess-$(preprocess)-$(TODAY) \
            $(foreach comm,checker propagate rollback, \
                si-$(problem)-hybrid-preprocess-$(preprocess)-comm-$(comm)-$(TODAY) ))) \
    si-noninduced-pathlad-$(YESTERDAY) \
    si-noninduced-vf2-$(YESTERDAY) \
    si-noninduced-ri-$(YESTERDAY) \
    $(foreach problem,noninducedoz moreoddthanevenoz lessthreeoddoz parityoz, \
        $(foreach preprocess,gac, \
            si-$(problem)-minion-preprocess-$(preprocess)-$(TOMORROW) \
            $(foreach comm,checker propagate rollback, \
                si-$(problem)-hybrid-preprocess-$(preprocess)-comm-$(comm)-$(TOMORROW) ))) \

RESULTS := results

all : $(foreach i, $(INSTANCES), $(foreach a, $(ALGORITHMS), $(RESULTS)/$(a)/$i/run-experiment.out ))

runtimes.data : runtimes all
	./runtimes $(foreach a,$(ALGORITHMS),$(RESULTS)/$(a) ) > >(tee runtimes.data )

runtimes : runtimes.cc
	$(CXX) -std=c++17 $(CXXFLAGS) -o runtimes -O2 -W -Wall runtimes.cc $(LDFLAGS)

dir-% :
	mkdir -p $(RESULTS) $(RESULTS)/$*

ladtoessence : ladtoessence.cc
	$(CXX) -std=c++17 $(CXXFLAGS) -o ladtoessence -O2 -W -Wall ladtoessence.cc $(LDFLAGS)

define ALGORITHM_template
$(RESULTS)/$(1)/%/run-experiment.out : ladtoessence | dir-$(1)
	mkdir -p $(RESULTS)/$(1)/$$*
	env TIMEOUT=$(TIMEOUT) ./run-experiment.sh $(RESULTS) $(1) $$* $$(shell grep "^`basename $$*` " < instances.txt | cut -d' ' -f2-3 ) > >(tee $(RESULTS)/$(1)/$$*/full-output ) 2>&1
endef

$(foreach a,$(ALGORITHMS),$(eval $(call ALGORITHM_template,$(a))))

