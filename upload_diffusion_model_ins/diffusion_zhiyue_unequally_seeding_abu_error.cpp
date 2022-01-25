//
// Created by 89270 on 31/07/2021.
//

//
// Created by 89270 on 29/06/2021.
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

tuple<double, double,double,double,int> originalGraphSeed(int seed_limit, Graph* g_original,double ratio,int count_per_select_seed,double count_seed_m,double count_seed_f,double spread_m,double spread_f)
{
    //cout << "Seed limit:" << seed_limit << endl;
    //printSeed(g_original->seeds);
    //cout << "The algorithm has been started:" << ceil(seed_limit*ratio) << endl;
    for(list<User*>::iterator it_per_select_seed = g_original->seeds.begin(); it_per_select_seed != g_original->seeds.end() && count_per_select_seed < seed_limit; ++it_per_select_seed){

        if((*it_per_select_seed)->is_male && count_seed_m <= ceil(seed_limit*ratio)){
            spread_m += 1;
            count_seed_m += 1;
            count_per_select_seed++;
            //cout << "count_seed_m:" << count_seed_m << endl;
        }
        else{
            if(count_seed_f <= ceil(seed_limit*(1.0-ratio))){
                spread_f += 1;
                count_seed_f += 1;
                count_per_select_seed++;
                //cout << "count_seed_fm:" << count_seed_m << endl;
            }

        }

        //current.push_back(*it_per_select_seed);
    }
    //cout << "The algorithm has been finished:" << ceil(seed_limit*ratio) << endl;

    return{spread_m,spread_f,count_seed_m,count_seed_f,count_per_select_seed};

}

tuple<double, double,double,double,int,list<User*>, list<User*>> currentGraphSeed(int seed_limit, Graph* g,double ratio,int seed_count,double count_seed_m,double count_seed_f,double spread_m,double spread_f,list<User*> current,list<User*> seedLis,list<User*> it_pervious_seeds)
{
    //cout << "The algorithm has been started:" << ceil(seed_limit*ratio) << endl;
    for(list<User*>::iterator it = g->seeds.begin(); it != g->seeds.end() && seed_count < seed_limit; it++){
        if((*it)->is_male && count_seed_m < ceil(seed_limit*ratio)){
            //spread_m += 1;
            if((std::find(it_pervious_seeds.begin(), it_pervious_seeds.end(), *it) != it_pervious_seeds.end()) == false){
                count_seed_m += 1;
                seed_count++;
                current.push_back(*it);
                seedLis.push_back(*it);
                //cout << "Seed male num:" << count_seed_m << endl;
                //cout << "count_seed_m second:" << count_seed_m << endl;

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
                    //cout << "Seed female num:" << count_seed_f << endl;;

                }
                else{

                }


                //spread_f += 1;
            }
        }
        //seed_count++;
        //current.push_back(*it);
    }
    //cout << "The algorithm has been finished:" << ceil(seed_limit*ratio) << endl;

    return{spread_m,spread_f,count_seed_m,count_seed_f,seed_count,current,seedLis};

}


tuple<double, double,Graph*,list<User*>> perviousGraphSeed(Graph* g,double spread_m,double spread_f,list<User*> current,list<User*> it_seed)
{

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

    }

    return{spread_m,spread_f,g,current};

}

tuple<double, double,list<User*>, list<User*>> currentGraphSpread(Graph* g, double spread_m,double spread_f,list<User*> current,list<User*> reLis,std::default_random_engine gen, std::uniform_real_distribution<> dis, double rho)
{
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

    return{spread_m,spread_f,current,reLis};

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

tuple<double, double,list<User*>,list<User*>> temporal_effect_Algorithm(int sampling, Graph* g, std::default_random_engine gen, std::uniform_real_distribution<> dis, double rho, list<User*> it_seed, int seed_limit, Graph* g_original,double ratio, list<User*> it_pervious_seeds){
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

        //Count every active seeds
        tie(spread_m,spread_f,count_seed_m,count_seed_f,count_per_select_seed) = originalGraphSeed(seed_limit, g,ratio,count_per_select_seed,count_seed_m,count_seed_f,spread_m,spread_f);
        //did zhiyue zhang
        //cout << "Seed limit second:" << seed_limit << endl;

        count_seed_m = 0.0;
        count_seed_f = 0.0;

        //Select every active seeds from current graph
        tie(spread_m,spread_f,count_seed_m,count_seed_f,seed_count,current,seedLis) = currentGraphSeed(seed_limit, g,ratio,seed_count,count_seed_m,count_seed_f,spread_m,spread_f,current,seedLis,it_pervious_seeds);
        //did by zhiyue zhang


        //select seeds from pervious graph
        tie(spread_m,spread_f,g,current) = perviousGraphSeed(g,spread_m,spread_f,current,it_seed);
        //did by zhiyue zhang

        //spread seed from currentGraph
        tie(spread_m,spread_f,current,reLis) = currentGraphSpread(g, spread_m,spread_f,current, reLis,gen, dis, rho);
        //did by zhiyue zhang

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
    //string fileName= "intensityl";
    string fileName = "hindexc";
    //string fileName= "indegreel";
    //string fileName = "pagerankc";

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
    //int seed_size[10] = {5,10,20,50,100,200,500,1000};
    //int seed_size[7] = {50,75,100,125,150,175,200}; //this is seed size 100
    //int seed_size[1] = {200}; //this is seed size 200
    //int seed_size[1] = {500}; //this is seed size 500
    int seed_size[1] = {100}; //this is seed size 100


    double ratio_counter_list[11] = {0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0};



    //double ratio_list_like_100[10] = {0.664,0.659,0.662,0.652,0.653,0.654,0.656,0.662,0.659,0.667};
    //double ratio_list_comment_100[10] = {0.463,0.465,0.47,0.47,0.475,0.477,0.477,0.478,0.481,0.481};

    //
    //double ratio_list_like_100[11] = {0.3213528663326579, 0.33423478592970113, 0.35605988875551187, 0.332916605980746, 0.3314512691495212, 0.3295193762640396, 0.30580706950207154, 0.3378309674169654, 0.3309098002505501, 0.3269442260561221, 0.3865983587976605};  // this is ratio_list_like_100
    //double ratio_list_like_100[11] = {0.317756343404869, 0.3252890910953202, 0.35662974625941973, 0.3419085327781718, 0.33143540724892745, 0.3258175311203792, 0.32283686009852586, 0.3206017136247155, 0.3268427667650438, 0.32637997196050883, 0.45322686515801347};  // this is ratio_list_like_200
    //double ratio_list_like_100[11] = {0.3345718846751868, 0.32648480614778796, 0.3667477968901342, 0.35143589341030956, 0.33552795713087263, 0.35064812644298393, 0.36304722725157496, 0.35979385864662533, 0.3598861835357594, 0.3457064332323271, 0.42694244273107473}; //this is ratio_like 500

    //double ratio_list_like_100[11] = {0.6939282484312627, 0.6547269923250258, 0.6572236852078702, 0.6802943068651954, 0.6631078628658905, 0.6584854527127217, 0.6531488851788705, 0.6483216858802185, 0.6488599690088663, 0.6368061931856148, 0.5810235672624275}; //this is ratio_like 100
    //double ratio_list_like_100[11] = {0.6988098955284077, 0.6608769692423105, 0.661682946180854, 0.6401988583215799, 0.6385830824663474, 0.6632432215935893, 0.6739801212385997, 0.6659145613483468, 0.623231786067006, 0.6111165418829247, 0.56614262353052}; //this is ratio_like 200
    //double ratio_list_like_100[11] = {0.6827235876594109, 0.6546561032563273, 0.597801677867714, 0.6149709701590205, 0.626991915673859, 0.6656529708097136, 0.6648978419137221, 0.6607694563547546, 0.6634981659536126, 0.6674192904967401, 0.6085331920090751}; //this is ratio_like 200
    //double ratio_list_like_100[11] = {1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0}; //this is ratio_like 200
    //double ratio_list_like_100[11] = {0.23, 0.57, 0.18, 0.6, 0.35, 0.76, 0.48, 0.28, 0.17, 0.22,0.4}; //this is ratio_like 200
    //double ratio_list_like_100[11] = {0.46, 0.47, 0.49, 0.45, 0.48, 0.40, 0.51, 0.44, 0.39, 0.43, 0.50}; //this is ratio_like 200
    double ratio_list_like_100[11] = {0.64, 0.61, 0.81, 0.58, 0.29, 0.25, 0.6, 0.39, 0.49, 0.76};
    //double ratio_list_like_100[11] = {0.24602356123907565, 0.31433166039953764, 0.28039106057442076, 0.296612504108106, 0.3402596913724023, 0.37706767886926773, 0.4068635343154354, 0.4233897432597644, 0.43889368693783837, 0.45416418321257646, 0.4228166510970859};
    //double ratio_list_like_100[11] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0}; //this is ratio_like 200


    //double ratio_list_comment_100[10] = {0.539,0.534,0.532,0.528,0.529,0.531,0.532,0.535,0.539,0.545}; // this is ratio_list_comment_200

    int filePiece = 546;
    //double seed_ratio[24] = {0.03815288827308658, 0.038658781088945375, 0.039006631384175226, 0.038849252741330484, 0.03903426440717119, 0.03926945315487026, 0.03982432360451349, 0.04030870973782025, 0.04064017270648738, 0.0409995238488661, 0.04136673272738872, 0.0416933047670591, 0.04216214874270481, 0.04253551852701059, 0.04273680769153719, 0.04303485655464194, 0.04344230252494714, 0.04369446176632122, 0.04389095175182407, 0.04410581366116462, 0.04410158067375313, 0.044146326552655005, 0.04417478789384402, 0.04417040521788208};
    double seed_ratio[12] = {0.05671172670751998, 0.08797285272479766, 0.07034811460994941, 0.08022840919860938, 0.08329043932290775, 0.0884038377870173, 0.10746663873818907, 0.08548126161185657, 0.0858406110369326, 0.08166535902475652, 0.0912369954974133, 0.08135375374005048};
    //double seed_ratio_improved[24] = {0.03815288827308658, 0.038658781088945375, 0.039006631384175226, 0.038849252741330484, 0.03903426440717119, 0.03926945315487026, 0.03982432360451349, 0.04030870973782025, 0.04064017270648738, 0.0409995238488661, 0.04136673272738872, 0.0416933047670591, 0.04216214874270481, 0.04253551852701059, 0.04273680769153719, 0.04303485655464194, 0.04344230252494714, 0.04369446176632122, 0.04389095175182407, 0.04410581366116462, 0.04410158067375313, 0.044146326552655005, 0.04417478789384402, 0.04417040521788208};
    //double seed_ratio[24] = {0.03815288827308658, 0.038658781088945375, 0.039006631384175226, 0.038849252741330484, 0.03903426440717119, 0.03926945315487026, 0.03982432360451349, 0.04030870973782025, 0.04064017270648738, 0.0409995238488661, 0.04136673272738872, 0.0416933047670591, 0.04216214874270481, 0.04253551852701059, 0.04273680769153719, 0.04303485655464194, 0.04344230252494714, 0.04369446176632122, 0.04389095175182407, 0.04410581366116462, 0.04410158067375313, 0.044146326552655005, 0.04417478789384402, 0.04417040521788208};
    double scaling_parameter[12] = {1.0,1.0,1.0,1.1,1.1,1.2,1.2,1.3,1.3,1.4,1.4,1.5};
    //double scaling_parameter[15] = {1.3,1.3,1.4,1.4,1.4,1.5,1.5,1.6,1.6,1.7,1.7,1.8,1.8,1.8,1.8};

    //double seed_ratio[13] = {0.075,0.076,0.077,0.078,0.079,0.079,0.08,0.081,0.081,0.081,0.082,0.082,0.082};
    /*year
    double seed_ratio[] = {0.0043, 0.00087,0.00043,0.101,0.1852,0.2252,0.250,0.253};
    */
    //int totalFileNum = 957 - 763;
    //int totalFileNum = 900 - 800;
    //int chunk_fileSize = totalFileNum / filePiece;
    for (int ratio_size_len = 0; ratio_size_len<sizeof(ratio_list_like_100)/sizeof(ratio_list_like_100[0]); ratio_size_len = ratio_size_len + 1){
        double ratio = ratio_list_like_100[ratio_size_len];
        double ratio_counter = ratio_counter_list[ratio_size_len];
        for(int seed_size_len = 0; seed_size_len<sizeof(seed_size)/sizeof(seed_size[0]); seed_size_len = seed_size_len + 1){
            bool firstTime = true;
            list<User*> it_seed;
            list<User*> it_current_select_seeds;
            list<User*> it_total_seeds;

            //cut file into five pieces

            for(int i = 535; i <= filePiece; i++){

                int seed_limit = ceil(seed_size[seed_size_len] * seed_ratio[i-533]);
                if(ratio<0.5){
                    //sed_limit = ceil(seed_size[seed_size_len] * seed_ratio_improved[i-197]);
                    seed_limit = ceil(seed_size[seed_size_len] * seed_ratio[i - 535]);
                }
                else {
                    if (i < 540) {
                        seed_limit = ceil(seed_size[seed_size_len] * seed_ratio[i - 535]);

                    } else {
                        //sed_limit = ceil(seed_size[seed_size_len] * seed_ratio[i - 533]);
                        seed_limit = ceil(seed_size[seed_size_len] * seed_ratio[i - 535]);
                        //sed_limit = ceil(seed_size[seed_size_len] * seed_ratio[i-197]);
                        //cout << "Seed limit:" << seed_limit;
                    }
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
                //oss_first << "../student_preprocess/diffusion/oldNetworkFile/like" << ".csv";
                //oss_first << "../student_preprocess/diffusion/netWorkFileMonth/like_" << 210 << ".csv";

                //oss << "../student_preprocess/diffusion/netWorkFileSeason/comment_" << i << ".csv";
                //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_season/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss << "../student_preprocess/diffusion/netWorkFileSeason/like_" << i << ".csv";
                //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_season/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";

                //oss << "../student_preprocess/diffusion/netWorkFileMonth/like_" << i << ".csv";
                //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_Month/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/pageRank_temporal/pagerank_seed/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/indegree_temporal/indegree_diversity_seed/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";

                //oss_seed << "../student_preprocess/hindex_temporal/diversity_month_hi_index/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/target_hindex_temporal/diversity_month_hi_index/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << ratio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/intensity_temporal/intensity_diversity_seed/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";


                //oss_seed << "../student_preprocess/target_hindex_temporal/diversity_month_hi_index/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";

                //oss << "../student_preprocess/diffusion/netWorkFileMonth/like_" << i << ".csv";
                //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_Month/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";

                oss_first << "../student_preprocess/diffusion/ins_month/comment_557" << ".csv";
                oss << "../student_preprocess/diffusion/ins_month/comment_" << i << ".csv";
                //oss_seed << "../student_preprocess/indegree_temporal_ins/indegree_diversity_seed/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                oss_seed << "../student_preprocess/target_hindex_temporal_ins/diversity_month_hi_index_ins/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";


                std::string var_seed_file = oss_seed.str();
                std::string var = oss.str();
                std::string var_first = oss_first.str();

                string seed_file = var_seed_file;

                string network_first = var_first;
                string network =  var;
                k = ratio;
                Graph* g = read(network, seed_file, k);
                Graph* g_original = read(network_first, seed_file, k);


                //cout << "Finish reading" << endl;


                std::random_device rd;
                std::default_random_engine gen = std::default_random_engine(rd());
                std::uniform_real_distribution<> dis(0, 1);

                double spread_m = 0.0;
                double spread_f = 0.0;

                //tie(spread_m, spread_f) = original_Algorithm(sampling, g, gen, dis, rho);
                //Created by zhiyue zhang

                if(firstTime == true){
                    tie(spread_m, spread_f,it_seed,it_current_select_seeds) = first_original_Algorithm(sampling, g, gen, dis, rho,seed_limit,g_original);
                    it_total_seeds.splice(it_total_seeds.end(),it_current_select_seeds);
                    firstTime = false;

                }
                else{
                    cout << "Start temporal_effect_Algorithm:" << endl;
                    tie(spread_m, spread_f,it_seed,it_current_select_seeds) = temporal_effect_Algorithm(sampling, g, gen, dis, rho,it_seed,seed_limit,g_original, ratio,it_total_seeds);
                    it_total_seeds.splice(it_total_seeds.end(),it_current_select_seeds);
                    //printSeed(it_total_seeds);

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
                //new_ss = new_ss + to_string(ratio_counter) + seed_size_break + to_string(seed_size[seed_size_len]) + txt_ss;
                new_ss = new_ss + to_string(ratio) + seed_size_break + to_string(seed_size[seed_size_len]) + txt_ss;


                fstream ff;
                try{
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

