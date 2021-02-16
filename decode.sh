#!/bin/bash
echo -e "Stage 0"
echo -e "Download exp.zip, sp023.zip, sp007.zip, test.zip and truetest.zip (Manually)"
echo -e "exp.zip Link : https://drive.google.com/file/d/1FkL3DPcqXTk2Ht6AgF2fPu3Rc5rlk8es/view?usp=sharing"
echo -e "sp023.zip Link : https://drive.google.com/file/d/1TyDxGJ9Qo9gKNrTx-yJPwEXYhWpaubaH/view?usp=sharing"
echo -e "truetest.zip Link : https://drive.google.com/file/d/1lYBMKXW1elwElQVvWa1dGUMrB6cLduMR/view?usp=sharing"
echo -e "sp007.7z Link : https://drive.google.com/file/d/12buT7lB_Te_Tqfn3D-6fj43BgyZuWHCc/view?usp=sharing"
echo -e "test.zip Link : https://drive.google.com/file/d/11UvmFgHZGJ2XoFhMZzOhHgpVRO8uT4RT/view?usp=sharing"
echo -e "unzip exp.zip"
echo -e "unzip sp023.zip and place at corpus/data/wav/"
echo -e "unzip truetest.zip and place at corpus/data/"
echo -e "unzip sp007.zip and place at corpus/data/wav/"
echo -e "unzip test.zip and place at corpus/data/"

if [ $method = "truetest" ] ; then
	if [ ! -d corpus/data/truetest ] || [ ! -d corpus/data/wav/sp023 ] || [ ! -d exp ] ; then
		echo "Please download exp.zip, sp023.zip and truetest.zip"
    	exit 1;
	fi
fi
if [ $method = "test" ] ; then
	if [ ! -d corpus/data/test ] || [ ! -d corpus/data/wav/sp007 ] || [ ! -d exp ] ; then
		echo "Please download exp.zip, sp007.zip and test.zip"
    	exit 1;
	fi
fi

method = $1 # test or truetest
echo -e "Stage 1"

if [ $stage -le 0 ] && [ $method = "test" ]; then
	cp -r corpus/data/test data/truetest
if
if [ $stage -le 0 ] && [ $method = "truetest" ]; then
	cp -r corpus/data/truetest data/truetest
if
utils/copy_data_dir.sh data/truetest data/truetest_hires
echo -e "Stage 2"
steps/make_mfcc.sh --nj 1 --mfcc-config conf/mfcc_hires.conf --cmd run.pl data/truetest_hires
steps/compute_cmvn_stats.sh data/truetest_hires
echo -e "Stage 3"
steps/online/nnet2/extract_ivectors_online.sh --cmd run.pl --nj 1  data/truetest_hires exp/nnet3/extractor  exp/nnet3/ivectors_truetest_hires
echo -e "Stage 4"
local/chain/tuning/run_tdnn_.sh --gmm tri3b_subword
echo -e "Finish"