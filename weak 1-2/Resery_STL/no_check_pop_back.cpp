/*
* @Author: resery
* @Date:   2020-07-10 13:31:49
* @Last Modified by:   resery
* @Last Modified time: 2020-07-11 09:13:45
*/
#include <vector>
#include <iostream>
#include <cstdlib>
#include <string>

using namespace std;

int main(){

	vector<int> first(5,1);
    vector<int> second(5,2);
    vector<int> third(5,3);
    vector<int> fourth(8,4);
    vector<int>::iterator first_begin = first.begin();
    vector<int>::iterator first_end = first.end();
    vector<int>::iterator second_begin = second.begin();
    vector<int>::iterator second_end = second.end();
    vector<int>::iterator fourth_begin = fourth.begin();
    vector<int>::iterator fourth_end = fourth.end();
    cout << "-------------------------------" <<endl;
    cout << "---------init------------------" <<endl;
    cout << "first_begin:" << "\t" << &*(first_begin) << endl;
    cout << "first_end:" << "\t" << &*(first_end) << endl;
    cout << "second_1_begin:" << "\t" << &*(second_begin) << endl;
    cout << "second_1_end:" << "\t" << &*(second_end) << endl;
    cout << "fourth_begin:" << "\t" << &*(fourth_begin) << endl;
    cout << "fourth_end:" << "\t" << &*(fourth_end) << endl;
    cout << "The first size : " <<  hex << "0x" << first[-2] << endl;
    cout <<endl;
    second.pop_back();
    second.pop_back();
    second.pop_back();
    second.pop_back();
    second.pop_back();
    second.pop_back();
    second.pop_back();
    second.pop_back();
    second.pop_back();
    second.pop_back();
    second.pop_back();
    second.pop_back();
    second.pop_back();
    second.pop_back();
    second.pop_back();
    second_begin = second.begin();
    second_end = second.end();
    cout << "-------------------------------" <<endl;
    cout << "---------after pop back--------" <<endl;
    cout << "second_2_begin:" << "\t" << &*(second_begin) << endl;
    cout << "second_2_end:" << "\t" << &*(second_end) << endl;
    cout <<endl;
    second.push_back(0x91);
    second_begin = second.begin();
    second_end = second.end();
    cout << "-------------------------------" <<endl;
    cout << "---------after push back-------" <<endl;
    cout << "second_3_begin:" << "\t" << &*(second_begin) << endl;
    cout << "second_3_end:" << "\t" << &*(second_end) << endl;
    cout <<endl;
    cout << "-------------------------------" <<endl;
    cout << "---------result----------------" <<endl;
    cout << "The first size be changed: " <<  hex << "0x" << first[-2] << endl;
    return 0;
    
}