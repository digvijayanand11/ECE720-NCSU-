
#include <systemc.h>
#include "module.h"
#include <map>
#include <vector>

using namespace std;

struct DefinedModule {
    string module_name;
    vector<pair<string, int>> instances;
};

struct InstantiatedModule {
    string instance_name;
    int num_leaf_cells;
};

int countLeafCellsRecursively(const string& mod_name, const map<string, module*>& mods) {
    if (mods.find(mod_name) == mods.end()) {
        return 1;
    }

    module* current_module = mods.at(mod_name);
    int total_leaf_cells = 0;

    for (const string& instance : current_module->instances) {
        if (mods.find(instance) != mods.end()) {
            total_leaf_cells += countLeafCellsRecursively(instance, mods);
        } else {
            total_leaf_cells++;
        }
    }
    //cout << "mod_name = " << mod_name << "\t --  " << total_leaf_cells << endl;

    return total_leaf_cells;
}

int sc_main(int argc, char* argv[])
{

    map<string,module*> mods;
    string line,first,second,current_module;
    size_t pos;
    ifstream f("LMS_pipe.hier");
    vector<DefinedModule> dModules;
    vector<InstantiatedModule> iModules;
	
    string last_module;

    while (f.good()) {
      getline(f,line);
      pos=line.find(' ');
      first = line.substr(0,pos);
      second = line.substr(pos+1);
      //cout << "\"" << first << "\"" << endl;
      //cout << "\"" << second << "\"" << endl;
      if (first == "module") {
        current_module = second;
	last_module = current_module;
        mods[current_module]=new module(current_module);
        //cout << "module " << second << endl;
      }
      else if (second != "") {
        mods[current_module]->addInstance(first);
	DefinedModule dModule;
        dModule.module_name = current_module;
        module* mod_obj = mods[current_module];

            for (const string& instance : mod_obj->instances) {
                if (mods.find(instance) != mods.end()) {
                    int leaf_cells_in_submodule = countLeafCellsRecursively(instance, mods);
                    dModule.instances.push_back({instance, leaf_cells_in_submodule});
                    iModules.push_back({instance, leaf_cells_in_submodule});
                } else {
                    dModule.instances.push_back({instance, 1});
                    iModules.push_back({instance, 1});
                }
            }

            dModules.push_back(dModule);
      }

    }
    f.close(); 

    //cout << "Defined Modules (dModules):\n";
    for (const auto& dModule : dModules) {
        //cout << "Module: " << dModule.module_name << endl;
        for (const auto& instance : dModule.instances) {
           // cout << "  Instance: " << instance.first << ", Leaf cells: " << instance.second << endl;
        }
    }

    //cout << "\nInstantiated Modules (iModules):\n";
    for (const auto& iModule : iModules) {
        //cout << "Instance: " << iModule.instance_name << ", Leaf cells: " << iModule.num_leaf_cells << endl;
    }

    map<string,module*>::iterator it;
    for (it=mods.begin(); it != mods.end(); it++) {
      cout << "module " << it->second->name << endl;
      it->second->print();
      }

    int total_leaf_cells_in_final_module = countLeafCellsRecursively(last_module, mods);
    cout << "\n######################################" << endl;
    cout << "p1:\n" << endl;
    cout << "\nTotal leaf cells in the final module '" << last_module << "': " << total_leaf_cells_in_final_module << endl;
    cout << "\n######################################" << endl;

    return 0;
}
