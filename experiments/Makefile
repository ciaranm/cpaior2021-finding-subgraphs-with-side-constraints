SHELL := /bin/bash
FILTER := -1
MODULUS := 1
CATTER := cat
INSTANCES_FILE := instances.txt
INSTANCES := $(shell cat $(INSTANCES_FILE) | $(CATTER) | cut -d' ' -f1 | if [[ $(FILTER) == -1 ]] ; then cat ; else awk "(NR %$(MODULUS)) == ($(FILTER) % $(MODULUS))" ; fi)
TIMEOUT := 1000
TODAY := 20201031
ALGORITHMS := \
    si-noninduced-gss-$(TODAY) \
    $(foreach problem,noninduced moreoddthaneven lessthreeodd parity, \
        $(foreach preprocess,gac none, \
            si-$(problem)-minion-preprocess-$(preprocess)-$(TODAY) \
            $(foreach comm,checker test propagate rollback, \
                si-$(problem)-hybrid-preprocess-$(preprocess)-comm-$(comm)-$(TODAY) )))

RESULTS := results
PARAMS := param

all : $(foreach i, $(INSTANCES), $(foreach a, $(ALGORITHMS), $(RESULTS)/$(a)/$i/run-experiment.out ))

runtimes.data : runtimes all
	./runtimes $(foreach a,$(ALGORITHMS),$(RESULTS)/$(a) ) > >(tee runtimes.data )

runtimes : runtimes.cc
	$(CXX) -std=c++17 $(CXXFLAGS) $(LDFLAGS) -o runtimes -O2 -W -Wall runtimes.cc

dir-% :
	mkdir -p $(RESULTS) $(RESULTS)/$*

ladtoessence : ladtoessence.cc
	$(CXX) -std=c++17 $(CXXFLAGS) $(LDFLAGS) -o ladtoessence -O2 -W -Wall ladtoessence.cc

define ALGORITHM_template
$(RESULTS)/$(1)/%/run-experiment.out : ladtoessence | dir-$(1)
	mkdir -p $(RESULTS)/$(1)/$$*
	env TIMEOUT=$(TIMEOUT) ./run-experiment.sh $(RESULTS) $(1) $$* $$(shell grep "^`basename $$*` " < instances.txt | cut -d' ' -f2-3 ) > >(tee $(RESULTS)/$(1)/$$*/full-output ) 2>&1
endef

$(foreach a,$(ALGORITHMS),$(eval $(call ALGORITHM_template,$(a))))

