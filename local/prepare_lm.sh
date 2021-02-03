#!/bin/bash

. ./path.sh || die "path.sh expected";

cd data
#convert to FST format for Kaldi
arpa2fst --disambig-symbol=#0 --read-symbol-table=lang/words.txt \
  local/sanskrit.lm lang/G.fst

cp -r lang lang_test

set +e
fstisstochastic lang_test/G.fst
set -e

# Everything below is only for diagnostic.
# Checking that G has no cycles with empty words on them (e.g. <s>, </s>);
# this might cause determinization failure of CLG.
# #0 is treated as an empty word.

# mkdir -p lang_test/tmpdir.g
# awk '{if(NF==1){ printf("0 0 %s %s\n", $1,$1); }}
#      END{print "0 0 #0 #0"; print "0";}' \
#      < "$lexicon" > lang_test/tmpdir.g/select_empty.fst.txt

# fstcompile --isymbols=lang_test/words.txt --osymbols=lang_test/words.txt \
#   lang_test/tmpdir.g/select_empty.fst.txt \
#   | fstarcsort --sort_type=olabel \
#   | fstcompose - lang_test/G.fst > lang_test/tmpdir.g/empty_words.fst

# fstinfo lang_test/tmpdir.g/empty_words.fst | grep cyclic | grep -w 'y' \
#   && echo "Language model has cycles with empty words" && exit 1

# rm -r $out_dir/tmpdir.g


echo "Succeeded in formatting LM: '$lm'"
