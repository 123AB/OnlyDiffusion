//
// Created by 89270 on 13/05/2021.
//

//#include "diffusion_zhiyue.h"
#include<cstdlib>
#include<iostream>
#include<random>
#include<string>
#include<sstream>
#include<utility>
#include "Graph.h"
#include "util.h"

using namespace std;

tuple<double, double> original_Algorithm(int sampling, Graph* g, std::default_random_engine gen, std::uniform_real_distribution<> dis, double rho){
    double spread_m = 0.0;
    double spread_f = 0.0;
    for(int i=0; i<sampling; i++){

        list<User*> current;

        for(list<User*>::iterator it = g->seeds.begin(); it != g->seeds.end(); it++){
            if((*it)->is_male){
                spread_m += 1;
            }
            else{
                spread_f += 1;
            }
            current.push_back(*it);
        }

        while(current.size() > 0){
            list<User*> next;
            for(list<User*>::iterator it = current.begin(); it != current.end(); it++){
                User* u = *it;
                for(list<Edge*>::iterator fit = u->friends.begin(); fit != u->friends.end(); fit++){
                    User* v = (*fit)->u2;
                    double w = (*fit)->w;
                    if(!v->active && ((u->is_male == v->is_male) || dis(gen) < rho) && dis(gen) < w){
                        v->active = true;
                        if(v->is_male){
                            spread_m += 1;
                        }
                        else{
                            spread_f += 1;
                        }
                        next.push_back(v);
                    }
                }
            }
            current.clear();
            current = next;
            next.clear();
        }
        g->reset();
    }
    spread_m /= (double)sampling;
    spread_f /= (double)sampling;

    return{spread_m,spread_f};
}

tuple<double, double> temporal_effect_Algorithm(int sampling, Graph* g, std::default_random_engine gen, std::uniform_real_distribution<> dis, double rho){
    double spread_m = 0.0;
    double spread_f = 0.0;

    spread_m /= (double)sampling;
    spread_f /= (double)sampling;

    return{spread_m,spread_f};
}


int main(int argc, char* argv[]){
    // network, seed_file, k, rho, sampling

    string network = "network";
    string seed_file = "seeds";
    int k = -1;
    double rho = 1.0;
    int sampling = 10000;


    if(argc >= 4){
        network = argv[1];
        seed_file = argv[2];
        k = std::stoi(argv[3], NULL);

        if(argc >= 5){
            rho = std::stod(argv[4], NULL);
            if(argc >= 6){
                sampling = std::stoi(argv[5], NULL);
            }
        }
    }

    //string filename = "comment_{}.csv";
    //std::vector<int> list = range(1,957);
    //for(auto i : list){
    //    std::string s = boost::format("%2% %1%!\n") % a % b;

    //string s = std::format("{:10}", "some_string");
    Graph* g = read(network, seed_file, k);
    // cout << "Finish reading" << endl;

    std::random_device rd;
    std::default_random_engine gen = std::default_random_engine(rd());
    std::uniform_real_distribution<> dis(0, 1);

    double spread_m = 0.0;
    double spread_f = 0.0;

    tie(spread_m, spread_f) = original_Algorithm(sampling, g, gen, dis, rho);
    cout << "the spread_m:" << spread_m;
    cout << "the spread_f:" << spread_f;
    cout<<"hi"<<endl;
    // output
    stringstream ss;
    ss << network << "_" << seed_file << "_" << sampling << ".out";
    string new_ss =  "diffusion_results.txt";
    fstream ff;
    try{
        //ff.open(ss.str(), ios::out);
        ff.open(new_ss, ios::app);
        ff << spread_m << "\t" << spread_f << endl;
        ff.close();
        cout << ss.str() << endl;
        cout << "finish!" << endl;
    }
    catch(std::stringstream::failure e){

        std::cerr << "Exception opeing file";
        cout << "open file failed" << endl;
    }


    // }



}

