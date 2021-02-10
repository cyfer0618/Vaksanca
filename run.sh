#!/bin/bash -e


# This is an example script for subword implementation

num_jobs=12
num_decode_jobs=5
decode_gmm=true
stage=0
overwrite=false
num_merges=32000

. ./cmd.sh ## You'll want to change cmd.sh to something that will work on your system.
           ## This relates to the queue.
. ./path.sh
. ./utils/parse_options.sh  # e.g. this parses the above options
                            # if supplied.

if [ $# -lt 1 ]; then
  printf "$help_message\n";
  exit 1;
fi

method = $1 # BPE or VS

echo "Stage 0"

if [ $stage -le 0 ] && [ $method = "VS" ]; then

  if [ -f data/train/text ] && ! $overwrite; then
    echo "$0: Not processing, probably script have run from wrong stage"
    echo "Exiting with status 1 to avoid data corruption"
    exit 1;
  fi

  echo "$0: Preparing data..."
  # For vowel split use vowel_splitter_Sanskrit.py file to create the data/train/text,
  # data/test/text and language model data.

  local/prepare_data.sh train test
  
  echo "$0: Preparing lexicon and LM..." 
  local/prepare_dict.sh
  
  utils/subword/prepare_lang_subword.sh data/local/dict "<UNK>" data/local/lang data/lang
  cp corpus/LM/sanskrit.lm data/local/

  local/prepare_lm.sh
  
fi

echo "Stage 1"

mfccdir=mfcc
if [ $stage -le 1 ]; then
  echo "$0: Preparing the test and train feature files..."
  for x in train test ; do
    steps/make_mfcc.sh --cmd "$train_cmd" --nj $num_jobs \
      data/$x exp/make_mfcc/$x $mfccdir
    utils/fix_data_dir.sh data/$x # some files fail to get mfcc for many reasons
    steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfccdir
  done
fi

echo "Stage 2"

if [ $stage -le 2 ]; then
  echo "$0: creating sub-set and training monophone system"
  utils/subset_data_dir.sh data/train 10000 data/train.10K || exit 1;

  steps/train_mono.sh --nj $num_jobs --cmd "$train_cmd" \
    data/train.10K data/lang exp/mono_subword || exit 1;

fi

echo "Stage 3"

if [ $stage -le 3 ]; then
  echo "Decoding the test set"
  utils/mkgraph.sh data/lang exp/mono_subword exp/mono_subword/graph
  
  # This decode command will need to be modified when you 
  # want to use tied-state triphone models 
  steps/decode.sh --nj $num_decode_jobs --cmd "$decode_cmd" \
    exp/mono_subword/graph data/test exp/mono_subword/decode_test
  echo "Monophone decoding done."
fi


echo "Stage 4"

if [ $stage -le 4 ]; then
  echo "$0: Aligning data using monophone system"
  steps/align_si.sh --nj $num_jobs --cmd "$train_cmd" \
    data/train data/lang exp/mono_subword exp/mono_ali_subword || exit 1;

  echo "$0: training triphone system with delta features"
  steps/train_deltas.sh --cmd "$train_cmd" \
    2500 30000 data/train data/lang exp/mono_ali_subword exp/tri1_subword || exit 1;
fi

echo "Stage 5"

if [ $stage -le 5 ] && $decode_gmm; then
  utils/mkgraph.sh data/lang_test exp/tri1_subword exp/tri1_subword/graph
  steps/decode.sh  --nj $num_decode_jobs --cmd "$decode_cmd" \
    exp/tri1_subword/graph data/test exp/tri1_subword/decode
fi

echo "Stage 6"

if [ $stage -le 6 ]; then
  echo "$0: Aligning data and retraining and realigning with lda_mllt"
  steps/align_si.sh --nj $num_jobs --cmd "$train_cmd" \
    data/train data/lang exp/tri1_subword exp/tri1_ali_subword || exit 1;

  steps/train_lda_mllt.sh --cmd "$train_cmd" 4000 50000 \
    data/train data/lang exp/tri1_ali_subword exp/tri2b_subword || exit 1;
fi

echo "Stage 7"

if [ $stage -le 7 ] && $decode_gmm; then
  utils/mkgraph.sh data/lang_test exp/tri2b_subword exp/tri2b_subword/graph
  steps/decode.sh --nj $num_decode_jobs --cmd "$decode_cmd" \
    exp/tri2b_subword/graph data/test exp/tri2b_subword/decode
fi

echo "Stage 8"

if [ $stage -le 8 ]; then
  echo "$0: Aligning data and retraining and realigning with sat_basis"
  steps/align_si.sh --nj $num_jobs --cmd "$train_cmd" \
    data/train data/lang exp/tri2b_subword exp/tri2b_ali_subword || exit 1;

  steps/train_sat_basis.sh --cmd "$train_cmd" \
    5000 100000 data/train data/lang exp/tri2b_ali_subword exp/tri3b_subword || exit 1;

  steps/align_fmllr.sh --nj $num_jobs --cmd "$train_cmd" \
    data/train data/lang exp/tri3b_subword exp/tri3b_ali_subword || exit 1;
fi

echo "Stage 9"

if [ $stage -le 9 ] && $decode_gmm; then
  utils/mkgraph.sh data/lang_test exp/tri3b_subword exp/tri3b_subword/graph
  steps/decode_fmllr.sh --nj $num_decode_jobs --cmd \
    "$decode_cmd" exp/tri3b_subword/graph data/test exp/tri3b_subword/decode
fi

echo "Stage 10"

if [ $stage -le 10 ]; then
  echo "$0: Training a regular chain model using the e2e alignments..."
  local/chain/run_tdnn.sh --gmm tri3b_subword
fi

echo "$0: training succeed"
exit 0
