Vaksancayah introduces free Sanskrit speech corpus and aims to make Sanskrit speech recognition more broadly accessible to everyone.

We are using 56 hours transcribed Sanskrit audio for training data (34,309 utterances, 12 people) and 10 hours transcribed Sanskrit audio for testing data (5531 utterances, 5 people).

The database can be also downloaded from Anonymous google drive: http://bit.ly/39JJkrx .
The dataset contains 5 speakers, each with 100 utterances. The full dataset will be released upon acceptance.


## Environments
- python version: 3.7.3
- Model files (SLP only)
	- model link: https://drive.google.com/file/d/1FkL3DPcqXTk2Ht6AgF2fPu3Rc5rlk8es/view?usp=sharing
	- dict link: 
	- LM link: 
	- In-domain test data link (test.zip) : https://drive.google.com/file/d/11UvmFgHZGJ2XoFhMZzOhHgpVRO8uT4RT/view?usp=sharing
	- Out-of-domain truetest data link (truetest.zip) :
- Result
	- In-domain sample data WER :
	- Out-domain sample data WER :

## recipe
This recipe is based on subword - Vowel Split and Byte Pair Encoding.

 
## Training
First download and prepare the dataset 
	- Training data : https://drive.google.com/drive/folders/1DAy2ss75I4Kee3xim4cf4Raz1VWu3g_W?usp=sharing
	- Test data : https://drive.google.com/drive/folders/1V8ieL35B3Kthd48i0SATpTFW4msr8OY4?usp=sharing
	- Out-of-domain data : https://drive.google.com/drive/folders/1q2735rccliINy7hRVnLejrDsFwrU47X8?usp=sharing
Or
Download the model and processed dataset
	- Model : https://drive.google.com/file/d/1FkL3DPcqXTk2Ht6AgF2fPu3Rc5rlk8es/view?usp=sharing
	- In-domain test data link (test.zip) : https://drive.google.com/file/d/11UvmFgHZGJ2XoFhMZzOhHgpVRO8uT4RT/view?usp=sharing
	- Out-of-domain truetest data link (truetest.zip) : https://drive.google.com/file/d/1lYBMKXW1elwElQVvWa1dGUMrB6cLduMR/view?usp=sharing
	- Wav files
		sp007 link : https://drive.google.com/file/d/12buT7lB_Te_Tqfn3D-6fj43BgyZuWHCc/view?usp=sharing
		sp023 link : https://drive.google.com/file/d/1TyDxGJ9Qo9gKNrTx-yJPwEXYhWpaubaH/view?usp=sharing

### Evaluate
```
./decode.sh test
# | WER : 
./decode.sh truetest
# | WER : 

``` 
