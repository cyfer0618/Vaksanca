Vāksañcayaḥ - Sanskrit speech corpus has more than 78 hours of data and contains recordings of 45,953 sentences with a sampling rate of 22 KHz. The content is mainly readings of various texts spanning many Śāstras of Saṃskṛt literature and also includes contemporary stories, radio program, extempore discourse, etc.
The summary datasheet associated with this corpus can be accessed here - [Link](https://drive.google.com/file/d/1Kmi8MTIEvRqBkAyQ17v7nN8susaczS3L/view). Please download the corpus from [https://www.cse.iitb.ac.in/~asr/](https://www.cse.iitb.ac.in/~asr/).


## Environments
- python version: 3.7.3
- Model files
	- List of the speakers used in the train, validation, test and out-of-domain-test split are given in the README file of corpus. 
	- [SRILM LM link](https://drive.google.com/file/d/1maOUwH4HzdCEWL2mcAmv1ixsGad3Meej/view?usp=sharing)
- Results for different model
	- In-domain test data WER : 21.94 for the best performing model (SLP1 as the script and BPE splits as the LM unit).
	- Out-of-domain test data WER for different speakers can be refered on the [paper](https://arxiv.org/abs/2106.05852).

## Recipe
This [Kaldi](http://kaldi-asr.org/) recipe is based on subword - Vowel Split and Byte Pair Encoding. For word based we used [Wall Street Journal recipe](https://github.com/kaldi-asr/kaldi/tree/master/egs/wsj/s5)

 
## Training

Download the vowel splitter (This requires the text to be in SLP1 format)

- [Sanskrit](https://drive.google.com/file/d/1iWLknjdlrtN4J6S9Hf1QBapOZYyujiYH/view?usp=sharing)
- [Gujarati](https://drive.google.com/file/d/1GrLt4FHS7Idsmh3f5f2er_4thfbbIJYo/view?usp=sharing)
- [Telugu](https://drive.google.com/file/d/1-seAKZyC_Uh1JVAkynPz3cFEOccwuP96/view?usp=sharing)

Download the pre-trained model 
	
- [Model (SLP word based)](https://drive.google.com/file/d/1DP4VxjtrZhMJ7AVHj43HSKT_CZxrezpZ/view?usp=sharing)
- [Model (SLP BPE based)](https://drive.google.com/file/d/1Hc3Gvfm7GfAeH8cMpSsztU2dZV441LnL/view?usp=sharing)
- [Model (SLP vowel split based)](https://drive.google.com/file/d/1D7i0gz6FMXaAoUDn0LoMpG8BwDNbvc7H/view?usp=sharing)
- [Model (Devnagari word based)](https://drive.google.com/file/d/1SYZYZRmEGhNAFfBDRY8CUpb9jQA3Q3qK/view?usp=sharing)
- [Model (Devnagari BPE based)](https://drive.google.com/file/d/1LOzNMShuMmfZG9wxl1efzzWDQleplS9e/view?usp=sharing)
- [Model (Devnagari vowel split based)](https://drive.google.com/file/d/1p2D0MiD57oL4bZ5TpwiPf-2d6JpNMGZS/view?usp=sharing)

Download the processed dataset

- Convert the audio files for testing from .mp3 files to .wav files before testing using the script given with the corpus.
- We used our best performing model(SLP1 as the script and BPE splits as the LM unit) for testing Out-of-domain data.
- [In-domain test data link (test.zip)](https://drive.google.com/file/d/11UvmFgHZGJ2XoFhMZzOhHgpVRO8uT4RT/view?usp=sharing)
- [Out-of-domain test data link (truetest.zip)](https://drive.google.com/file/d/1lYBMKXW1elwElQVvWa1dGUMrB6cLduMR/view?usp=sharing)

## Evaluate
From pre-trained model (SLP vowel split)
```
./decode.sh test
# | WER : 18.12
./decode.sh truetest
# | WER : 34.88

``` 

## Publications
Devaraja Adiga and Rishabh Kumar and Amrith Krishna and Preethi Jyothi and Ganesh Ramakrishnan and Pawan Goyal[Devaraja Adiga and Rishabh Kumar and Amrith Krishna and Preethi Jyothi and Ganesh Ramakrishnan and Pawan Goyal](https://arxiv.org/abs/2106.05852), In ACL 2021.

