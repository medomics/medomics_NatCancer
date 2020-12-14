"""
*****************************************************************************
DESCRIPTION:

This script is used to reproduce the NLP experiments of the following paper:
"MEDomics: Towards Self-Cognizant Hospitals in the Treatment of Cancer"

Results are saved in a pickle object with the following name:
  --> {disease}{starting point}.pickle  (Ex: breast30.pickle),
where "disease" is one of the options below (breast, prostate, lung or glioma)
and "starting point" is one of the options below (20, 30 or 60) days.

All calculations are repeated for each random seed values defined
in random_state_list.
-----------------------------------------------------------------------------
INSTRUCTIONS:

Please configure the values of the following variables below:
  --> 'cancer_type_index'
  --> 'start_index'
-----------------------------------------------------------------------------
REQUIREMENTS:

Running this script requires a file of the following format:
  --> df_Notes_{disease}.pkl (Ex. df_Notes_breast.pkl)

The file df_Notes_{disease}.pkl must contain a panda dataframe,
where each row is associated with a single patient note.

The dataframe must have the following mandatory columns:
  --> 'id': Unique identifier for a patient.
  --> 'deid_notecontent': De-identified note.
  --> 'overallsurvival': Survival time from the date of diagnosis in years.
  --> 'vitalstatusbinary': Vital status (0 if alive and 1 if dead).
  --> 'authortype': Author of the note or source.
  --> 'filingdate': Note date.
  --> 'dateofdiagnosis': Date of diagnosis.
  --> 'stage_grade': Stage or grade.

The dataframe may contain additional columns, for example:
  --> 'AGE': Age at diagnosis.

If present, these columns will also be saved in the output file 
{disease}{starting point}.pickle
-----------------------------------------------------------------------------
AUTHORS: 

  --> Jorge Barrios <Jorge.BarriosGinart@ucsf.edu>
  --> Taman Upadhaya <tamanupadhaya@gmail.com>
  --> Olivier Morin <olivier.morin@ucsf.edu>
  --> Martin Vallières <martin.vallieres@usherbrooke.ca>
-----------------------------------------------------------------------------
STATEMENT:

 This file is part of <https://github.com/medomics>, a package providing 
 research utility tools for developing precision medicine applications.
 --> Copyright (C) 2020  MEDomics consortium

     This package is free software: you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
     the Free Software Foundation, either version 3 of the License, or
     (at your option) any later version.

     This package is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     GNU General Public License for more details.
 
     You should have received a copy of the GNU General Public License
     along with this package.  If not, see <http://www.gnu.org/licenses/>.
*****************************************************************************
"""



# ***************************************************************************
import pickle
import time
from survivalnlp import lr_cv


# ---------------------------------------------------------------------------
# PARAMETERS OPTIONS
# ---------------------------------------------------------------------------
# OPTION 1: Used to set the index of the cancer type for the experiment.
#           This index is assigned to the "cancer_type_index" variable.
#           --> Choose one option from the following list:
#                   0 --> breast
#                   1 --> prostate
#                   2 --> lung
#                   3 --> glioma
cancer_type_index = 0 # ASSIGN THE CHOSEN VALUE FOR OPTION 1 HERE

# OPTION 2: Used to set the start index of the time series for the 
#           experiment.
#           This index is assigned to the "start_index" variable.
#           --> Choose one option from the following list:
#                   0 --> 20 days
#                   1 --> 30 days
#                   2 --> 60 days
start_index = 1 # ASSIGN THE CHOSEN VALUE FOR OPTION 2 HERE 
# ---------------------------------------------------------------------------


# ---------------------------------------------------------------------------
# INITIALIZATIONS
# ---------------------------------------------------------------------------

# List of cancer types and time points
cancer_type = ['breast', 'prostate', 'lung', 'glioma']
period_points = [20, 30, 60, 120, 180, 240, 300, 365]

if start_index == 0:
    period_points = period_points[:1] + period_points[2:]
else:
    period_points = period_points[start_index:]
    
# Threshold to define survival (in years):
survival_thr_list = [5, 5, 2, 1.17] 
cancer_year_survival = survival_thr_list[cancer_type_index] 

# List of random seeds.
random_state_list = [3, 23, 59, 101, 139, 181, 233, 277, 331, 383, 433,
                     479, 547, 599, 643, 701, 757, 821, 877, 937, 997]

# List of authortype valid values
# --> Note: It is required that the values in authortype_list belong to 
# the values stored in the column authortype
authortype_list = ['Physician',
                   'Imaging-Narrative',
                   'Imaging-Impression',
                   'Pathology-Impression']

# List of additional columns
added_features_list = ['AGE'] 

# ---------------------------------------------------------------------------


# ---------------------------------------------------------------------------
# COMPUTATIONS
# ---------------------------------------------------------------------------
start = time.time()

# NLP calculations
results_list = []
for random_state_value in random_state_list:
    results_list.append(lr_cv(cancer_type[cancer_type_index],
                              year_survival=cancer_year_survival,
                              period_of_analysis_days=period_points,
                              random_state=random_state_value,
                              authortype_list=authortype_list,
                              added_features_list=added_features_list))

# Saving results
with open(cancer_type[cancer_type_index]+str(period_points[0])+'.pickle', \
 'wb') as f:
    pickle.dump(results_list, f, pickle.HIGHEST_PROTOCOL)

print('---DONE!---')
print('Execution Time: ', time.time() - start)
# ---------------------------------------------------------------------------

# ***************************************************************************
# Execution Time:  about 18 hours