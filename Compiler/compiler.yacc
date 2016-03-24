%{
#include<stdio.h>
#include"table_of_symbol.h"
#include"asm.h"


int yyerror(char *s);
int error= 0;
extern int current_row;
extern int current_row_temp;
extern int depth;
extern int counter;

FILE * f;
extern struct s_instruction prog[512];

%}

%token tMAIN
%token tID tCONST
%token tPLUS tMOINS tETOILE tDIV tEG
%token tPO tPF tCO tCF
%token tAO tAF
%token tEGALITE tOU tET tSUP tSUPEG tINF tINFEG
%token tNON
%token tIF tELSE tWHILE
%token tPRINT
%token tINT
%token tNB
%token tRETURN
%token tPV tVIR tADDR tERR 

%type <variable> tID
%type <value> tNB
%type <value> tWHILE
%type <value> tIF
%type <value> EXPARITHMETIQUE
%type <value> EXPCONDITIONNELLE
%type <value> AFFECTATION

%union{int value; char * variable;}

%left tPLUS tMOINS
%right tETOILE tDIV tEG

%start Prg
%%
Prg :  Dfct Prg
	|Main;

Dfct : tINT tID tPO PARAMS tPF BODYF
	| tINT tETOILE tID tPO PARAMS tPF BODYF {/*Comment gérer le passage par adresse dans l'usage dans la fonction*/};

Main : tINT tMAIN tPO tPF BODY {};

PARAMS : PARAM tVIR PARAMS
		| PARAM
		|;

PARAM : tINT tID 
	| tINT tETOILE tID;

BODYF : tAO INSTRUCTIONS tAF;

BODY : tAO {up_depth();} DECLARATIONS INSTRUCTIONS tAF {down_depth(); };

DECLARATIONS : tINT SUITEDECLARATIONS tPV DECLARATIONS
	| tCONST tINT AFFECTATIONSCONSTS tPV DECLARATIONS {}
	| tINT tID tCO tNB tCF tPV {int i; for(i = 0; i<$4;i++){add_symb($2,0,0,$4);}}			
	| ;

SUITEDECLARATIONS : DECLARATION tVIR SUITEDECLARATIONS
				| DECLARATION;

DECLARATION : tID 
	{add_symb($1,0,0,1);}
		| tID tEG EXPARITHMETIQUE 
	{ add_symb($1,1,0,1); int args[2]; args[0] = find_symbol($1,depth); args[1] = $3; addInstruction("COP",2,args); current_row_temp--;}
		| tETOILE tID
	{add_symb($2,0,0,1);}
		| tETOILE tID tEG EXPARITHMETIQUE
	{add_symb($2,0,0,1); int args[2]; args[0] = find_symbol($2,depth); args[1] = $4; addInstruction("COP",2,args); current_row_temp--;}
		| tETOILE tID tEG tADDR tID
	{add_symb($2,1,0,1); int args[2]; args[0] = current_row_temp ; args[1]=find_symbol($5,depth); addInstruction("AFC",2,args) ;args[0] = find_symbol($2,depth); args[1] = current_row_temp; addInstruction("PCOPB",2,args);}
		;

AFFECTATIONSCONSTS : AFFECTATIONSCONST tVIR AFFECTATIONSCONSTS
		| AFFECTATIONSCONST;

AFFECTATIONSCONST : tID tEG EXPARITHMETIQUE 
	{ add_symb($1,1,1,1); int args[2]; args[0] = find_symbol($1,depth); args[1] = $3; addInstruction("COP",2,args); current_row_temp--;}
		| tETOILE tID tEG tADDR tID
	{add_symb($2,1,1,1); int args[2]; args[0] = current_row_temp ; args[1]=find_symbol($5,depth); addInstruction("AFC",2,args) ;args[0] = find_symbol($2,depth); args[1] = current_row_temp; addInstruction("PCOPB",2,args);};

AFFECTATIONS : AFFECTATION tVIR { current_row_temp--;} AFFECTATIONS
		| AFFECTATION{ current_row_temp--;} ;

AFFECTATION : tID tEG EXPARITHMETIQUE
	{ int pos = find_symbol($1,depth); 
if(pos==-1){yyerror("Id n'existe pas.");}
else{ if(getSymb(pos)->isConst){yyerror("Attention affectation sur un const.");/*il serait bien d'afficher la ligne*/}
	else{ int args[2]; args[0] = pos; args[1] = $3; addInstruction("COP",2,args); $$ = $3;}}}
		| tETOILE tID tEG EXPARITHMETIQUE 
	{ int pos = find_symbol($2,depth); 
if(pos==-1){yyerror("Id n'existe pas.");}
else{ if(getSymb(pos)->isConst){yyerror("Attention affectation sur un const.");/*il serait bien d'afficher la ligne*/}
	else{ int args[2]; args[0] = pos; args[1] = $4; addInstruction("PCOPB",2,args); $$ = $4;}}}
		| tID tCO EXPARITHMETIQUE tCF tEG EXPARITHMETIQUE
	{int args[3]; args[0] = current_row_temp; args[1] = find_symbol($1,depth) ;args[2] = $3; addInstruction("ADD",3,args);
	args[0] = current_row_temp; args[1] = $3; addInstruction("PCOPB",2,args);current_row_temp--;/*verifier si besoin de supprimer la dernière*/}
	;

INSTRUCTIONS : 	AFFECTATIONS tPV INSTRUCTIONS
			| 	WHILE INSTRUCTIONS
			|	IF INSTRUCTIONS	
			| 	RETURN
			|	tPV INSTRUCTIONS
			| 	PRINT INSTRUCTIONS
			|;

EXPARITHMETIQUE : EXPARITHMETIQUE tPLUS EXPARITHMETIQUE 
	{ int args[3]; args[0] = $1; args[1] = $1;args[2] = $3; addInstruction("ADD",3,args); $$ = $1;current_row_temp--;}
				| EXPARITHMETIQUE tMOINS EXPARITHMETIQUE 
	{ int args[3]; args[0] = $1; args[1] = $1;args[2] = $3; addInstruction("SOU",3,args); $$ = $1;current_row_temp--;}
				| EXPARITHMETIQUE tETOILE EXPARITHMETIQUE 
	{ int args[3]; args[0] = $1; args[1] = $1;args[2] = $3; addInstruction("MUL",3,args); $$ = $1;current_row_temp--;}
				| EXPARITHMETIQUE tDIV EXPARITHMETIQUE 
	{ int args[3]; args[0] = $1; args[1] = $1;args[2] = $3; addInstruction("DIV",3,args); $$ = $1;current_row_temp--;}
				| tPO EXPARITHMETIQUE tPF 
	{$$ = $2;}
				| tNB 
	{ int args[2]; args[0] = current_row_temp; args[1] = $1; addInstruction("AFC",2,args); $$ = current_row_temp; current_row_temp++;}
				| tID 
	{ int args[2]; args[0] = current_row_temp; args[1] = find_symbol($1,depth); addInstruction("COP",2,args); $$ = current_row_temp; current_row_temp++;}
				| tADDR tID 
	{ int args[2]; args[0] = current_row_temp ; args[1]=find_symbol($2,depth); addInstruction("AFC",2,args) ; $$ = current_row_temp; current_row_temp++;} /*a verifier*/
				| tETOILE tID 
	{ int args[2]; args[0] = current_row_temp; args[1] = find_symbol($2,depth); addInstruction("PCOPB",2,args); $$ = current_row_temp; current_row_temp++;}
				| tID tCO EXPARITHMETIQUE tCF
	{ int args[3]; args[0] = current_row_temp; args[1] = find_symbol($1,depth) ;args[2] = $3; addInstruction("ADD",3,args); 
		args[0] = current_row_temp; args[1] = current_row_temp; addInstruction("PCOPA",2,args);
	$$ = current_row_temp; current_row_temp++;};

EXPCONDITIONNELLE : EXPARITHMETIQUE tOU EXPARITHMETIQUE 
						{int args[3]; args[0] = $1; args[1] = $1;args[2] = $3; addInstruction("OR",3,args); $$= $1;current_row_temp--;}
				| 	EXPARITHMETIQUE tET EXPARITHMETIQUE {	int args[3]; args[0] = $1; args[1] = $1;args[2] = $3; addInstruction("AND",3,args);
										;$$= $1;current_row_temp--;}
				| 	EXPARITHMETIQUE tINFEG EXPARITHMETIQUE { int args[3]; args[0] = $1; args[1] = $1;args[2] = $3; addInstruction("INFEQ",3,args);
										;$$= $1;current_row_temp--;}
				| 	EXPARITHMETIQUE tINF EXPARITHMETIQUE { int args[3]; args[0] = $1; args[1] = $1;args[2] = $3; addInstruction("INF",3,args);
										;$$= $1;current_row_temp--;}
				| 	EXPARITHMETIQUE tSUPEG EXPARITHMETIQUE { int args[3]; args[0] = $1; args[1] = $1;args[2] = $3; addInstruction("SUPEQ",3,args);
										$$= $1;current_row_temp--;}
				| 	EXPARITHMETIQUE tSUP EXPARITHMETIQUE { int args[3]; args[0] = $1; args[1] = $1;args[2] = $3; addInstruction("SUP",3,args);
										;$$= $1;current_row_temp--;}
				| 	EXPARITHMETIQUE tEGALITE EXPARITHMETIQUE {  int args[3]; args[0] = $1; args[1] = $1;args[2] = $3; addInstruction("EQU",3,args);
										;$$= $1;current_row_temp--;}
				| 	tNON EXPARITHMETIQUE{ int args[3]; args[0] = current_row_temp; args[1] = 0; addInstruction("AFC",2,args);
							args[0] = $2; args[1] = $2;args[2] = current_row_temp; addInstruction("EQU",3,args); $$ = $2;}
				| 	EXPARITHMETIQUE {$$=$1;}

				|	AFFECTATION{$$ = $1;};

IF : tIF tPO EXPCONDITIONNELLE {current_row_temp--;}tPF { int * args = malloc(2*sizeof(int)); args[0] = $3; $1 = counter; addInstruction("JMF",2,args);} BODY {updateJMF($1,counter);} SUITEIF;

SUITEIF : tELSE BODY
		| ;

WHILE : tWHILE { int args[2];$1 = counter; addInstruction("JMF",2,args);} tPO EXPCONDITIONNELLE {updateWHILE($1,$4);current_row_temp--;} tPF BODY {updateJMF($1,counter);};

RETURN : tRETURN EXPARITHMETIQUE tPV {/*TODO*/}
		| tRETURN tPV;

PRINT : tPRINT tPO tID tPF tPV {int args[1]; args[0] = find_symbol($3,depth); addInstruction("PRI",1,args);}
	| tPRINT tPO tETOILE tID tPF tPV {int args[1]; args[0] = find_symbol(getSymb(find_symbol($4,depth))->name,depth); addInstruction("PRI",1,args);}; /*A verifier*/


%%
int yyerror(char *s) {
 fprintf(stderr,"%s\n",s);
 error = 1;
}

int main(void) {
	counter = 0;	
	yyparse();
	if(!error){
	  print_table_symb();
	  f = fopen("assembler.asm","w");
	  writeProgramToFile(f);
	  fclose(f);
	}else{
	  printf("Process executed returning error\n");
	}
}