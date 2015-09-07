%{
	#include<stdio.h>
	#define MAX_STATES 100 // increase the no to increase the no of states limit
	void yyerror(char *);
	#include "fa.h"
	#include<string.h>
	#include<stdio.h>
	#include <stdlib.h>
	extern int lineNo;
	int startIsFinal=0;
	struct s state[MAX_STATES];
	int start=0;
	int i=1;
	int yywrap(void);
	void addNextState(char *curr, char input, char *next);
	void addNext(int curr, char input, int next);
	int addState(char *s, int isFinal);
	int ex();
%}
%union {
	char *stateName;
	char input;
	char automata;
};
%token <automata> FA
%token <stateName> STATE
%token <input> INPUT
%token START STARTFINAL FINAL INTERMEDIATE ENDL
%%
st:
	end0 FA end start intermediate final rules '%' end0 {
					ex();
				}
	|
	;
start:
	START STATE end {
					state[0].name=$2;
					state[0].isFinal=0;
				}
	| STARTFINAL STATE end {
					state[0].name=$2;
					state[0].isFinal=1;
				}
	;
intermediate:
	INTERMEDIATE stateI end
	|
	;
stateI:
	STATE stateI	{ addState($1,0); }
	| STATE		{ addState($1,0); }
	;
final:
	FINAL stateF end
	|
	;
stateF:
	STATE stateF	{ addState($1,1); }
	| STATE 		{ addState($1,1); }
	;
rules:
	rules rule
	|
	;
rule:
	'(' STATE INPUT ')' '=' STATE end	{ addNextState($2,$3,$6); }
	;
end0:
	end
	|
	;
end:
	ENDL end
	| ENDL
	;
%%
void yyerror(char *s)
{
	fprintf(stderr,"Line %d:%s\n",lineNo,s);
	exit(-1);
}
int ex()
{
	char ch;
	int current;
	struct next *ptr;
	while(ch!=EOF)
	{
		current=start;
		while((ch=getchar())!=EOF && ch!='\n')
		{
			ptr=state[current].n;
			while(ptr!=NULL)
			{
				if(ptr->input == ch)
					break;
				ptr=ptr->n;
			}
			if(ptr==NULL)
			{
				printf("(%s,%c)\n",state[current].name,ch);
				yyerror("No transition defined");
			}
			current=ptr->nextState;
		}
		if(state[current].isFinal)
			printf("Accepted\n");
		else
			printf("Not Accepted\n");
	}

}
int addState(char *s, int isFinal)
{
	int j;
	if(i >= MAX_STATES)
	{
		yyerror("Max no of states limit reached.");
	}
	for(j=0;j<i;j++)
	{
		if(strcmp(state[j].name,s) == 0)
			yyerror("State Already declared");
	}
	state[i].name=s;
	state[i].isFinal=isFinal;
	state[i].n=NULL;
	i++;
	return i-1;
}
void addNext(int curr, char input, int next)
{
	struct next *ptr=state[curr].n,*par;
	if(ptr == NULL)
	{
		if((state[curr].n=malloc(sizeof(struct next))) == NULL)
			yyerror("Memory Allocation Error");
		ptr=state[curr].n;
	}
	else
	{
		while(ptr!=NULL)
		{
			par=ptr;
			ptr=ptr->n;
		}
		if((ptr=malloc(sizeof(struct next))) == NULL)
			yyerror("Memory Allocation Error");
		par->n = ptr;
	}
	ptr->input=input;
	ptr->nextState=next;
	ptr->n=NULL;
}
void addNextState(char *curr, char input, char *next)
{
	int c = -1;
	int n = -1;
	int j;
	for(j=0;j<i;j++)
	{
		if(strcmp(curr,state[j].name) == 0)
			c=j;
		if(strcmp(next,state[j].name) == 0)
			n=j;
	}
	if(c == -1)
	{
		printf("State '%s' is not declared\n",curr);
	}
	if(n == -1)
	{
		printf("State '%s' is not declared\n",next);
	}
	if(c == -1 || n == -1)
	{
		yyerror("Invalid State(s)");
	}
	else
	{
		addNext(c,input,n);
	}
}