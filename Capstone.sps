* Encoding: UTF-8.
COMMENT TRANSFORMATIONS********************.
COMMENT Recode binary variables.
RECODE ethnic ('0'=0) ('1'=0) ('6'=0) (ELSE=1) INTO minority.
RECODE SEX ('M'=1) ('F'=0) INTO male.
RECODE Hispanic FirstGen Athlete ('Y'='1') (ELSE='0').
RECODE PellEligible ('Y'=1) (MISSING=0) (ELSE=0) INTO PellElig.
RECODE Res_hall ('BRH'=1) ('CLBR'=1) ('CRST'=1) ('GRHN'=1) ('WLKS'=1) (ELSE=0) INTO OnCampus.
RECODE PellEligible ('Y'='Y') (ELSE='N').
RECODE AGE (Lowest thru 19=0) (20 thru Highest=1) INTO nontraditional.
RECODE region ('International'=1) (ELSE=0) INTO International.
RECODE region ('Pueblo'=1) (ELSE=0) INTO Pueblo.
RECODE region ('Colorado'=1) (ELSE=0) INTO Colorado.
RECODE region ('US'=1) (ELSE=0) INTO US.
RECODE HighSchoolGPA (756=SYSMIS) (973=SYSMIS).
RECODE MAJOR1_Name ('Undecided'=1) (ELSE=0) INTO Undeclared.
alter type male minority Hispanic nontraditional FirstGen Athlete OnCampus International Pueblo Colorado US Undeclared (f1.0).
EXECUTE.

COMMENT DISTRIBUTIONS********************************.
COMMENT Dichotomous variable distributions.
FREQUENCIES VARIABLES=male minority Hispanic nontraditional FirstGen Athlete pueblo colorado us OnCampus stem_major1 
  undeclared PellElig retain1yr
  /ORDER=ANALYSIS.

COMMENT Continuous variables.
FREQUENCIES VARIABLES= HS_GPA ACT_with_SAT_scores Total_Aid Total_Tuition_Fees COA EFC Original_Need 
     Unmet_Packaged_Need Need_Based_Aid curatt termGPA GenEdsPassed GenEdsFailed curearn creditsnotearned 
  /FORMAT=NOTABLE
  /STATISTICS=STDDEV MINIMUM MAXIMUM MEAN MEDIAN SKEWNESS SESKEW KURTOSIS SEKURT
  /HISTOGRAM NORMAL
  /ORDER=ANALYSIS.

CORRELATIONS
  /VARIABLES=Retain1yr Total_Aid Total_Tuition_Fees COA EFC Original_Need Unmet_Packaged_Need Need_Based_Aid PellElig
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

CORRELATIONS
  /VARIABLES=Retain1yr termGPA curearn creditsnotearned GenEdsPassed GenEdsFailed
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.


COMMENT Missing data.
MULTIPLE IMPUTATION  male minority Hispanic nontraditional FirstGen Athlete OnCampus  
    Pueblo Colorado US STEM_Major1 Undeclared PellElig HighSchoolGPA ACT_with_SAT_scores 
    Total_Aid COA UnMet_Packaged_Need CurATT termGPA 
   /IMPUTE METHOD=NONE
   /MISSINGSUMMARIES  OVERALL VARIABLES (MAXVARS=25 MINPCTMISSING=.01) PATTERNS.

RECODE Total_Aid (SYSMIS=0).
USE ALL.
COMPUTE filter_$=(Missing(Unmet_Packaged_Need)).
VARIABLE LABELS filter_$ 'Missing(Unmet_Packaged_Need) (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
FREQUENCIES VARIABLES=male minority Hispanic nontraditional FirstGen international retain1yr
  /ORDER=ANALYSIS.
FILTER OFF.
USE ALL.
EXECUTE.
RECODE Unmet_Packaged_Need (SYSMIS=0).
EXECUTE.

RMV /nontraditional1=SMEAN(nontraditional) /HighSchoolGPA1=SMEAN(HighSchoolGPA) /ACT_with_SAT_scores1=SMEAN(ACT_with_SAT_scores) /COA1=SMEAN(COA).
execute. 

COMMENT Transform continuous variables.
COMPUTE HS_GPA=(HighSchoolGPA1) / 100.
COMPUTE Total_Aid_K=(Total_Aid)/5000.
COMPUTE COA_K=(COA1)/5000.
COMPUTE Unmet_Need_K = (Unmet_Packaged_Need)/5000.
execute. 

COMMENT Descriptive analyses.
FREQUENCIES VARIABLES= HS_GPA ACT_with_SAT_scores Total_Aid_K COA_K  
     Unmet_Need_K curatt termGPA GenEdsPassed GenEdsFailed
  /FORMAT=NOTABLE
  /STATISTICS=STDDEV MINIMUM MAXIMUM MEAN MEDIAN SKEWNESS SESKEW KURTOSIS SEKURT
  /HISTOGRAM NORMAL
  /ORDER=ANALYSIS.

CROSSTABS
  /TABLES=male minority Hispanic nontraditional FirstGen Athlete pueblo colorado us OnCampus stem_major1 undeclared
  PellElig BY Retain1yr
  /FORMAT=AVALUE TABLES
  /STATISTICS=CHISQ CORR 
  /CELLS=COUNT ROW 
  /COUNT ROUND CELL.

T-TEST GROUPS=Retain1yr(0 1)
  /MISSING=ANALYSIS
  /VARIABLES=HS_GPA ACT_with_SAT_scores Total_Aid_K COA_K  
     Unmet_Need_K curatt termGPA GenEdsPassed GenEdsFailed
  /CRITERIA=CI(.95).

COMMENT Hypothesis 1.
LOGISTIC REGRESSION VARIABLES Retain1yr
  /METHOD=BSTEP(COND) male minority Hispanic nontraditional1 FirstGen Athlete OnCampus  
    Pueblo Colorado US STEM_Major1 Undeclared PellElig HS_GPA ACT_with_SAT_scores1 
    Total_Aid_K COA_K UnMet_Need_K CurATT 
  /SAVE=PRED PGROUP
  /CRITERIA=PIN(.01) POUT(.05) ITERATE(20) CUT(.5).

COMMENT Hypothesis 2.
LOGISTIC REGRESSION VARIABLES Retain1yr
  /METHOD=BSTEP(COND) male minority Hispanic nontraditional1 FirstGen Athlete OnCampus  
    Pueblo Colorado US STEM_Major1 Undeclared PellElig HS_GPA ACT_with_SAT_scores1 
    Total_Aid_K COA_K UnMet_Need_K CurATT termGPA
  /SAVE=PRED PGROUP
  /CRITERIA=PIN(.01) POUT(.05) ITERATE(20) CUT(.5).

