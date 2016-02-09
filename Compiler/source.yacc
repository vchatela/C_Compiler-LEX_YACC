%{
#include<stdio.h>
int yyerror(char *s);
%}

%token tMAIN
%token tID tCONST
%token tPLUS tMOINS tFOIS tMOD tDIV tEG
%token tPO tPF 
%token tAO tAF
%token tEGALITE tOU tET tSUP tSUPEG tINF tINFEG
%token tNON
%token tIF tWHILE
%token tPRINT
%token tINT
%token tNB
%token tRETURN
%token tPV tVIR tERR

%union{int value; char * variable;}

%left tPLUS tMOINS
%right tFOIS tDIV tEG

%start Prg
%%
Prg : Dfct Prg
	|Main;

Dfct : tINT tID tPO PARAMS tPF BODY;

Main : tINT tMAIN tPO tPF BODY;

PARAMS : PARAM tVIR PARAMS
		| PARAM
		|;

PARAM : tINT tID ;

BODY : tAO DECLARATIONS INSTRUCTIONS tAF;

DECLARATIONS : tINT SUITEDECLARATIONS tPV DECLARATIONS
			| ;

SUITEDECLARATIONS : DECLARATION tVIR SUITEDECLARATIONS
				| DECLARATION;

DECLARATION : tID
		| AFFECTATION;
			
AFFECTATION : tID tEG EXPARITHMETIQUE;

INSTRUCTIONS : 	AFFECTATION tPV INSTRUCTIONS
			| 	WHILE INSTRUCTIONS
			|	IF INSTRUCTIONS	
			| 	RETURN
			|	tPV
			| 	PRINT
			|;

EXPARITHMETIQUE : EXPARITHMETIQUE tPLUS EXPARITHMETIQUE
				| EXPARITHMETIQUE tMOINS EXPARITHMETIQUE
				| EXPARITHMETIQUE tFOIS EXPARITHMETIQUE
				| EXPARITHMETIQUE tDIV EXPARITHMETIQUE
				| EXPARITHMETIQUE tMOD EXPARITHMETIQUE
				| tPO EXPARITHMETIQUE tPF
				| tNB
				| tID ;

EXPCONDITIONNELLE : EXPARITHMETIQUE tOU EXPARITHMETIQUE
				| 	EXPARITHMETIQUE tET EXPARITHMETIQUE
				| 	EXPARITHMETIQUE tINFEG EXPARITHMETIQUE
				| 	EXPARITHMETIQUE tINF EXPARITHMETIQUE
				| 	EXPARITHMETIQUE tSUPEG EXPARITHMETIQUE
				| 	EXPARITHMETIQUE tSUP EXPARITHMETIQUE
				| 	EXPARITHMETIQUE tEGALITE EXPARITHMETIQUE
				| 	tPO EXPARITHMETIQUE tPF
				| 	tNON EXPARITHMETIQUE;

IF : tIF tPO EXPCONDITIONNELLE tPF BODY;

WHILE : tWHILE tPO EXPCONDITIONNELLE tPF BODY;

RETURN : tRETURN EXPARITHMETIQUE tPV
		| tRETURN tID tPV
		| tRETURN tPV;

PRINT : tPRINT tPO tID tPF tPV;


%%
int yyerror(char *s) {
 fprintf(stderr,"%s\n",s);
}

int main(void) {
  yyparse();
}
