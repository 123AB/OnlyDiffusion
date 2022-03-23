//
// Created by 89270 on 29/06/2021.
//

//
// Created by 89270 on 18/06/2021.
//

//
// Created by 89270 on 12/06/2021.
//

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
#include <iomanip>

using namespace std;

void printSeed(list<User*> it_seed)
{
    cout << "print seed start:" << endl;

    cout << it_seed.size();

    for(std::list<User*>::iterator it = it_seed.begin(); it!= it_seed.end(); ++it)
    {
        User* item = *it;
        item->print();
    }

    cout << "print seed end:" << endl;

}

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

tuple<double, double,list<User*>> first_original_Algorithm(int sampling, Graph* g, std::default_random_engine gen, std::uniform_real_distribution<> dis, double rho,int seed_limit,Graph* g_original){
    double spread_m = 0.0;
    double spread_f = 0.0;
    list<User*> reLis;
    for(int i=0; i<sampling; i++){

        list<User*> current;
        reLis.clear();
        int seed_count = 0;
        int count_per_select_seed = 0;
        //
        for(list<User*>::iterator it_per_select_seed = g_original->seeds.begin(); it_per_select_seed != g_original->seeds.end() && count_per_select_seed < seed_limit; it_per_select_seed++){
            if((*it_per_select_seed)->is_male){
                spread_m += 1;
            }
            else{
                spread_f += 1;
            }
            //current.push_back(*it_per_select_seed);
            count_per_select_seed++;
        }




        //did my zhiyue zhang

        for(list<User*>::iterator it = g->seeds.begin(); it != g->seeds.end() && seed_count < seed_limit; it++){
            if((*it)->is_male){
                //spread_m += 1;
            }
            else{
                //spread_f += 1;
            }
            current.push_back(*it);
            seed_count++;
        }
        //printSeed(current);
        //cout << seed_count << endl;

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
                        reLis.push_back(v);
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
    // user list
    //printSeed(reLis);
    //
    return{spread_m,spread_f,reLis};
}

tuple<double, double,list<User*>> temporal_effect_Algorithm(int sampling, Graph* g, std::default_random_engine gen, std::uniform_real_distribution<> dis, double rho, list<User*> it_seed, int seed_limit){
    double spread_m = 0.0;
    double spread_f = 0.0;
    list<User*> reLis;
/*
    for(list<User*>::iterator cur_it_seed = it_seed.begin(); cur_it_seed != it_seed.end(); cur_it_seed++){
        User* it_seed_user = *cur_it_seed;

        if((it_seed_user)->is_male){
            g->add_seed(it_seed_user);
        }
        else{
            g->add_seed(it_seed_user);
        }

    }
*/
    for(int i=0; i<sampling; i++){
        g->unseeds();
        list<User*> current;
        reLis.clear();

        int seed_count = 0;
        //printSeed(it_seed);
        for(list<User*>::iterator cur_it_seed = it_seed.begin(); cur_it_seed != it_seed.end(); cur_it_seed++){
            User* it_seed_user = *cur_it_seed;
            if((it_seed_user)->is_male){
                g->add_seed(it_seed_user);
            }
            else{
                g->add_seed(it_seed_user);
            }

        }

        for(list<User*>::iterator cur_it_seed = g->seeds.begin(); cur_it_seed != g->seeds.end(); cur_it_seed++){
            User* it_seed_user = *cur_it_seed;
            if(it_seed_user->active){
                if((it_seed_user)->is_male){
                    spread_m += 1;
                }
                else{
                    spread_f += 1;
                }
                //cout << "I am come here";
                current.push_back(it_seed_user);
                //printSeed(current);
            }

            else{
            }

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
                        //cout << "I am come here:" ;
                        next.push_back(v);
                        reLis.push_back(v);
                        //printSeed(reLis);
                    }
                }
            }
            current.clear();
            current = next;
            next.clear();
        }
        //printSeed(reLis);
        g->reset();

    }
    spread_m /= (double)sampling;
    spread_f /= (double)sampling;
    //printSeed(reLis);
    return{spread_m,spread_f,reLis};
    //return{spread_m,spread_f,it_seed};
}


int main(int argc, char* argv[]){
    // network, seed_file, k, rho, sampling
    //string fileName = "intensityc";
    //string fileName= "intensityc";
    //string fileName= "indegreel";
    string fileName = "pagerankc";

    //string fileName = "hindexc";

    int k = -1;
    double rho = 1.0;
    //int sampling = 10000;
    int sampling = 1000;
/*
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
*/
    //string filename = "comment_{}.csv";
    //std::vector<int> list = range(1,957);
    //for(auto i : list){
    //    std::string s = boost::format("%2% %1%!\n") % a % b;

    //string s = std::format("{:10}", "some_string");
    //int seed_size[10] = {5,10,20,50,100,200,500,1000};
    //int seed_size[10] = {5,10,20,50,100,200,500,1000};
    //int seed_size[4] = {100,200,500,1000};
    int seed_size[7] = {50,75,100,125,150,175,200}; //this is seed size 100

    double ratio_counter_list[11] = {0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0};
    //double ratio_counter_list[10] = {0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9};
    //double ratio_list_like_100[10] = {0.674,0.676,0.675,0.652,0.669,0.651,0.666,0.660,0.673,0.666};
    //double ratio_list_comment_100[10] = {0.554,0.554,0.552,0.551,0.552,0.550,0.550,0.550,0.557,0.560};

    //
    //double ratio_list_like_100[10] = {0.688,0.687,0.683,0.678,0.676,0.673,0.680,0.675,0.678,0.687};  // this is ratio_list_like_200
    //double ratio_list_like_100[11] = {0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0};  // this is ratio_list_like_200
    double ratio_list_like_100[11] = {0.53, 0.52, 0.51, 0.49, 0.54, 0.48, 0.47, 0.44, 0.42, 0.41, 0.43};

    //double ratio_list_like_100[11] = {0.2850449594421815, 0.3643528110739663, 0.2636661179943511, 0.2972225543431846, 0.3291640764732027, 0.3958536758328378, 0.40640374952855435, 0.4202143177664483, 0.4488937146766258, 0.4695800493150261, 0.5056304945271488};
    //double ratio_list_like_100[11] = {0.23, 0.57, 0.18, 0.6, 0.35, 0.76, 0.48, 0.28, 0.17, 0.22}; //this is ratio_like 200

    //double ratio_list_comment_100[10] = {0.558,0.559,0.558,0.556,0.550,0.551,0.553,0.556,0.554,0.558}; // this is ratio_list_comment_200

    int filePiece = 220;
    //int totalFileNum = 957 - 763;
    //int totalFileNum = 900 - 800;
    //int chunk_fileSize = totalFileNum / filePiece;
    for (int ratio_size_len = 0; ratio_size_len<sizeof(ratio_list_like_100)/sizeof(ratio_list_like_100[0]); ratio_size_len = ratio_size_len + 1){
        double ratio = ratio_list_like_100[ratio_size_len];
        //double ratio_counter = ratio_counter_list[ratio_size_len];
        for(int seed_size_len = 0; seed_size_len<sizeof(seed_size)/sizeof(seed_size[0]); seed_size_len = seed_size_len + 1){
            bool firstTime = true;
            list<User*> it_seed;

            //cut file into five pieces

            //int seed_limit = seed_size[seed_size_len];
            //int seed_limit = 1870;
            int seed_limit = ceil(seed_size[seed_size_len]);
            //for(int i = 208; i <= filePiece; i++){
            //cout << "HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH" << endl;;
            //int fileNum_limit = 763 + chunk_fileSize * (i - 1);
            //int fileNum_limit = 800 + chunk_fileSize * (i - 1);
            //for(int fileNum = fileNum_limit ; fileNum < (fileNum_limit + chunk_fileSize*i); fileNum++){

            std::ostringstream oss;
            std::ostringstream oss_first;
            std::ostringstream oss_seed;
            std::ostringstream oss_ratio;
            oss_ratio << std::fixed;
            oss_ratio << std::setprecision(1);

            oss_ratio << ratio;
            std::string strRatio = oss_ratio.str();


            //oss << "../student_preprocess/diffusion/netWorkFileMonth/like_" << i << ".csv";
            //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_Month/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";


            oss << "../student_preprocess/diffusion/netWorkFileYear/comment_19" << ".csv";
            //oss << "../student_preprocess/diffusion/netWorkFileYear/comment_" << i << ".csv";
            //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_Year/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-220" << ".csv";
           // oss_seed << "../student_preprocess/target_hindex_temporal/diversity_month_hi_index/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << "220" << ".csv";
            //oss_seed << "../student_preprocess/intensity_temporal/intensity_diversity_seed/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << "220" << ".csv";
            //oss_seed << "../student_preprocess/indegree_temporal/indegree_diversity_seed/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << "220" << ".csv";
            oss_seed << "../student_preprocess/pageRank_temporal/pagerank_seed/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << "220" << ".csv";

            //oss_seed << "../student_preprocess/target_hindex_temporal/diversity_month_hi_index/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-19" << ".csv";

            //oss_seed << "../student_preprocess/target_hindex_temporal/diversity_month_hi_index/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << ratio << "-" << i << ".csv";

            //oss_seed << "../student_preprocess/diffusion/diversity_seed/diversity_seed_original/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << ".csv";

            //oss_first << "../student_preprocess/diffusion/old_data/comment" << ".csv";
            //oss << "../student_preprocess/diffusion/netWorkFileSeason/comment_" << i << ".csv";
            //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_season/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
            //oss_seed << "../student_preprocess/diffusion/diversity_seed/diversity_seed_original_improve/diversity-" << fileName << ".csv";
            //oss_first << "../student_preprocess/diffusion/old_data/like" << ".csv";

            //oss << "../student_preprocess/diffusion/netWorkFileMonth/like_" << i << ".csv";
            //oss << "../student_preprocess/diffusion/old_data/like" << ".csv";
            //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_Month/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";

            //oss << "../student_preprocess/diffusion/netWorkFileHalfYear/comment_" << i << ".csv";
            //oss_seed << "../student_preprocess/diffusion/diversity_seed/diversity_seed_original/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << ".csv";


            std::string var_seed_file = oss_seed.str();
            std::string var = oss.str();

            string seed_file = var_seed_file;

            string network =  var;
            k = ratio;
            Graph* g = read(network, seed_file, k);
            // cout << "Finish reading" << endl;

            std::random_device rd;
            std::default_random_engine gen = std::default_random_engine(rd());
            std::uniform_real_distribution<> dis(0, 1);

            double spread_m = 0.0;
            double spread_f = 0.0;

            //tie(spread_m, spread_f) = original_Algorithm(sampling, g, gen, dis, rho);
            //Created by zhiyue zhang

            std::string var_seed_file_first = oss_seed.str();
            std::string var_first = oss.str();
            string seed_file_first = var_seed_file;
            string network_first = var_first;
            k = ratio;
            Graph *g_original = read(network_first, seed_file_first, k);
            tie(spread_m, spread_f) = original_Algorithm(sampling, g_original, gen, dis, rho);
            firstTime = false;


            /*
            else {
                //for(k=0;k<10;k++) {
                cout << "Start temporal_effect_Algorithm:" << endl;

                tie(spread_m, spread_f, it_seed) = temporal_effect_Algorithm(sampling, g, gen, dis, rho,
                                                                             it_seed, seed_limit);
                //tie(spread_m, spread_f) = original_Algorithm(sampling, g, gen, dis, rho);
                cout << "Finish temporal_effect_Algorithm:" << endl;
                //}
            }
            */


            //
            cout << "the spread_m:" << spread_m;
            cout << "the spread_f:" << spread_f;
            //printSeed(it_seed);
            cout<<"hi"<<endl;
            //cout << seed_limit;
            // output
            stringstream ss;
            ss << network << "_" << seed_file << "_" << sampling << ".out";
            //string new_ss =  "diffusion_results.txt";
            string new_ss =  "diffusion_results_";
            string txt_ss = ".txt";
            string seed_size_break = "_";
            new_ss = new_ss + to_string(ratio) + seed_size_break + to_string(seed_size[seed_size_len]) + txt_ss;


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


                //}

          //  }



        }




    }



    // }



}

