/*
Copyright (c) 2014 by Rosalba Giugno

This library contains portions of other open source products covered by separate
licenses. Please see the corresponding source files for specific terms.

RI is provided under the terms of The MIT License (MIT):

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#include <iostream>
#include <fstream>
#include <string>
#include <cstdlib>
#include <ctime>


#include <stdio.h>
#include <stdlib.h>
#include "c_textdb_driver.h"
#include "timer.h"


#include "AttributeComparator.h"
#include "AttributeDeconstructor.h"
#include "Graph.h"
#include "MatchingMachine.h"
#include "MaMaConstrFirst.h"
#include "Match.h"
#include "Solver.h"
#include "IsoGISolver.h"
#include "SubGISolver.h"
#include "InducedSubGISolver.h"

#define PRINT_MATCHES
//#define CSV_FORMAT


using namespace rilib;

struct Success
{
};

class FirstOnlyConsoleMatchListener : public MatchListener {
public:
	FirstOnlyConsoleMatchListener() : MatchListener(){
	}
	virtual void match(int n, int* qIDs, int* rIDs){
		matchcount++;
		std::cout<< "{";
		for(int i=0; i<n; i++){
			std::cout<< "("<< qIDs[i] <<","<< rIDs[i] <<")";
		}
		std::cout<< "}\n";
                throw Success();
	}
};

void usage(char* args0);
int match(MATCH_TYPE matchtype,	std::string& referencefile,	std::string& queryfile);

int main(int argc, char* argv[]){

	if(argc!=5){
		usage(argv[0]);
		return -1;
	}

	MATCH_TYPE matchtype;
	std::string reference;
	std::string query;

	std::string par = argv[1];
	if(par=="iso"){
		matchtype = MT_ISO;
	}
	else if(par=="ind"){
		matchtype = MT_INDSUB;
	}
	else if(par=="mono"){
		matchtype = MT_MONO;
	}
	else{
		usage(argv[0]);
		return -1;
	}

	par = argv[2];
	if(par=="loopgfu"){
	}
	else{
		usage(argv[0]);
		return -1;
	}

	reference = argv[3];
	query = argv[4];

	return match(matchtype, reference, query);
};





void usage(char* args0){
	std::cout<<"usage "<<args0<<" [iso ind mono] [loopgfu] reference query\n";
	std::cout<<"\tmatch type:\n";
	std::cout<<"\t\tiso = isomorphism\n";
	std::cout<<"\t\tind = induced subisomorphism\n";
	std::cout<<"\t\tmono = monomorphism\n";
	std::cout<<"\tgraph input format:\n";
	std::cout<<"\t\tloopgfu = undirect graphs with labels on nodes, label must be loop or noloop\n";

	std::cout<<"\treference file contains one or more reference graphs\n";
	std::cout<<"\tquery contains the query graph (just one)\n";
};

class NonIndLoopAsAttrComparator: public AttributeComparator{
public:
	NonIndLoopAsAttrComparator(){};
	virtual bool compare(void* attr1, void* attr2){
		std::string* a=(std::string*)attr1;
		std::string* b=(std::string*)attr2;
                return (*b == "loop") ? (*a == "loop") : true;
	};
	virtual int compareint(void* attr1, void* attr2){
            throw "not used?";
	};
};

class IndLoopAsAttrComparator: public AttributeComparator{
public:
	IndLoopAsAttrComparator(){};
	virtual bool compare(void* attr1, void* attr2){
		std::string* a=(std::string*)attr1;
		std::string* b=(std::string*)attr2;
                return (*b == "loop") == (*a == "loop");
	};
	virtual int compareint(void* attr1, void* attr2){
            throw "not used?";
	};
};


int match(
		MATCH_TYPE 			matchtype,
		std::string& 		referencefile,
		std::string& 	queryfile){

	TIMEHANDLE load_s, load_s_q, make_mama_s, match_s, total_s;
	double load_t=0;double load_t_q=0; double make_mama_t=0; double match_t=0; double total_t=0;
	total_s=start_time();

	bool takeNodeLabels = false;
	bool takeEdgesLabels = false;
	int rret;

	AttributeComparator* nodeComparator;			//to compare node labels
	AttributeComparator* edgeComparator;			//to compare edge labels
	AttributeDeconstructor* nodeAttrDeco;			//to free node labels
	AttributeDeconstructor* edgeAttrDeco;			//to free edge labels

        if (matchtype == MT_MONO)
            nodeComparator = new NonIndLoopAsAttrComparator();
        else
            nodeComparator = new IndLoopAsAttrComparator();

        edgeComparator = new DefaultAttrComparator();
        nodeAttrDeco = new StringAttrDeCo();
        edgeAttrDeco = new VoidAttrDeCo();
        takeNodeLabels = true;

	TIMEHANDLE tt_start;
	double tt_end;



	//read the query graph
	load_s_q=start_time();
	Graph *query = new Graph();
	rret = read_graph(queryfile.c_str(), query, GFT_GFU);
	load_t_q+=end_time(load_s_q);
	if(rret !=0){
		std::cout<<"error on reading query graph\n";
	}

	make_mama_s=start_time();
	MaMaConstrFirst* mama = new MaMaConstrFirst(*query);
	mama->build(*query);
	make_mama_t+=end_time(make_mama_s);

	//mama->print();

	long 	steps = 0,				//total number of steps of the backtracking phase
			triedcouples = 0, 		//nof tried pair (query node, reference node)
			matchcount = 0, 		//nof found matches
			matchedcouples = 0;		//nof mathed pair (during partial solutions)
	long tsteps = 0, ttriedcouples = 0, tmatchedcouples = 0;

        bool result = false;

	FILE *fd = open_file(referencefile.c_str(), GFT_GFU);
	if(fd != NULL){
		MatchListener* matchListener=new FirstOnlyConsoleMatchListener();
		int i=0;
		bool rreaded = true;
		do{//for each reference graph inside the input file
			std::cout<<"#"<<i<<"\n";
			//read the next reference graph
			load_s=start_time();
			Graph * rrg = new Graph();
			int rret = read_dbgraph(referencefile.c_str(), fd, rrg, GFT_GFU);
			rreaded = (rret == 0);
			load_t+=end_time(load_s);
			if(rreaded){

                            try {
					//run the matching
					match_s=start_time();
					match(	*rrg,
							*query,
							*mama,
							*matchListener,
							matchtype,
							*nodeComparator,
							*edgeComparator,
							&tsteps,
							&ttriedcouples,
							&tmatchedcouples);
					match_t+=end_time(match_s);

					//see rilib/Solver.h
//					steps += tsteps;
//					triedcouples += ttriedcouples;
					matchedcouples += tmatchedcouples;

				}
                            catch (const Success &) {
                                matchedcouples += tmatchedcouples;
                                match_t+=end_time(match_s);
                                result = true;
                            }
                        }
//				delete rrg;
				//remember that destroyer are not defined
			i++;
		}while(rreaded);

		matchcount = matchListener->matchcount;

		delete matchListener;

		fclose(fd);
	}
	else{
		std::cout<<"unable to open reference file\n";
		return -1;
	}

	total_t=end_time(total_s);

#ifdef CSV_FORMAT
	std::cout<<referencefile<<"\t"<<queryfile<<"\t";
	std:cout<<load_t_q<<"\t"<<make_mama_t<<"\t"<<load_t<<"\t"<<match_t<<"\t"<<total_t<<"\t"<<steps<<"\t"<<triedcouples<<"\t"<<matchedcouples<<"\t"<<matchcount;
#else
	std::cout<<"matching time: "<<match_t<<"\n";
	std::cout<<"number of found matches: "<<matchcount<<"\n";
	std::cout<<"search space size: "<<matchedcouples<<"\n";
        std::cout << "result: " << std::boolalpha << result << "\n";
#endif

//	delete mama;
//	delete query;

	delete nodeComparator;
	delete edgeComparator;

	return 0;
};





