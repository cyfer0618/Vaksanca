#!/usr/bin/env bash

# Copyright 2017 QCRI (author: Ahmed Ali)
#           2019 Dongji Gao
# Apache 2.0
# This script prepares the subword dictionary.

set -e
dir=data/local/dict
#lexicon_url1="http://alt.qcri.org/resources/speech/dictionary/ar-ar_grapheme_lexicon_2016-02-09.bz2";
#lexicon_url2="http://alt.qcri.org/resources/speech/dictionary/ar-ar_lexicon_2014-03-17.txt.bz2";
num_merges=32000
stage=0
. ./cmd.sh
. ./path.sh
. ./utils/parse_options.sh || exit 1;
mkdir -p $dir data/local/lexicon_data
mkdir -p data/lang

# if [ $stage -le 0 ]; then
#   echo "$0: Downloading text for lexicon... $(date)."
#   wget -P data/local/lexicon_data $lexicon_url1
#   wget -P data/local/lexicon_data $lexicon_url2
#   bzcat data/local/lexicon_data/ar-ar_grapheme_lexicon_2016-02-09.bz2  | sed '1,3d' | awk '{print $1}'  >  data/local/lexicon_data/grapheme_lexicon
#   bzcat data/local/lexicon_data/ar-ar_lexicon_2014-03-17.txt.bz2 | sed '1,3d' | awk '{print $1}' >>  data/local/lexicon_data/grapheme_lexicon
#   cat data/train/text | cut -d ' ' -f 2- | tr -s " " "\n" | sort -u >> data/local/lexicon_data/grapheme_lexicon
# fi


# if [ $stage -le 0 ]; then
#   echo "$0: processing lexicon text and creating lexicon... $(date)."
#   # remove vowels and  rare alef wasla
#   grep -v "[0-9]" data/local/lexicon_data/grapheme_lexicon |  sed -e 's:[FNKaui\~o\`]::g' -e 's:{:}:g' | sort -u > data/local/lexicon_data/processed_lexicon
#   local/prepare_lexicon.py
# fi

# cut -d' ' -f2- $dir/lexicon.txt | sed 's/SIL//g' | tr ' ' '\n' | sort -u | sed '/^$/d' >$dir/nonsilence_phones.txt || exit 1;

# echo UNK >> $dir/nonsilence_phones.txt

# echo SIL > $dir/silence_phones.txt

# echo SIL >$dir/optional_silence.txt

# echo -n "" >$dir/extra_questions.txt

cp corpus/lang/lexicon.txt data/local/dict/.

cp corpus/lang/nonsilence_phones.txt data/local/dict/.

cp corpus/lang/optional_silence.txt data/local/dict/.

touch data/local/dict/extra_questions.txt

echo "SIL" > data/local/dict/silence_phones.txt
echo "SPN" >> data/local/dict/silence_phones.txt
echo "LAU" >>  data/local/dict/silence_phones.txt
echo "MUS" >>  data/local/dict/silence_phones.txt
echo "ऽ" >>  data/local/dict/silence_phones.txt

echo "<UNK>" > data/lang/oov.txt

# Make a subword lexicon based on current word lexicon
glossaries="<UNK> <sil>"
if [ $stage -le 0 ]; then
  echo "$0: making subword lexicon... $(date)."
  # get pair_code file
  cp corpus/data/train/clean_text.txt data/train/clean_text.txt
  utils/lang/bpe/learn_bpe.py -s $num_merges -i data/train/clean_text.txt > data/local/pair_code.txt
  #mv $dir/lexicon.txt $dir/lexicon_word.txt
  cat corpus/lang/lexicon.txt | sed '1,4d' > data/local/dict/lexicon_word.txt

  # get words
  cut -f1 -d$'\t' $dir/lexicon_word.txt > $dir/words.txt
  utils/lang/bpe/apply_bpe.py -c data/local/pair_code.txt --glossaries $glossaries < $dir/words.txt | \
  sed 's/ /\n/g' | sort -u > $dir/subwords.txt
  #sed 's/./& /g' $dir/subwords.txt | sed 's/@ @ //g' | sed 's/*/V/g' | paste -d ' ' $dir/subwords.txt - > $dir/lexicon.txt
  #rm data/local/dict/lexicon.txt
  echo "sed -i '1i<UNK> SPN' corpus/lexicon.txt"
  #echo "run this command first : sed 's/./& /g' data/local/dict/subwords.txt | sed 's/@ @ //g' | sed 's/*/V/g' | paste -d ' ' data/local/dict/subwords.txt - > corpus/lexicon.txt"
  #echo '<sil> SIL' >> $dir/lexicon.txt

  sed 's/./& /g' data/local/dict/subwords.txt | sed 's/@ @ //g' | sed 's/*/V/g' | paste -d ' ' data/local/dict/subwords.txt - > data/local/dict/lexicon.txt

fi

sed -i '1i<UNK> SPN' $dir/lexicon.txt

echo '<sil> SIL' >> $dir/lexicon.txt

#exit 1;
rm data/local/dict/lexicon.txt
cp corpus/lexicon.txt data/local/dict/.
sed -i '1i<UNK> SPN' data/local/dict/lexicon.txt

echo '<sil> SIL' >> data/local/dict/lexicon.txt

echo "$0: Dictionary preparation succeeded"
