Vaksancayah introduces free Sanskrit speech corpus and aims to make Sanskrit speech recognition more broadly accessible to everyone.

We are using 56 hours transcribed Sanskrit audio for training data (34,309 utterances, 12 people) and 10 hours transcribed Sanskrit audio for testing data (5531 utterances, 5 people).

The sample dataset can be downloaded from Anonymous google drive link : http://bit.ly/39JJkrx .
The dataset contains 5 speakers, each with 100 utterances. The full dataset will be released upon acceptance.


## Environments
- python version: 3.7.3
- Model files (SLP vowel split)
	- model link: https://drive.google.com/file/d/1FkL3DPcqXTk2Ht6AgF2fPu3Rc5rlk8es/view?usp=sharing
	- LM link: https://drive.google.com/file/d/1maOUwH4HzdCEWL2mcAmv1ixsGad3Meej/view?usp=sharing
	- In-domain test data link (test.zip) : https://drive.google.com/file/d/11UvmFgHZGJ2XoFhMZzOhHgpVRO8uT4RT/view?usp=sharing
	- Out-of-domain truetest data link (truetest.zip) : https://drive.google.com/file/d/1lYBMKXW1elwElQVvWa1dGUMrB6cLduMR/view?usp=sharin
- Result
	- In-domain sample data WER : 22.59
	- Out-domain sample data WER : 34.88

## Recipe
This [Kaldi](http://kaldi-asr.org/) recipe is based on subword - Vowel Split and Byte Pair Encoding. For word based we used [Wall Street Journal recipe](https://github.com/kaldi-asr/kaldi/tree/master/egs/wsj/s5)

 
## Training

Download the pre-trained model and processed dataset
	
- Model (SLP vowel split) : https://drive.google.com/file/d/1FkL3DPcqXTk2Ht6AgF2fPu3Rc5rlk8es/view?usp=sharing
- In-domain test data link (test.zip) : https://drive.google.com/file/d/11UvmFgHZGJ2XoFhMZzOhHgpVRO8uT4RT/view?usp=sharing
- Out-of-domain test data link (truetest.zip) : https://drive.google.com/file/d/1lYBMKXW1elwElQVvWa1dGUMrB6cLduMR/view?usp=sharing
- Audio files for testing (convert these .mp3 files to .wav files before testing)
	* In-domain test audio files link : https://drive.google.com/file/d/12buT7lB_Te_Tqfn3D-6fj43BgyZuWHCc/view?usp=sharing
	* Out-of-domain test audio files link : https://drive.google.com/file/d/1TyDxGJ9Qo9gKNrTx-yJPwEXYhWpaubaH/view?usp=sharing

## Evaluate
From pre-trained model (SLP vowel split)
```
./decode.sh test
# | WER : 18.12
./decode.sh truetest
# | WER : 34.88

``` 
