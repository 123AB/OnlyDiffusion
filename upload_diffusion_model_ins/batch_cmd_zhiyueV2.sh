for ratio in 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
do
	for  seed_size in 10
	do
	    for fileNum in {1..957}
	    do

		    time ./diffusion_zhiyue.exe  ../student_preprocess/diffusion/networkFile/comment_${fileNum}.csv ../student_preprocess/diffusion/diversity_seed/diversity-${1}-${seed_size}-${ratio}.csv ${seed_size} 1.0 10000  >> tmp &

	    done
	done
done
