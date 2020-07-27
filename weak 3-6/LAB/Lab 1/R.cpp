#include <iostream>

using namespace std;

int main(){
	int x;
	int b = 0x80000000;
	cin >> x;
	int sign = ((x >> 31) & 0x1);
  	int sign_opposite = (((~x + 1) >> 31) & 0x1);
  	cout << ((~(x|(~x+1))>>31)&1)<<endl;
  	cout << !b;
}
