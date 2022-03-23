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
    //string fileName= "intensityc";
    //string fileName= "pagerankc";
    //string fileName = "hindexl";
    //string fileName = "hindexc";
    //string fileName = "indegreec";
    //string fileName = "pagerankc";

    //fb sensitivity analysis
    string fileName = "comment";
    //string fileName = "like";


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
    //int seed_size[4] = {75,125,150,175};
    //int seed_size[10] = {50,75,100,125,150,175,200};
    int seed_size[2] = {100,200};

    //int seed_size[1] = {100};
    //int filePiece = 220; //by month
    int filePiece = 111; //by two months
    //int filePiece = 479; //by two weeks
    //int filePiece = 957; //by one week

    //double influenced_ratio[11] = {0.3213528663326579, 0.33423478592970113, 0.35605988875551187, 0.332916605980746, 0.3314512691495212, 0.3295193762640396, 0.30580706950207154, 0.3378309674169654, 0.3309098002505501, 0.3269442260561221, 0.3865983587976605};
    //double seed_ratio[24] = {0.03815288827308658, 0.038658781088945375, 0.039006631384175226, 0.038849252741330484, 0.03903426440717119, 0.03926945315487026, 0.03982432360451349, 0.04030870973782025, 0.04064017270648738, 0.0409995238488661, 0.04136673272738872, 0.0416933047670591, 0.04216214874270481, 0.04253551852701059, 0.04273680769153719, 0.04303485655464194, 0.04344230252494714, 0.04369446176632122, 0.04389095175182407, 0.04410581366116462, 0.04410158067375313, 0.044146326552655005, 0.04417478789384402, 0.04417040521788208};
    double seed_ratio[12] = {0.10652123692916102,0.10671845124163609,0.10725048814549754,0.09858340077175048,0.09256480610957955,0.08803041950649984,0.08375602087965854,0.08038565359128069,0.07810542413224734,0.07890794887110879,0.07917614982158036}; // by like
    //double seed_ratio[12] = {0.08830779436742564,0.08557610924802123,0.08649968864252765,0.08837438629113312,0.08986030397660402,0.09114273814572171,0.09247054684551716,0.09369697687003824,0.09447611764237858,0.09472217370534156,0.09487316426529116}; // by comment

    //double seed_ratio[48] = {0.020623996232321955,0.020660744339095042,0.020640255373669904,0.020329626303232675,0.02022464925772744,0.02010820166706479,0.01992581683396076,0.019947474703051797,0.02002431251747397,0.020138643256465853,0.020262439379786234,0.020401956100493907,0.020549180155504176,0.02061654168217647,0.020675372654055228,0.020741228580272903,0.020795785860708245,0.02087440246964499,0.020936194112079486,0.02101997370612452,0.021118731747144414,0.021186544173236933,0.021280872961566704,0.021338468811646527,0.021484891999963656,0.021553284769294277,0.021601547058434933,0.02164682738075835,0.02168780120758291,0.021739914767818346,0.021811810002173377,0.021895458210905636,0.021962890580519603,0.022025421738317688,0.022077879425159954,0.022132935465833652,0.022117349501784716,0.02215666463890392,0.022175634401684005,0.02216628530032348,0.022177540839224893,0.02217935714890163,0.022170262652690502,0.02219148353309877,0.022204624928427712,0.022211347756125006,0.022207373813567934}; // by two week comment
    //double seed_ratio[48] = {0.02501590124902694,0.02494402633885938,0.02497074324339084,0.024930973489510518,0.02491560037087653,0.024919855552744615,0.024997151672935623,0.025094552957477045,0.02517266840669128,0.025095722442065982,0.0251803272322456,0.02458368696235367,0.02423745945862381,0.02388968302408382,0.02331865223850132,0.022787363101059967,0.02247355530416775,0.02212962674455131,0.021775126570815612,0.021496938030354042,0.02119508861320466,0.020811412685345327,0.0208040447428455,0.02063970250532372,0.020432491854493123,0.02017517763442194,0.019921053167958242,0.019690981327370523,0.019549258252835367,0.01914917302217793,0.01900497107207389,0.018939615048750368,0.018785419020531477,0.01877760642062537,0.01859829600367784,0.018305904147540974,0.01829673281404952,0.018372997541758047,0.018419492479804726,0.018454777063596228,0.018485104395771782,0.018510260863446506,0.018518149552663305,0.01854352073967173,0.01855523859533803,0.018566234156239904,0.01856768188814829}; // by two week like
    //double seed_ratio[96] = {0.010133131261469934,0.010171757928950788,0.010211637532424588,0.010219902395802885,0.010229832762007746,0.010198668331309349,0.010219687982791421,0.01008370284675283,0.010065885032160155,0.010017301141852035,0.010013907349181126,0.010056633990999929,0.009956250211642105,0.009942549660825986,0.009865945316989772,0.00985451039616538,0.009876668859914766,0.009890985710257934,0.00991471385860583,0.009929712096879333,0.009971322871342612,0.01001937357385069,0.01003261851574765,0.010052143018182538,0.01010169795920422,0.010135524760716927,0.01017459356434707,0.010199421381575426,0.010207946532717487,0.010236404047570513,0.010237075735115439,0.010263411550121955,0.010269683229818282,0.010288819269374756,0.010296696383151168,0.010309180073647116,0.010335622123121587,0.010344091130670073,0.010366217253568994,0.010395183085660937,0.010407699361952067,0.010419502828766955,0.010456597805636202,0.010475895446064929,0.010490174029547902,0.010515812319941312,0.010536879400536431,0.0105652657650195,0.010565397052390218,0.010620032027536612,0.010637896121367604,0.010654044142157358,0.010671759692829507,0.010685631204092948,0.010695655983230159,0.010711399097433918,0.010718075801082581,0.010721929620983681,0.010738363327473471,0.010755075400127148,0.010764166512348688,0.010791965961225815,0.010799764272611636,0.010813853040348853,0.010841181327686166,0.010855125315086592,0.01087456937279116,0.010887093694439558,0.010905530662287345,0.010917887461087718,0.010931504235875522,0.01094436837839501,0.01095876434225826,0.010968393716643578,0.010951047204722507,0.010964003002973557,0.010970513457784069,0.010977116909005097,0.010979906028428686,0.010983214740433943,0.01097527697238775,0.010974894063587749,0.010980849970084144,0.010981026820761302,0.01098174928638817,0.010975079750472285,0.01097724629396119,0.01098132882697577,0.010987753469021111,0.010990077564725156,0.010994260217968215,0.010997444011524691,0.010997588917162321,0.010996335759985522,0.010995621283901039}; // by comment
    //double seed_ratio[96] = {0.012289321750253508,0.01230632678210753,0.012337025657438992,0.012366242556551141,0.01230157929865951,0.012294758758001843,0.012314755203593394,0.012287563321779956,0.012295142059572436,0.012238920983603766,0.012287560539437121,0.012292360841234593,0.012289659056190965,0.012334071662758109,0.012327778978736392,0.01232902508740176,0.012375814111850026,0.012393773691622015,0.012414338100716373,0.012363436292739461,0.012376390863462386,0.012414183580914187,0.012418115183397832,0.012273921947580433,0.012123871684247296,0.012027763548450547,0.011953123584696333,0.011854100169772439,0.011781611603046705,0.011577643912611348,0.011499997865336863,0.011369590599689647,0.011237983410815174,0.01111062083064541,0.011083223652083123,0.010966963571132297,0.010913609316701937,0.010797405242164295,0.01073878140642973,0.010688624131474062,0.010601587901901742,0.010562581159097622,0.010452725625584606,0.010329658432703231,0.010263509186047938,0.010294512517810054,0.010259875557390772,0.01024367942303054,0.010178827332075062,0.01013012992327147,0.010076637805088065,0.010037048112158074,0.00994973883377214,0.009865493971406888,0.009824412944781117,0.009751924616785534,0.009710949025487171,0.009679724694560993,0.009641055832778026,0.00951186981060567,0.009443746860910564,0.00942389673677231,0.009372631167713006,0.009366405830517932,0.009340399711065329,0.009287210828455447,0.009264355264875908,0.009263070967790887,0.009260502345705286,0.009245182251712525,0.009172072303049346,0.009093620116080104,0.00902787418700798,0.008999654755127692,0.009023351184799471,0.009046018807655869,0.00906096245825037,0.009070625752276797,0.00908389224350626,0.009093256015163887,0.009101293448092672,0.009110809804700897,0.009116249898050115,0.009124958381268445,0.009128656246478826,0.009127408520795736,0.009132546690412965,0.009136442709623367,0.009145058931405882,0.00914927683887504,0.009150837795199996,0.009154937673184763,0.009156260446801236,0.009156634860529197,0.009156974420905992}; // by like

    //double seed_ratio_improved[24] = {0.98, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01};
    //double scaling_parameter[15] = {1.2,1.2,1.3,1.3,1.3,1.4,1.4,1.5,1.5,1.6,1.6,1.7,1.7,1.7,1.7};
    //double scaling_parameter[15] = {1.3,1.3,1.4,1.4,1.4,1.5,1.5,1.6,1.6,1.7,1.7,1.9,1.9,1.9,1.9};
    //double scaling_parameter[15] = {1.1,1.1,1.2,1.2,1.2,1.3,1.3,1.5,1.5,1.6,1.6,1.7,1.7,1.7,1.7};

    //double scaling_parameter[15] = {1.1,1.1,1.2,1.2,1.2,1.3,1.3,1.4,1.4,1.5,1.5,1.6,1.6,1.6,1.6};
    //double scaling_parameter[15] = {1.0,1.0,1.1,1.1,1.1,1.2,1.2,1.3,1.3,1.4,1.4,1.5,1.5,1.5,1.5};
    //double scaling_parameter[6] = {1.2,1.3,1.4,1.5,1.5,1.5};
    double scaling_parameter[6] = {1.0,1.0,1.0,1.0,1.0,1.0};
    //double scaling_parameter[24] = {1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0};
    //double scaling_parameter[24] = {1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0};

    //double scaling_parameter[24] = {1.0,1.0,1.1,1.1,1.1,1.1,1.1,1.1,1.1,1.1,1.1,1.1,1.1,1.1,1.2,1.2,1.3,1.3,1.4,1.4,1.5,1.5,1.5,1.5};
    //double scaling_parameter[48] = {1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0};
    //double scaling_parameter[48] = {1.0,1.0,1.1,1.1,1.1,1.1,1.1,1.1,1.1,1.1,1.1,1.1,1.1,1.1,1.2,1.2,1.3,1.3,1.2,1.2,1.2,1.2,1.2,1.2,1.2,1.2,1.3,1.3,1.3,1.3,1.3,1.3,1.4,1.4,1.4,1.4,1.4,1.4,1.4,1.4,1.4,1.4,1.4,1.4,1.5,1.5,1.5,1.5};
    //double scaling_parameter[12] = {1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0};

    //double ratio_list[11] = {0.23, 0.57, 0.18, 0.6, 0.35, 0.76, 0.48, 0.28, 0.17, 0.22,0.4};
    //double ratio_list[11] = {0.0, 0.1, 0.2, 0.3, 0.35, 0.76, 0.48, 0.28, 0.17, 0.22,0.4};
    double ratio_list[11] = {0.0, 0.1 , 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9,1.0};

    //double seed_ratio[24] = {0.036603221,0.037142637,0.037450875,0.037836172,0.038760885,0.039300301,0.039916776,0.040302073,0.04068737,0.041149726,0.041457964,0.041843261,0.042459736,0.042767974,0.042999152,0.04330739,0.043846806,0.044077984,0.044386222,0.044694459,0.044694459,0.044771519,0.044771519,0.044771519};
    /*year
    double seed_ratio[] = {0.0043, 0.00087,0.00043,0.101,0.1852,0.2252,0.250,0.253};
    */
    //int totalFileNum = 957 - 763;
    //int totalFileNum = 900 - 800;
    //int chunk_fileSize = totalFileNum / filePiece;

    //for (double ratio = 1.0; ratio<=1.0; ratio = ratio + 0.1){
    for (int ratio_size_len = 0; ratio_size_len<sizeof(ratio_list)/sizeof(ratio_list[0]); ratio_size_len = ratio_size_len + 1){
        double ratio = ratio_list[ratio_size_len];
        //for (int influenced_ratio = 0; influenced_ratio<sizeof(seed_size)/sizeof(seed_size[0]); influenced_ratio = influenced_ratio + 1){
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

            // i = 197 by month
            // i = 100 by two month
            // i = 862 by per week
            // i = 432 by per two week
            //for(int i = 432; i <= filePiece; i++){
            //for(int i = 862; i <= filePiece; i++){
            for(int i = 100; i <= filePiece; i++){
            //for(int i = 197; i <= filePiece; i++){
                int seed_limit = ceil(seed_size[seed_size_len] * seed_ratio[i - 100]);
                if(ratio<0.5){
                    //seed_limit = ceil(seed_size[seed_size_len] * seed_ratio_improved[i-197]);
                    seed_limit = ceil(seed_size[seed_size_len] * seed_ratio[i - 100]);
                }
                else {
                    if (i < 105) {
                        seed_limit = ceil(seed_size[seed_size_len] * seed_ratio[i - 100]);

                    } else {
                        seed_limit = ceil(seed_size[seed_size_len] * seed_ratio[i - 100]);
                        //seed_limit = ceil(seed_size[seed_size_len] * seed_ratio[i - 432]) * scaling_parameter[i - 910];
                        //seed_limit = ceil(seed_size[seed_size_len] * seed_ratio[i-197]);
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
                //oss_ratio << influenced_ratio;
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


                oss_first << "../student_preprocess/diffusion/old_data/comment" << ".csv";
                //oss_first << "../student_preprocess/diffusion/old_data/like" << ".csv";

                //oss << "../student_preprocess/diffusion/netWorkFileMonth/comment_" << i << ".csv";
                oss << "../student_preprocess/diffusion/fbnetWorkFileTwoMonth/comment_" << i << ".csv";
                //oss << "../student_preprocess/diffusion/fbnetWorkFileTwoMonth/like_" << i << ".csv";
                //oss << "../student_preprocess/diffusion/netWorkFileTwoWeek/comment_" << i << ".csv";
                //oss << "../student_preprocess/diffusion/netWorkFileOneWeek/like_" << i << ".csv";



                //oss << "../student_preprocess/diffusion/netWorkFileOneWeek/comment_" << i << ".csv";


                //oss << "../student_preprocess/diffusion/netWorkFileSeason/comment_" << i << ".csv";
                //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_season/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss << "../student_preprocess/diffusion/netWorkFileSeason/like_" << i << ".csv";
                //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_season/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";

                //oss << "../student_preprocess/diffusion/netWorkFileMonth/like_" << i << ".csv";
                //oss_seed << "../student_preprocess/indegree_temporal/indegree_diversity_seed_10/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/diffusion/diversity_seed/intensity/diversity_Month/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/hindex_temporal/diversity_month_hi_index/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/target_hindex_temporal/diversity_month_hi_index/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/pageRank_temporal/pagerank_seed/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/intensity_temporal/intensity_diversity_seed/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";

                //oss_seed << "../student_preprocess/indegree_temporal/indegree_diversity_seed/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";


                //oss_seed << "../student_preprocess/target_hindex_temporal/diversity_two_month_hi_index/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/target_hindex_temporal/diversity_two_week_hi_index/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/target_hindex_temporal/diversity_month_hi_index/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/target_hindex_temporal/diversity_one_week_hi_index/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";


                // for sensitivity analysis
                //oss_seed << "../student_preprocess/indegree_temporal/indegree_diversity_seed_oneweek/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/indegree_temporal/indegree_diversity_seed_twomonth/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/indegree_temporal/indegree_diversity_seed_twoweek/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/indegree_temporal/indegree_diversity_seed/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";

                //oss_seed << "../student_preprocess/pagerank_temporal/pagerank_seed/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/pagerank_temporal/pagerank_twoweek_seed_100/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                oss_seed << "../student_preprocess/pagerank_temporal/pagerank_twomonth_seed_100/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/pagerank_temporal/pagerank_oneweek_seed_100/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";

                //oss_seed << "../student_preprocess/intensity_temporal/intensity_diversity_seed_oneweek/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/intensity_temporal/intensity_diversity_seed_twomonth/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/intensity_temporal/intensity_diversity_seed_twoweek/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";
                //oss_seed << "../student_preprocess/intensity_temporal/intensity_diversity_seed/diversity-" << fileName << "-" << seed_size[seed_size_len] << "-" << strRatio << "-" << i << ".csv";


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

