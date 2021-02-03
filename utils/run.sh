#!/bin/bash

# This script prepares data and trains + decodes an ASR system.

# initialization PATH
. ./path.sh  || die "path.sh expected";
# initialization commands
. ./cmd.sh

[ ! -L "steps" ] && ln -s ../../wsj/s5/steps

[ ! -L "utils" ] && ln -s ../../wsj/s5/utils

###############################################################
#                   Configuring the ASR pipeline
###############################################################
stage=0  # from which stage should this script start
nj=4    # number of parallel jobs to run during training
test_nj=2    # number of parallel jobs to run during decoding
# the above two parameters are bounded by the number of speakers in each set
###############################################################

# Stage 1: Prepares the train/dev data. Prepares the dictionary and the
# language model.
if [ $stage -le 1 ]; then
  echo "Preparing data and training language models"
  local/prepare_data.sh train test
  local/prepare_dict.sh
  utils/prepare_lang.sh data/local/dict "<UNK>" data/local/lang data/lang
  local/prepare_lm.sh
  echo "DONE Preparing data and training language models"
fi

# Feature extraction
# Stage 2: MFCC feature extraction + mean-variance normalization
if [ $stage -le 2 ]; then
   for x in train test; do
      steps/make_mfcc.sh --nj 40 --cmd "$train_cmd" data/$x exp/make_mfcc/$x mfcc
      steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x mfcc
   done
   echo "DONE MFCC feature extraction"
fi

# Stage 3: Training and decoding monophone acoustic models
if [ $stage -le 3 ]; then
  ### Monophone
    echo "Monophone training"
	steps/train_mono.sh --nj "$nj" --cmd "$train_cmd" data/train data/lang exp/mono
    echo "Monophone training done"
    (
    echo "Decoding the test set"
    utils/mkgraph.sh data/lang exp/mono exp/mono/graph
  
    # This decode command will need to be modified when you 
    # want to use tied-state triphone models 
    steps/decode.sh --nj $test_nj --cmd "$decode_cmd" \
      exp/mono/graph data/test exp/mono/decode_test
    echo "Monophone decoding done."
    ) &
fi

# Stage 4: Training tied-state triphone acoustic models
if [ $stage -le 4 ]; then
  ### Triphone
    echo "Triphone training"
    steps/align_si.sh --nj $nj --cmd "$train_cmd" \
       data/train data/lang exp/mono exp/mono_ali
	# steps/train_deltas.sh --boost-silence 1.25  --cmd "$train_cmd"  \
	#    5200 100000 data/train data/lang exp/mono_ali exp/tri1
    steps/train_deltas.sh --boost-silence 1.25  --cmd "$train_cmd"  \
	   5200 100000 data/train data/lang exp/mono_ali exp/tri
    echo "Triphone training done"
    (
    echo "Decoding the test set"
    utils/mkgraph.sh data/lang exp/tri exp/tri/graph
  
    # This decode command will need to be modified when you 
    # want to use tied-state triphone models 
    steps/decode.sh --nj $test_nj --cmd "$decode_cmd" \
      exp/tri/graph data/test exp/tri/decode_test
    echo "Triphone decoding done."
    ) &
fi



#stage 5: taken from line #203 - #213 https://github.com/kaldi-asr/kaldi/blob/master/egs/wsj/s5/run.sh#L176
if [ $stage -le 5 ]; then
  echo "Stage 5 started"
  # From 2b system, train 3b which is LDA + MLLT + SAT.

  # Align tri2b system with all the si284 data.
  if $train; then
    steps/align_si.sh  --nj $nj --cmd "$train_cmd" \
      data/train data/lang exp/tri exp/tri2b_ali_si284

    steps/train_sat.sh --cmd "$train_cmd" 5200 100000 \
      data/train data/lang exp/tri2b_ali_si284 exp/tri3b
  fi  
fi

#stage 6: line #325 of https://github.com/kaldi-asr/kaldi/blob/master/egs/wsj/s5/run.sh#L176
if [ $stage -le 6 ]; then
  echo "stage 6 started"
  # Caution: this part needs a GPU.
  local/chain/tuning/run_tdnn_1i.sh
  echo "stage 6 ended"
fi

wait;
#score
# Computing the best WERs
for x in exp/*/decode*; do [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh; done
for x in exp/*/*/decode*; do [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh; done
