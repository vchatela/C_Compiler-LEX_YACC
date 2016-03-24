#ifndef ASM_H
#define ASM_H

#include<stdio.h>
#include<string.h>
#include<stdlib.h> 

struct s_instruction{
	char codeOp[6]; //PCOPA\0
	int args[4];
	int nb_args;
};

struct s_instruction prog[512];
int counter;

void addInstruction(char * code, int nb, int * args);
void writeProgramToFile(FILE * f);
void updateJMF(int pos, int to);
void updateWHILE(int pos, int val);

#endif