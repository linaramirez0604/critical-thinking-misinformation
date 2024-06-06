**********************************

/* Outline
1. Setting the work directory
2. Cleaning the raw data 
3. Main tables
4. Appendix tables
*/

********************************************************************************
********************************************************************************

clear all 


************************************************
** 1. WORK DIRECTORY                             **
************************************************

* Set directory for data and code 
	* This must be modified by the user 
	global dir <<insert directory here>>
	
	
* Set directory for output  
	global dir_output <<insert directory here>>


*********************************
** 2. CLEANING OF THE RAW DATA **
*********************************
 	
do "./code/cleaning.do"
	
	
********************
** 3. MAIN TABLES **
********************
	
do "./code/analysis.do"

	
************************
** 4. APPENDIX TABLES **
************************

do "./code/appendix.do"
