%{
//declaration : include etc,
#include "source.h"
#include <stdlib.h>
%}

WHITESPACES [ \t\n]+
DIGIT       [0-9]
NUMBER      {DIGIT}+
EXP         {NUMBER}[eE][+-]?{NUMBER}
REEL        {NUMBER}("."{NUMBER})?{EXP}?

%%

{WHITESPACES}  { }
"main"		return(tMAIN);
"const"		return(tCONST);
"int" 		return(tINT);
"if" 		return(tIF);
"while" 	return(tWHILE);
"return" 	return(tRETURN);
"printf"	return(tPRINT);
[a-zA-Z][_a-zA-Z0-9]*	{yylval.variable = strdup(yytext); return(tID);}
"{" 		return(tAO);
"}" 		return(tAF);
"(" 		return(tPO);
")" 		return(tPF);	
"+"		return(tPLUS);
"-"		return(tMOINS);
"*"		return(tFOIS);
"/"		return(tDIV);
"%"		return(tMOD);
"="		return(tEG);
"=="		return(tEGALITE);
"||"		return(tOU);
"&&"		return(tET);
">"		return(tSUP);
">="		return(tSUPEG);
"<="		return(tINFEG);
"<"		return(tINF);
"!"		return(tNON);
{NUMBER}	{yylval.value = atof(yytext); return tNB;}
{REEL}		{yylval.value = atof(yytext); return tNB;}
{EXP}		{yylval.value = atof(yytext); return tNB;}
","		return(tVIR);
";"		return(tPV);
.		return(tERR);

%%
