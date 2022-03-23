//
// Created by 89270 on 31/07/2021.
//

//
// Created by 89270 on 13/07/2021.
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
#include <algorithm>


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

tuple<double,double> gender_ratio_rebalance(double spread_m_cul, double spread_f_cul, double target_gender_ratio, int seed_limit){
    double spread_gender_ratio = spread_f_cul/spread_m_cul;
    double current_gender_ratio = 2.0*target_gender_ratio - spread_gender_ratio;
    double m_seed_num = ceil(current_gender_ratio*seed_limit);
    double f_seed_num = ceil((1-current_gender_ratio)*seed_limit);

    return {f_seed_num,m_seed_num};
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

tuple<double, double,list<User*>,list<User*>> first_original_Algorithm(int sampling, Graph* g, std::default_random_engine gen, std::uniform_real_distribution<> dis, double rho,int seed_limit, Graph* g_original){
    double spread_m = 0.0;
    double spread_f = 0.0;
    list<User*> reLis;
    list<User*> seedLis;

    for(int i=0; i<sampling; i++){

        list<User*> current;
        reLis.clear();
        seedLis.clear();
        int seed_count = 0;

        int count_per_select_seed = 0;
        //
        for(list<User*>::iterator it_per_select_seed = g_original->seeds.begin(); it_per_select_seed != g_original->seeds.end() && count_per_select_seed < seed_limit; it_per_select_seed++){
            if((*it_per_select_seed)->is_male){
                spread_m += 1;
                seedLis.push_back(*it_per_select_seed);

            }
            else{
                spread_f += 1;
                seedLis.push_back(*it_per_select_seed);

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
    }
    spread_m /= (double)sampling;
    spread_f /= (double)sampling;

    return{spread_m,spread_f,reLis,seedLis};
}

tuple<double, double,list<User*>,list<User*>> temporal_effect_Algorithm_improved(int sampling, Graph* g, std::default_random_engine gen, std::uniform_real_distribution<> dis, double rho, list<User*> it_seed, int seed_limit, Graph* g_original,double ratio, list<User*> it_pervious_seeds){
    double spread_m = 0.0;
    double spread_f = 0.0;
    double count_seed_m = 0.0;
    double count_seed_f = 0.0;

    double m_seed_num = 0.0;
    double f_seed_num = 0.0;
    list<User*> reLis;
    list<User*> seedLis;
    //tie(m_seed_num, f_seed_num) = gender_ratio_rebalance(total_m_seed, total_f_seed, ratio, seed_limit);
    for(int i=0; i<sampling; i++){

        list<User*> current;
        int seed_count = 0;
        int count_per_select_seed = 0;
        count_seed_m = 0.0;
        count_seed_f = 0.0;
        reLis.clear();
        seedLis.clear();

        //
        for(list<User*>::iterator it_per_select_seed = g_original->seeds.begin(); it_per_select_seed != g_original->seeds.end() && count_per_select_seed < seed_limit; it_per_select_seed++){
            //cout << "Seed limit:" << seed_limit;
            //cout << "count_seed_m:" << ceil(seed_limit*ratio);
            //cout << "count_seed_f:" << ceil(seed_limit*(1.0-ratio));
            if((*it_per_select_seed)->is_male && count_seed_m <= ceil(seed_limit*ratio)){
                spread_m += 1;
                count_seed_m += 1;
                count_per_select_seed++;
                //cout << "count_seed_m:" << count_seed_m;
            }
            else{
                if(count_seed_f <= ceil(seed_limit*(1.0-ratio))){
                    spread_f += 1;
                    count_seed_f += 1;
                    count_per_select_seed++;
                    //cout << "count_seed_f:" << count_seed_f;

                }

            }
            //current.push_back(*it_per_select_seed);
        }
        //did my zhiyue zhang
        //cout << "Seed limit:" << seed_limit;
        //cout << "count_seed_m:" << count_seed_m;
        //cout << "count_seed_f:" << count_seed_f;

        count_seed_m = 0.0;
        count_seed_f = 0.0;
        for(list<User*>::iterator it = g->seeds.begin(); it != g->seeds.end() && seed_count < seed_limit; it++){
            if((*it)->is_male && count_seed_m <= ceil(seed_limit*ratio)){
                //spread_m += 1;
                if((std::find(it_pervious_seeds.begin(), it_pervious_seeds.end(), *it) != it_pervious_seeds.end()) == false){
                    count_seed_m += 1;
                    seed_count++;
                    current.push_back(*it);
                    seedLis.push_back(*it);

                }
                else{
                }


            }
            else{
                if(count_seed_f <= ceil(seed_limit*(1.0-ratio))){
                    if((std::find(it_pervious_seeds.begin(), it_pervious_seeds.end(), *it) != it_pervious_seeds.end()) == false){
                        seed_count++;
                        count_seed_f += 1;
                        current.push_back(*it);
                        seedLis.push_back(*it);

                    }
                    else{

                    }


                    //spread_f += 1;
                }
            }
            //seed_count++;
            //current.push_back(*it);
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
            g->add_seed(it_seed_user);
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
    return{spread_m,spread_f,reLis,seedLis};
}


int main(int argc, char* argv[]){
    // network, seed_file, k, rho, sampling
    //string fileName = "intensityc";
    string fileName= "intensityl";
    //string fileName= "pagerankc";
    //string fileName = "hindexl";
    //string fileName = "indegreec";

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
    int seed_size[10] = {5,10,20,50,100,200,500,1000};
    int filePiece = 220;
    double seed_ratio[24] = {0.03815288827308658, 0.038658781088945375, 0.039006631384175226, 0.038849252741330484, 0.03903426440717119, 0.03926945315487026, 0.03982432360451349, 0.04030870973782025, 0.04064017270648738, 0.0409995238488661, 0.04136673272738872, 0.0416933047670591, 0.04216214874270481, 0.04253551852701059, 0.04273680769153719, 0.04303485655464194, 0.04344230252494714, 0.04369446176632122, 0.04389095175182407, 0.04410581366116462, 0.04410158067375313, 0.044146326552655005, 0.04417478789384402, 0.04417040521788208};
    double scaling_parameter[15] = {1.3,1.3,1.4,1.4,1.4,1.5,1.5,1.6,1.6,1.7,1.7,1.8,1.8,1.8,1.8};
    //double seed_ratio[24] = {0.036603221,0.037142637,0.037450875,0.037836172,0.038760885,0.039300301,0.039916776,0.040302073,0.04068737,0.041149726,0.041457964,0.041843261,0.042459736,0.042767974,0.042999152,0.04330739,0.043846806,0.044077984,0.044386222,0.044694459,0.044694459,0.044771519,0.044771519,0.044771519};
    /*year
    double seed_ratio[] = {0.0043, 0.00087,0.00043,0.101,0.1852,0.2252,0.250,0.253};
    */
    //int totalFileNum = 957 - 763;
    //int totalFileNum = 900 - 800;
    //int chunk_fileSize = totalFileNum / filePiece;

    for (double ratio = 0.0; ratio<=1.0; ratio = ratio + 0.1){
        for(int seed_size_len = 0; seed_size_len<sizeof(seed_size)/sizeof(seed_size[0]); seed_size_len = seed_size_len + 1){
            bool firstTime = true;
            list<User*> it_seed;
            list<User*> it_current_select_seeds;
            list<User*> it_total_seeds;

            //created by zhiyue zhang
            //double total_m_seed = 0.0;
            //double total_f_seed = 0.0;

            //double total_m_seed_current = 0.0;
            //double total_f_seed_current = 0.0;

            //created by zhiyue zhang
            //cut file into five pieces

            for(int i = 197; i <= filePiece; i++){
                int seed_limit = ceil(seed_size[seed_size_len] * seed_ratio[i-197]);
                if(i < 206){
                    seed_limit = ceil(seed_size[seed_size_len] * seed_ratio[i-197]);

                }
                else{
                    seed_limit = ceil(seed_size[seed_size_len] * seed_ratio[i-197])*scaling_parameter[i-206];
                    //cout << "Seed limit:" << seed_limit;
                }

                //cout << "Seed limit:" << seed_limit;
                //cout << "float:" << seed_ratio[i];

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


                //oss << "../student_preprocess/diffusion/netWorkFileYear/comment_" << i << ".csv";
                //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_Year/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                oss_first << "../student_preprocess/diffusion/old_data/like" << ".csv";

                //oss << "../student_preprocess/diffusion/netWorkFileSeason/comment_" << i << ".csv";
                //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_season/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss << "../student_preprocess/diffusion/netWorkFileSeason/like_" << i << ".csv";
                //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_season/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";

                oss << "../student_preprocess/diffusion/netWorkFileMonth/like_" << i << ".csv";
                //oss_seed << "../student_preprocess/indegree_temporal/indegree_diversity_seed/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_Month/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";

                //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_Month/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/pagerank_temporal/pagerank_seed/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/hindex_temporal/diversity_month_hi_index/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";

                //oss << "../student_preprocess/diffusion/netWorkFileMonth/like_" << i << ".csv";
                //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_Month/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";




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
                    tie(spread_m, spread_f,it_seed,it_current_select_seeds) = first_original_Algorithm(sampling, g, gen, dis, rho,seed_limit,g_original);
                    it_total_seeds.splice(it_total_seeds.end(),it_current_select_seeds);
                    firstTime = false;

                }
                else{
                    cout << "Start temporal_effect_Algorithm:" << endl;
                    std::string var_seed_file_first = oss_seed.str();
                    std::string var_first = oss_first.str();
                    string seed_file_first = var_seed_file;
                    string network_first = var_first;
                    k = ratio;
                    Graph *g_original = read(network_first, seed_file_first, k);
                    //cout << "The real seed num:" << seed_limit;

                    //tie(spread_m, spread_f,it_seed,total_m_seed_current,total_f_seed_current) = temporal_effect_Algorithm(sampling, g, gen, dis, rho,it_seed,seed_limit,g_original,total_m_seed,total_f_seed,ratio);
                    tie(spread_m, spread_f,it_seed,it_current_select_seeds) = temporal_effect_Algorithm_improved(sampling, g, gen, dis, rho,it_seed,seed_limit,g_original, ratio,it_total_seeds);
                    //it_total_seeds.insert(it_total_seeds.end(),it_current_select_seeds.begin(),it_current_select_seeds.end());
                    //printSeed(it_current_select_seeds);
                    it_total_seeds.splice(it_total_seeds.end(),it_current_select_seeds);
                    printSeed(it_total_seeds);
                    //total_m_seed = total_m_seed + total_m_seed_current;
                    //total_f_seed = total_f_seed + total_f_seed_current;
                    //tie(spread_m, spread_f) = original_Algorithm(sampling, g, gen, dis, rho);
                    cout << "Finish temporal_effect_Algorithm:" << endl;

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

            }

        }

    }

}

