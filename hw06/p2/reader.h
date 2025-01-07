#pragma once

#include <string>
#include <vector>
#include <sstream>
using namespace std;

class reader{
	private:
		vector <string> words;
	public:
		reader(const string& filename){
			ifstream file(filename);
			string line, word;

			if(!file){
				cerr << " Error: loading file " << filename << endl;
				return;
			}	
			
			while(getline(file, line)){
				istringstream iss(line);
				while(iss >> word){
					words.push_back(word);
				}
			}			
		}
	void reversePrint() const {
		cout << "###################################" << endl;
		cout << "p2:" << endl;
		cout << endl;
		for(auto it =words.rbegin(); it !=words.rend(); ++it){
			cout << *it << endl;
		}
		cout << "###################################" << endl;
	}

};
