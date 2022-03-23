//
// Created by 89270 on 28/06/2021.
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
        g_original->reset();
    }
    spread_m /= (double)sampling;
    spread_f /= (double)sampling;

    return{spread_m,spread_f,reLis};
}

tuple<double, double,list<User*>> temporal_effect_Algorithm(int sampling, Graph* g, std::default_random_engine gen, std::uniform_real_distribution<> dis, double rho, list<User*> it_seed, int seed_limit, Graph* g_original){
    double spread_m = 0.0;
    double spread_f = 0.0;
    list<User*> reLis;

    for(int i=0; i<sampling; i++){

        list<User*> current;
        int seed_count = 0;
        reLis.clear();

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
            seed_count++;
            current.push_back(*it);
        }


        for(list<User*>::iterator cur_it_seed = it_seed.begin(); cur_it_seed != it_seed.end(); cur_it_seed++){
            User* it_seed_user = *cur_it_seed;
            //if(it_seed_user->active){
            if((it_seed_user)->is_male){
                spread_m += 1;
            }
            else{
                spread_f += 1;
            }
            current.push_back(it_seed_user);

            //}

            //else{
            //}

        }

        //
        //it_seed.clear();
        //

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
                        //it_seed.push_back(v);
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
    //printSeed(it_seed);
    return{spread_m,spread_f,reLis};
}


int main(int argc, char* argv[]){
    // network, seed_file, k, rho, sampling
    //string fileName = "intensityc";
    //string fileName= "intensityc";
    string fileName = "hindexc";
    //string fileName = "pagerankc";
    //string fileName= "indegreec";


    int k = -1;
    double rho = 1.0;
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
    //int seed_size[1] = {500};
    //int seed_size[7] = {50,75,100,125,150,175,200}; //this is seed size 100
    int seed_size[1] = {100}; //this is seed size 100

    double ratio_counter_list[11] = {0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0};

    //double ratio_list_like_100[10] = {0.674,0.676,0.675,0.652,0.669,0.651,0.666,0.660,0.673,0.666};
    //double ratio_list_comment_100[10] = {0.554,0.554,0.552,0.551,0.552,0.550,0.550,0.550,0.557,0.560};

    //
    //double ratio_list_like_100[11] = {0.3179498782663622, 0.43813588858491964, 0.4705752681334521, 0.45652636808857977, 0.4583416874325704, 0.4014066346266557, 0.38268943871920724, 0.3892896461819806, 0.37417323122977414, 0.36062745526467926, 0.5396579586754383}; // this is seed 100
    //double ratio_list_like_100[11] = {0.3478779628551021, 0.41344528786833223, 0.4941446922492712, 0.4668503895985926, 0.43177220359588536, 0.3771823035434704, 0.3693423677152825, 0.3643333633063202, 0.3391055399395681, 0.3455927320611144, 0.4925363086430439};  // this is ratio_list_like_200
    //double ratio_list_like_100[11] = {0.3770140126106636, 0.39428582379054294, 0.5277605456621399, 0.44618049618979544, 0.43130772409683726, 0.3565264908610233, 0.3165307469624352, 0.289874287060329, 0.2574227469334956, 0.21050814546141172, 0.4340338437120396};  // this is ratio list like 500
    //double ratio_list_like_100[11] = {0.23, 0.57, 0.18, 0.6, 0.35, 0.76, 0.48, 0.28, 0.17, 0.22}; //this is ratio_like 200
    //double ratio_list_like_100[11] = {0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0};  // this is ratio_list_like_200

    //double ratio_list_like_100[11] = {0.48, 0.47, 0.49, 0.46, 0.45, 0.44, 0.43, 0.50, 0.42, 0.41, 0.40};
    double ratio_list_like_100[11] = {0.64, 0.61, 0.81, 0.58, 0.29, 0.25, 0.6, 0.39, 0.49, 0.76};
    //double ratio_list_like_100[11] = {0.48, 0.47, 0.48, 0.48, 0.48, 0.47, 0.47, 0.47, 0.47, 0.47, 0.47}

    //double ratio_list_like_100[11] = {0.46, 0.48, 0.49, 0.45, 0.48, 0.48, 0.49, 0.44, 0.39, 0.43, 0.50}; //this is ratio_like 200
    //double ratio_list_like_100[11] = {0.53, 0.52, 0.51, 0.49, 0.54, 0.48, 0.47, 0.44, 0.42, 0.41, 0.43};
    //double ratio_list_like_100[11] = {0.64, 0.61, 0.81, 0.58, 0.29, 0.25, 0.6, 0.39, 0.49, 0.76};

    //double ratio_list_like_100[10] = {0.688,0.687,0.683,0.678,0.676,0.673,0.680,0.675,0.678,0.687};  // this is ratio_list_like_200
    //double ratio_list_comment_100[10] = {0.558,0.559,0.558,0.556,0.550,0.551,0.553,0.556,0.554,0.558}; // this is ratio_list_comment_200
    int filePiece = 546;
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

            int seed_limit = ceil(seed_size[seed_size_len] / 12);
            for(int i = 535; i <= filePiece; i++){
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


                //oss << "../student_preprocess/diffusion/netWorkFileYear/like_" << i << ".csv";
                //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_Year/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss << "../student_preprocess/diffusion/netWorkFileYear/comment_" << i << ".csv";
                //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_Year/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";


                //oss << "../student_preprocess/diffusion/netWorkFileHalfYear/comment_" << i << ".csv";
                //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_HalfYear/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss << "../student_preprocess/diffusion/netWorkFileHalfYear/like_" << i << ".csv";
                //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_HalfYear/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";


                //oss << "../student_preprocess/diffusion/netWorkFileYear/like_" << i << ".csv";
                //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_Year/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";

                //oss << "../student_preprocess/diffusion/netWorkFileSeason/comment_" << i << ".csv";
                //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_season/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss << "../student_preprocess/diffusion/netWorkFileSeason/like_" << i << ".csv";
                //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_season/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_first << "../student_preprocess/diffusion/old_data/comment" << ".csv";
                //oss_first << "../student_preprocess/diffusion/old_data/like" << ".csv";

                //oss << "../student_preprocess/diffusion/netWorkFileMonth/comment_" << i << ".csv";
                //oss_seed << "../student_preprocess/intensity_temporal/intensity_diversity_seed/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/pageRank_temporal/pagerank_seed/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/indegree_temporal/indegree_diversity_seed/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";

                //oss_first << "../student_preprocess/diffusion/ins_month/comment_557" << ".csv";
                oss_first << "../student_preprocess/diffusion/ins_month/comment_557" << ".csv";

                //oss << "../student_preprocess/diffusion/ins_month/comment_" << i << ".csv";
                oss << "../student_preprocess/diffusion/ins_month/comment_" << i << ".csv";

                //oss_seed << "../student_preprocess/indegree_temporal_ins/indegree_diversity_seed/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/ins_full_dataset/intensity_diversity_seed/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/pagerank_temporal_ins/pagerank_diversity_seed/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                oss_seed << "../student_preprocess/target_hindex_temporal_ins/diversity_month_hi_index_ins/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";





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

                if(firstTime == true){
                    std::string var_seed_file_first = oss_seed.str();
                    std::string var_first = oss_first.str();
                    string seed_file_first = var_seed_file;
                    string network_first =  var_first;
                    k = ratio;
                    Graph* g_original = read(network_first, seed_file_first, k);
                    tie(spread_m, spread_f,it_seed) = first_original_Algorithm(sampling, g, gen, dis, rho,seed_limit, g_original);
                    firstTime = false;

                }
                else{
                    //for(int l=0;l<10;l++) {
                    cout << "Start temporal_effect_Algorithm:" << endl;
                    std::string var_seed_file_first = oss_seed.str();
                    std::string var_first = oss_first.str();
                    string seed_file_first = var_seed_file;
                    string network_first = var_first;
                    k = ratio;
                    Graph *g_original = read(network_first, seed_file_first, k);
                    tie(spread_m, spread_f, it_seed) = temporal_effect_Algorithm(sampling, g, gen, dis, rho,
                                                                                 it_seed, seed_limit, g_original);
                    //tie(spread_m, spread_f) = original_Algorithm(sampling, g, gen, dis, rho);
                    cout << "Finish temporal_effect_Algorithm:" << endl;
                    //}
                }

                //
                cout << "the spread_m:" << spread_m;
                cout << "the spread_f:" << spread_f;
                //printSeed(it_seed);
                cout<<"hi"<<endl;
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

            }



        }




    }



    // }



}

