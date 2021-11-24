#for k in 30
# do
# 	# for the agnostic
# 	./Diffusion_test.exe  ${1} agnostic-${2}-${k}.csv ${k} >> tmp &
# 	# # # for the parity
# 	# ./Diffusion_test.exe  ${1} parity-${2}-${k}.csv ${k} >> tmp &
	
# done
for ratio in 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
 #for ratio in 0.0
do
	# for k in 1 2 5 10 20 30
	# for k in 30
	for seed_size in 100 200
	do
		# # for the agnostic
		# ./Diffusion_test.exe ${1} agnostic-${2}-${k}-${ratio}.csv ${k} >> tmp &
		# for the diversity train
		    time ./diffusion_zhiyue_copy.exe  ../student_preprocess/diffusion/networkFile/comment_${fileNum}.c sv ../student_preprocess/diffusion/diversity_seed/diversity-${1}-${seed_size}-${ratio}.csv ${seed_size} 1.0 10000
		# # for the diversity test
		# ./Diffusion_test.exe  ${1} diversity-${2}-${k}-${ratio}.csv 10000 >> tmp &
	done
done
