%{
#include<stdio.h>
#include"table_of_symbol.h"
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

%type <variable> tID
%type <value> EXPARITHMETIQUE

%union{int value; char * variable;}

%left tPLUS tMOINS
%right tFOIS tDIV tEG

%start Prg
%%
Prg :  Dfct Prg
	|Main;

Dfct : tINT tID tPO PARAMS tPF BODYF;

Main : tINT tMAIN tPO tPF BODY {print_table();};

PARAMS : PARAM tVIR PARAMS
		| PARAM
		|;

PARAM : tINT tID ;

BODYF : tAO INSTRUCTIONS tAF;

BODY : tAO {up_depth();} DECLARATIONS INSTRUCTIONS tAF {/*delete_depth_at();*/down_depth(); };

DECLARATIONS : tINT SUITEDECLARATIONS tPV DECLARATIONS
	| tCONST tINT AFFECTATIONS tPV DECLARATIONS			
	| ;

SUITEDECLARATIONS : DECLARATION tVIR SUITEDECLARATIONS
				| DECLARATION;

DECLARATION : tID {add_symb($1,0,0);}
		| tID tEG EXPARITHMETIQUE {add_symb($1,1,0);};

AFFECTATIONS : AFFECTATION tVIR AFFECTATIONS
		| AFFECTATION;

AFFECTATION : tID tEG EXPARITHMETIQUE {/*COP $1 $3*/};

INSTRUCTIONS : 	AFFECTATION tPV INSTRUCTIONS
			| 	WHILE INSTRUCTIONS
			|	IF INSTRUCTIONS	
			| 	RETURN
			|	tPV
			| 	PRINT
			|;

EXPARITHMETIQUE : EXPARITHMETIQUE tPLUS EXPARITHMETIQUE {/*create temp var (add_symb_temp)
								ADD temp3 $1 $3
								--- retourner @temp3*/}
				| EXPARITHMETIQUE tMOINS EXPARITHMETIQUE
				| EXPARITHMETIQUE tFOIS EXPARITHMETIQUE
				| EXPARITHMETIQUE tDIV EXPARITHMETIQUE
				| EXPARITHMETIQUE tMOD EXPARITHMETIQUE
				| tPO EXPARITHMETIQUE tPF
				| tNB {/*create temp var (add_symb_temp) - AFC <-> AFC @temp1 value     --- retourner @temp1*/}
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
	init_tab();
  yyparse();
}
