/*
* @Author: resery
* @Date:   2020-07-10 18:10:35
* @Last Modified by:   resery
* @Last Modified time: 2020-07-11 15:06:38
*/
#include <vector>
#include <iostream>
#include <string>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

using namespace std;

class no_copy_ctor{

public:
	no_copy_ctor(string content = " ")
    {
        ptr = new string[10];
        for (int i = 0; i < 10; i++)
            ptr[i] = content;
        cout << &(*ptr) << " constructed." << endl;
    }
    ~no_copy_ctor()
    {
        cout << &(*ptr) << " destroyed." << endl;
        delete[] ptr;
    }
    void print (){
    	cout << &(*ptr) << " printed." << endl;
    }
    void uaf(){
    	system("/bin/sh;");
    }

private:
	string *ptr;

};

int main(){

	vector<no_copy_ctor> ncc;
    ncc.push_back(no_copy_ctor("Resery"));
    cout << "-----------------------" << endl;
    cout << "----after push back----" << endl;
    cout << "-----------------------" << endl;
    //ncc.begin()->print();
    //ncc.begin()->uaf();
    return 0;

}