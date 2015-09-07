struct s
{
	char *name;
	int isFinal;
	struct next *n;
};
struct next
{
	char input;
	int nextState;
	struct next *n;
};