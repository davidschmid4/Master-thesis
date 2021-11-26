# Master-thesis
Basic scripts and some results from my master thesis calculations.

*The data used and most of the end results are too big to be uploaded.*

In my master thesis I use the mTRF toolbox in matlab to build and compare two different backward models and their respective stimulus reconstruction correlations.
The data consists of MEG data of participants that listened to a single speaker and the speech envelopes of said speaker.
My task was to train a backward model on part of the data and reconstruct the speech envelopes on new data with just the MEG data as input. 
One backward model was trained with data within the subjects and tested on holdout data of the same subject. 
The other backward model was trained across 70% of the subjects and tested on the remaining 30%.

I als try to integrate Multiway Canonical Correlation Analysis (MCCA) as a preprocessing step to denoise the data.


mTRF toolbox:
https://github.com/mickcrosse/mTRF-Toolbox
https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5127806/

MCCA:
https://pubmed.ncbi.nlm.nih.gov/30496819/
