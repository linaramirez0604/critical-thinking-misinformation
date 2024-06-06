# critical-thinking-misinformation

Replication Instructions

Critical Thinking and Misinformation Vulnerability: Experimental Evidence from Colombia

John A. List, Lina M. Ramirez, Julia Seither, Jaime Unda,
Beatriz Vallejo

This document describes the replication files that produce the tables in the paper Toward an Understanding of the Economics of Misinformation: Evidence from a Demand Side Field Experiment on Critical Thinking. 

The replication package contains the following files: 

Round_1.csv
This file includes the raw data from the experiment as described in the paper. 

Round_3(1).csv & Round_3(2).csv
These files include the raw data from the third wave of the experiment as described in the paper. 

dip_first_round.dta
This file contains the cleaned data and represents the output of the cleaning.do file. 

dip_third_round.dta
This file contains the cleaned data for the third wave of the experiment.

dip_first_round_imputation.dta
This file contains the data from the third wave of the experiment that are needed for the imputation.

Master.do
This file sets the work directory and runs the cleaning.do and the analysis.do files. Running the Master.do file should only take a few seconds. The entire analysis of the paper is done with Stata 18. 

cleaning.do 
This file cleans the raw data from the Eval_04_27_2022.csv file. The cleaned data will be saved in dip_first_round.dta

analysis.do
This file contains the code for reproducing all tables and analyses presented in the paper.

appendix.do
This file contains the code for reproducing all tables and analyses presented in the appendix of the paper.

simulations_randomization.R
This file simulates the randomization procedure.


Replication procedure 

To replicate the paper, open the Master.do file and add your individual directory for the data and the code. Afterwards, running the Master.do file will open the cleaning.do file to clean the raw data and produce the tables in the analysis.do file. Lastly, all tables in the appendix will be produced in the appendix.do file. 


