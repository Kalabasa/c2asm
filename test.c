/*
 * Test Code
 *
 *	Counts down to zero.
 */
int main(int argc, char* argv[]){
	int i = 10;
	while(i --> 0){ // i goes to zero
		printf("%s ticks left.", i);
	}
	return 0;
}
