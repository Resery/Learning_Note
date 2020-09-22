#include "cachelab.h"
#include<stdlib.h>
#include<unistd.h>
#include<stdio.h>
#include<limits.h>
#include<getopt.h>
#include<string.h>

typedef struct{
	int vaild;
	int tag;
	int Time_counter;
}Cache_line;

typedef Cache_line* Cache_set;
typedef Cache_set* Cache;

int verbose = 0;			
int s,E,b;
int S;
int hits,misses,evictions;

char buf[100];

FILE* fp = NULL;

Cache cache;

void visit(unsigned int address) {
	int set_index = (address >> b) & (S - 1);
	int tag = (address >> b) >> s;

	int evict = 0;
	int empty = -1;
	
	Cache_set Cache_Set = cache[set_index];

	for (int i = 0; i < E; i++) {
		if (Cache_Set[i].vaild) {
			if (Cache_Set[i].tag == tag) {
				hits++;
				Cache_Set[i].Time_counter = 1;
				return;
			}
			Cache_Set[i].Time_counter++;
			if (Cache_Set[evict].Time_counter <= Cache_Set[i].Time_counter) {
				evict = i;
			}
		}
		else {
			empty = i;
		}
	}
	misses++;
	if (empty != -1) {
		Cache_Set[empty].vaild = 1;
		Cache_Set[empty].tag = tag;
		Cache_Set[empty].Time_counter = 1;
		return;
	}
	else {
		Cache_Set[evict].tag = tag;
		Cache_Set[evict].Time_counter = 1;
		evictions++;
		return;
	}

}

void simulate() {
	S = 1 << s;
	cache = ((Cache)malloc(sizeof(Cache_set) * S));
	if (cache == NULL)
		return ;
	for (int i = 0; i < S; i++) {
		cache[i] = ((Cache_set)calloc(E,sizeof(Cache_line)));
		if (cache[i] == NULL)
			return ;
	}

	char op;
	unsigned int address;
	int size;

	while (fgets(buf, 1000, fp)) {
		sscanf(buf, " %c %xu,%d", &op, &address, &size);
		switch (op)
		{
		case 'L':
			visit(address);
			break;
		case 'M':
			visit(address);
		case 'S':
			visit(address);
			break;
		}
	}

	for (int i = 0; i < S; i++)
		free(cache[i]);
	free(cache);
	fclose(fp);
	return ;
}

void argument(int argc, char* argv[]){
	int opt;
	if(!argv[1]){
		fprintf(stderr,"./csim: Missing required command line argument\n");
		fprintf(stderr, "Usage: ./csim [-hv] -s <num> -E <num> -b <num> -t <file>");
		fprintf(stderr,"Options:\n");
		fprintf(stderr,"  -h         Print this help message.\n");
		fprintf(stderr,"  -v         Optional verbose flag.\n");
		fprintf(stderr,"  -s <num>   Number of set index bits.\n");
		fprintf(stderr,"  -E <num>   Number of lines per set.\n");
		fprintf(stderr,"  -b <num>   Number of block offset bits.\n");
		fprintf(stderr,"  -t <file>  Trace file.\n");
		fprintf(stderr,"\n");
		fprintf(stderr,"Examples:\n");
		fprintf(stderr,"  linux>  ./csim -s 4 -E 1 -b 4 -t traces/yi.trace\n");
		fprintf(stderr,"  linux>  ./csim -v -s 8 -E 2 -b 4 -t traces/yi.trace\n");
		exit(-1);
	}
	while ((opt = getopt(argc, argv, "hvs:E:b:t:")) != -1) {
		switch (opt) {
		case 'h':
			fprintf(stderr, "Usage: ./csim [-hv] -s <num> -E <num> -b <num> -t <file>");
			fprintf(stderr,"Options:\n");
			fprintf(stderr,"  -h         Print this help message.\n");
			fprintf(stderr,"  -v         Optional verbose flag.\n");
			fprintf(stderr,"  -s <num>   Number of set index bits.\n");
			fprintf(stderr,"  -E <num>   Number of lines per set.\n");
			fprintf(stderr,"  -b <num>   Number of block offset bits.\n");
			fprintf(stderr,"  -t <file>  Trace file.\n");
			fprintf(stderr,"\n");
			fprintf(stderr,"Examples:\n");
			fprintf(stderr,"  linux>  ./csim -s 4 -E 1 -b 4 -t traces/yi.trace\n");
			fprintf(stderr,"  linux>  ./csim -v -s 8 -E 2 -b 4 -t traces/yi.trace\n");
			exit(-1);
		case 'v':
			verbose = 1;
			break;
		case 's':
			s = atoi(optarg);
			break;
		case 'E':
			E = atoi(optarg);
			break;
		case 'b':
			b = atoi(optarg);
			break;
		case 't':
			fp = fopen(optarg, "r");
			if (fp == NULL) {
				fprintf(stderr, "The File is wrong!\n");
				exit(-1);
			}
			break;
		default:
			fprintf(stderr, "Usage: ./csim [-hv] -s <num> -E <num> -b <num> -t <file>");
			fprintf(stderr,"Options:\n");
			fprintf(stderr,"  -h         Print this help message.\n");
			fprintf(stderr,"  -v         Optional verbose flag.\n");
			fprintf(stderr,"  -s <num>   Number of set index bits.\n");
			fprintf(stderr,"  -E <num>   Number of lines per set.\n");
			fprintf(stderr,"  -b <num>   Number of block offset bits.\n");
			fprintf(stderr,"  -t <file>  Trace file.\n");
			fprintf(stderr,"\n");
			fprintf(stderr,"Examples:\n");
			fprintf(stderr,"  linux>  ./csim -s 4 -E 1 -b 4 -t traces/yi.trace\n");
			fprintf(stderr,"  linux>  ./csim -v -s 8 -E 2 -b 4 -t traces/yi.trace\n");
			exit(-1);
		}
	}
}

int main(int argc, char* argv[])
{
	argument(argc,argv);
	simulate();
	printSummary(hits, misses, evictions);
    return 0;
}
