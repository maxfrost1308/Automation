%{
	#include "y.tab.h"
	int startDone=0;
	int j;
	int lineNo=1;
%}
%%
#.* ;
\%fa return FA;
\%s {return START;}
\%sf return STARTFINAL;
\%i return INTERMEDIATE;
\%f return FINAL;
[a-zA-Z][a-zA-Z0-9]* {yylval.stateName=strdup(yytext);return STATE;}
[ ] ;
,. {yylval.input=yytext[1];return INPUT;}
[()=] return *yytext;
[%] return *yytext;
[\n]+ {for(j=0;yytext[j]!='\0';j++,lineNo++);return ENDL;}
. return *yytext;
%%
int yywrap(void)
{
	return 1;
}
int main(int argc, char *argv[])
{
	FILE *fp;
	if(argc == 2)
	{
		fp=fopen(argv[1],"r");
		if(fp != NULL)
			yyin=fp;
		else
			yyerror("File Cannot be opened");
	}
	else
		yyerror("No File specified");
	yyparse();
	return 0;
}