"""
*****************************************************************************
DESCRIPTION:

Functions used to perform the NLP experiments of the paper.
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



# ************************************************************************
import warnings
import string
import re

from shutil import rmtree
from tempfile import mkdtemp
from datetime import timedelta

import numpy as np
import pandas as pd

from sklearn.metrics import make_scorer, roc_auc_score
from sklearn.metrics import f1_score
from sklearn.model_selection import GridSearchCV, StratifiedKFold
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder
from sklearn.feature_selection import SelectFromModel
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression

from joblib import Memory
from imblearn.pipeline import Pipeline
from imblearn.over_sampling import RandomOverSampler

warnings.filterwarnings('ignore')


# ---------------------------------------------------------------------------
# HELPER FUNCTIONS AND CLASSES
# ---------------------------------------------------------------------------

def nested_train_test_split(df, examples_col_names, labels_col_names,
                            train_frac=0.8, random_state=42):
    """This function perform a nested stratification in training/test set.
    'labels_col_names' is a list of two values represent the category and label
    used in the nested stratification."""

    df = pd.merge(df,
                  df.groupby(labels_col_names).size().to_frame(name = 'count').reset_index(), 
                  on=labels_col_names, 
                  how='left')
    
    train_one_member = None
    if 1 in df['count'].values:
        train_one_member = df[df['count']==1].copy().reset_index(drop=True)
        train_frac = (train_frac*len(df)-len(train_one_member))/(len(df)-len(train_one_member))
        df = df[df['count']>1].copy().reset_index(drop=True)

    # Dropping some columns 
    df.drop(columns =["count"], inplace = True)
    
    labels_list_0 = df[labels_col_names[0]].value_counts().index.tolist()
    train = None
    test = None

    for i in labels_list_0:
        labels = df[df[labels_col_names[0]].astype(str) == i][labels_col_names[1]].copy()
        labels.reset_index(inplace=True, drop=True)
        examples = df[df[labels_col_names[0]].astype(str) == i][examples_col_names].copy()
        examples.reset_index(inplace=True, drop=True)
        
        X_tr, X_te, y_tr, y_te = train_test_split(examples,
                                                  labels,
                                                  train_size=train_frac,
                                                  stratify=labels,
                                                  random_state=random_state)
        
        train_i = pd.concat([y_tr, X_tr], axis=1).reset_index(drop=True)
        train_i = train_i.loc[:,~train_i.columns.duplicated()]
        test_i = pd.concat([y_te, X_te], axis=1).reset_index(drop=True)
        test_i = test_i.loc[:,~test_i.columns.duplicated()]
        if train is None:
            train = train_i
            test = test_i
        else:
            train = pd.concat([train, train_i], axis=0, ignore_index=True)
            test = pd.concat([test, test_i], axis=0, ignore_index=True)
    if  train_one_member is not None:       
        train = pd.concat([train, train_one_member[train.columns]], axis=0, ignore_index=True)
    
    return train, test


def custom_drop_duplicates(df, colum_list=None):
    """ This function drop duplicate rows in the dataframe 'df' using
    the columns in the 'colum_list' """

    init_shape = df.shape

    if colum_list is not None:
        df.drop_duplicates(colum_list, inplace=True, keep=False)
        if len(df):
            df.reset_index(inplace=True, drop=True)
            fin_shape = df.shape
            print('Initial shape: ',
                  init_shape,
                  "\nDuplicated rows: ",
                  init_shape[0] - fin_shape[0], "\nFinal shape: ", fin_shape)
        else:
            print('Return Empty DataFrame')
            return None
    else:
        df.drop_duplicates(inplace=True, keep=False)
        if len(df):
            df.reset_index(inplace=True, drop=True)
            fin_shape = df.shape
            print('Initial shape: ',
                  init_shape, "\nDuplicated rows: ",
                  init_shape[0] - fin_shape[0],
                  "\nFinal shape: ", fin_shape)
        else:
            print('Return Empty DataFrame')
            return None

    return df


class CatStratifiedKFold:
    """CatStratifiedKFold cross-validator
    Provides training/test indices to split data in training/test sets.
    This cross-validation class is a variation of StratifiedKFold from 
    Scikit-learn 0.21.3 that returns stratified folds, but also 
    conserving the category 'stage_grade' in the folds.
    """

    def __init__(self, n_splits=5, random_state=None, shuffle=True):
        self.n_splits = n_splits
        self.random_state = random_state
        self.shuffle = shuffle

    def split(self, X, y):
        categories = X['stage_grade'].value_counts().index.tolist()
        X_idx = [0]*len(categories)
        y_val = [0]*len(categories)
        skf = [0]*len(categories)
        for k, j in enumerate(categories):
            X_idx[k] = X[X['stage_grade'] == j].copy().index
            y_val[k] = y[X['stage_grade'] == j].copy()
            skf[k] = StratifiedKFold(n_splits=self.n_splits,
                                     random_state=self.random_state,
                                     shuffle=self.shuffle).split(X_idx[k],
                                                                 y_val[k])

        for indexes in zip(*skf):
            i_train = []
            i_test = []
            for i, index in enumerate(indexes):
                i_train += X_idx[i][list(index[0])].tolist()
                i_test += X_idx[i][list(index[1])].tolist()
            yield np.array(i_train), np.array(i_test)

    def get_n_splits(self):
        return self.n_splits
# ---------------------------------------------------------------------------


# ---------------------------------------------------------------------------
# FUNCTION TO PRE-PROCESS NOTES
# ---------------------------------------------------------------------------
def combined_notes(disease, period=60, year_survival=5, days_sur_bounds=None,
                   authortype_list=None, idlist=None,
                   added_features_list=None):
    """
    This function chronologically concatenates all the notes of the same id in
    a single text.

    Parameters
    ----------
     disease: 
         Name of the disease in the pickle object name df_Notes_{disease}.pkl 
         Ex. disease = 'breast' refers to the pickle df_Notes_breast.pkl    
     period:
         Number of days after diagnosis considered to select the notes.
     year_survival:
         Threshold to define survival.
     days_sur_bounds:
         List of lower and upper bounds to consider notes around 'year_survival'
         in days [lb,up].
     authortype_list:
         List of authors considered as valid in the authortype feature.
     idlist:
         List of id considered.
     added_features_list:
         Features from the input working data set conserved in the output.

    Return
    ------
    df_Notes: 
        Dataframe with concatenated notes and other information related with
        the id and text.
    """
    # Load all Notes.
    df_Notes = pd.read_pickle(f'df_Notes_{disease}.pkl')

    # Delete Null Notes.
    df_Notes = df_Notes[~df_Notes['deid_notecontent'].isnull()].copy()
    df_Notes.reset_index(inplace=True, drop=True)

    # Delete duplicate notes.
    del_duplicate = False
    if del_duplicate:
        df_Notes = custom_drop_duplicates(
            df_Notes, colum_list=['deid_notecontent'])

    df_Notes['overallsurvival'] = df_Notes['overallsurvival'].astype(float)
    df_Notes['vitalstatusbinary'] = df_Notes['vitalstatusbinary'].astype(int)

    # Select notes by author.
    df_Notes = df_Notes[df_Notes['authortype'].isin(authortype_list)].copy()
    df_Notes.reset_index(inplace=True, drop=True)

    # Computing the note time from diagnostic in years.
    df_Notes['timefromdiagnostic'] = (df_Notes['filingdate'] -
                                      df_Notes['dateofdiagnosis']
                                      )/timedelta(days=365)

    # Select only after 'dateofdiagnosis' and before 'overallsurvival'
    # This query also avoids taking patients with 'overallsurvival' in 
    # the center 'days_sur_bounds'.
    if days_sur_bounds is None:
        days_sur_bounds = [10, 10]

    df_Notes = df_Notes[((df_Notes['timefromdiagnostic'] >= 0) &
                         (df_Notes['timefromdiagnostic'] <=
                          df_Notes['overallsurvival'])) &
                        ((df_Notes['overallsurvival'] <=
                          year_survival -
                          (timedelta(days=days_sur_bounds[0]
                                     )/timedelta(days=365))) |
                         (df_Notes['overallsurvival'] >=
                          year_survival +
                          (timedelta(days=days_sur_bounds[1]
                                     )/timedelta(days=365))))].copy()
    df_Notes.reset_index(inplace=True, drop=True)

    # Select only the notes of the first 'x' years from diagnostic.
    df_Notes = df_Notes[df_Notes['timefromdiagnostic'] <=
                        timedelta(days=period)/timedelta(days=365)].copy()
    df_Notes.reset_index(inplace=True, drop=True)

    # Number of notes by id.
    minimun_number_of_notes = 3
    compute_number_of_notes = False  # True when use quartiles.
    if compute_number_of_notes:
        df_index = (df_Notes['id'].value_counts()).to_frame()[
            'id'].describe().to_frame()
        minimun_number_of_notes = df_index[df_index.index.str.startswith(
            '25%')].iloc[0][0].astype(int)

    # Select only id with more than 'minimun_number_of_notes'.
    cols = ['id']
    df_Notes['id_count'] = df_Notes.groupby(cols)['id'].transform('size')
    df_Notes = df_Notes[df_Notes['id_count']
                        >= minimun_number_of_notes].copy()
    df_Notes.reset_index(inplace=True, drop=True)

    # Order the notes by date.
    df_Notes = df_Notes.sort_values(by=['id', 'filingdate'],
                                    ascending=[True, True], na_position='last',
                                    inplace=False)
    df_Notes.reset_index(inplace=True, drop=True)

    # Concatenate all notes by id.
    if added_features_list is None:
        added_features_list = []

    
    df_Notes = df_Notes.groupby(['id', 'overallsurvival','vitalstatusbinary','stage_grade','id_count']+added_features_list,
                                )['deid_notecontent'].apply(' '.join).reset_index(drop=False, inplace=False)
    
    df_Notes.rename(columns={df_Notes.columns[-1]: 'text'}, inplace=True)
    
    # Add length.
    df_Notes['text_length'] = df_Notes['text'].str.len()
    
    # Computing the label.
    df_Notes['label'] = None
    df_Notes['label'] = np.where(((df_Notes['overallsurvival'] >=
                                   year_survival) &
                                  ((df_Notes['vitalstatusbinary'] == 0) |
                                   (df_Notes['vitalstatusbinary'] == 1))),
                                 1, None)
    df_Notes['label'] = np.where(((df_Notes['overallsurvival'] <
                                   year_survival) &
                                  (df_Notes['vitalstatusbinary'] == 1)),
                                 0, df_Notes['label'])

    # Select non-null notes.
    df_Notes = df_Notes[~df_Notes['label'].isnull()].copy()
    df_Notes['label'] = df_Notes['label'].astype(int)
    df_Notes.reset_index(inplace=True, drop=True)
    

    # This select notes from ids that are in the list 'idlist' only.
    if idlist:
        df_Notes = df_Notes[df_Notes['id'].isin(idlist)].copy()
        df_Notes.reset_index(inplace=True, drop=True)
        print(df_Notes.shape)


    return df_Notes
# ---------------------------------------------------------------------------


# ---------------------------------------------------------------------------
# FUNCTIONS FOR NLP EXPERIMENTS
# ---------------------------------------------------------------------------

re_tok = re.compile(f'([{string.punctuation}“”¨«»®´·º½¾¿¡§£₤‘’])')
def tokenize(s): return re_tok.sub(r' \1 ', s).split()


def lr_cv(disease, year_survival=5, period_of_analysis_days=None,
          kfold=5, random_state=17, authortype_list=None,
          added_features_list=None):
    """This is the main function to obtain the NLP experiment results.
    
    The function lr_cv (logistic regression - cross validation) performs
    n-year survival prediction (year_survival) using text notes and stage/grade,
    independently. Term-frequency inverse document-frequency (tf-idf) is
    applied to the text. 
    Also, the function use the Scikit-learn SelectFromModel Meta-transformer
    for selecting features based on importance weights for each time point.

    Parameters
    ----------
     disease:
         One of the values from ('breast','prostate','lung','glioma').
     year_survival:
         Threshold to define survival.
     period_of_analysis_days:
         List of number of days after diagnosis considered to select the notes.
     kfold:
         Number of folds in the cross validation.
     random_state:
         Seed used by the random number generator.
     authortype_list:
         List of authors considered as valid.
     added_features_list:
         Features from the input dataset conserved in the output.

    Return
    ------
    Dictionary with all results.

    Dictionary keys: 
     val_f1: 
         List of tuples (mean, std) of test sets F1 metric in the grid search,
         best index for each time point.
     val_area_under_curve:
         List of tuples (mean, std) of test sets AUC metric in the grid search,
         best index for each time point.
     tfidf_param_text: 
         List of hyperparameter max_features for tfidfvectorizer in the grid
         search for each time point.
     C_param_text: 
         List of hyperparameter C for logistic regression in the grid search
         for each time point.
     f1_train:
         List of tuples (F1 score, 0) of training set for each time point.
     area_under_curve_train:
         List of tuples (AUC score, 0) of training set for each time point.
     n:
         List of train set size for each time point.
     f1: 
         List of tuples (F1 score, 0) of test set for each time point.
     area_under_curve:
         List of tuples (AUC score, 0) of test set for each time point.
     n_test:
         List of test set size for each time point.
     feature_names:
         List of importants features for each time point.
     predictions:
         List of predictions for the test set for each time point.
     val_f1_s:
         List of tuples (mean, std) of test sets F1 metric in the grid search
         best index for each time point. (stage/grade approach)
     val_area_under_curve_s:
         List of tuples (mean, std) of test sets AUC metric in the grid search
         best index for each time point. (stage/grade approach)
     C_param_s: 
         List of hyperparameter C for logistic regression in the grid search
         for each time point. (stage/grade approach)
     f1_train_s:
         List of F1 score of training set for each time point.
         (stage/grade approach)
     area_under_curve_train_s:
         List of AUC score of training set for each time point.
         (stage/grade approach)
     f1_s:
         List of tuples (F1 score, 0) of test set for each time point.
         (stage/grade approach)
     area_under_curve_s:
         List of tuples (AUC score, 0) of test set for each time point.
         (stage/grade approach)
     predictions_s:
         Lis of predictions for the test set for each time point.
         (stage/grade approach)
     train: 
         List of the complete training sets with added columns with the
         predictions for the two approaches for each time point.
     test: 
         List of the complete test sets with added columns with the
         predictions for the two approaches for each time point.
     random_state:
         Seed used by the random number generator.
    """

    # Initializations:
    val_f1 = []
    val_area_under_curve = []
    tfidf_param_text = []
    C_param_text = []
    f1_train = []
    area_under_curve_train = []
    n = []
    f1 = []
    area_under_curve = []
    n_test = []
    feature_names = []
    predictions = []
    tain_list = []
    val_f1_s = []
    val_area_under_curve_s = []
    C_param_s = []
    f1_train_s = []
    area_under_curve_train_s = []
    f1_s = []
    area_under_curve_s = []
    predictions_s = []
    test_list = []
    id_list_flag = True
    idlist = []
    test_ids = []
    train = None
    test = None
    train_frac = 0.8
    unic_label = False  # Nested stratification is done when value is False.
    ngram = 1
    max_features = 200  # For feature importance.
    examples_col_names = ['id', 'overallsurvival',
                          'vitalstatusbinary',
                          'stage_grade',
                          'id_count'
                          ] + added_features_list + ['text_length', 'text']
    labels_col_names = ['stage_grade', 'label']
    scoring = {'f1': make_scorer(f1_score, average='macro'),
               'auc': make_scorer(roc_auc_score)}

    parameter_grid = {'logisticregression__C': [0.1, 1, 10, 100, 1000],
                      'tfidfvectorizer__max_features': [500, 1000, None]}
    parameter_grid_stage = {'logisticregression__C': [0.1, 1, 10, 100, 1000]}
    if period_of_analysis_days is None:
        period_of_analysis_days = [30, 365]

    # Main loop: Solving the problem at each time point.
    for period in period_of_analysis_days:
        print(f"Period in days: {period}")

        # 1. Define train and test set.

        if id_list_flag:
            id_list_flag = False
            df = combined_notes(
                disease, year_survival=year_survival, period=period,
                authortype_list=authortype_list,
                added_features_list=added_features_list)
            idlist = df['id'].copy().tolist()
            if unic_label:
                examples = df[examples_col_names].copy()
                labels = df['label'].copy()
                X_tr, X_te, y_tr, y_te = train_test_split(examples, labels,
                                                          train_size=train_frac,
                                                          stratify=labels,
                                                          random_state=random_state)
                train = pd.concat([y_tr, X_tr], axis=1).reset_index(drop=True)
                test = pd.concat([y_te, X_te], axis=1).reset_index(drop=True)
            else:
                train, test = nested_train_test_split(df, examples_col_names,
                                                      labels_col_names,
                                                      train_frac=train_frac,
                                                      random_state=random_state)
            test_ids = test['id'].copy().tolist()
            print('text is in df:', df.columns)
        else:
            df = combined_notes(disease, period=period,
                                year_survival=year_survival, idlist=idlist,
                                authortype_list=authortype_list,
                                added_features_list=added_features_list)
            train = df[~df['id'].isin(
                test_ids)].copy().reset_index(drop=True)
            test = df[df['id'].isin(test_ids)].copy().reset_index(drop=True)

        train['is_test'] = False
        test['is_test'] = True

        # 2. NLP.

        # Create a temporary folder to store the transformers of the pipeline.
        cachedir = mkdtemp()
        memory = Memory(location=cachedir, verbose=10)
        pipeline = Pipeline([('tfidfvectorizer',
                              TfidfVectorizer(ngram_range=(1, ngram),
                                              tokenizer=tokenize,
                                              min_df=3,
                                              max_df=0.9,
                                              strip_accents='unicode',
                                              use_idf=1,
                                              smooth_idf=1,
                                              sublinear_tf=1)),
                             ('randomOversampler',
                              RandomOverSampler(random_state=random_state)),
                             ('logisticregression',
                              LogisticRegression(random_state=random_state))],
                            memory=memory)

        if unic_label:
            x_train = train['text'].copy()
            y_train = train['label'].values.copy()
            cross_validation = StratifiedKFold(n_splits=kfold,
                                               shuffle=True,
                                               random_state=random_state)
        else:
            # Nested stratification.
            x_train_2col = train[['stage_grade', 'text']].copy()
            x_train = train['text'].copy()
            y_train = train['label'].values.copy()
            cross_validation = CatStratifiedKFold(n_splits=kfold,
                                                  shuffle=True,
                                                  random_state=random_state
                                                  ).split(x_train_2col,
                                                          y_train)

        x_test = test['text'].copy()
        y_test = test['label'].values.copy()

        grid_search = GridSearchCV(pipeline, param_grid=parameter_grid,
                                   scoring=scoring, refit='f1',
                                   cv=cross_validation)

        # Fit.
        grid_search.fit(x_train, y_train)
        
        # Clear the cache directory when you don't need it anymore.
        rmtree(cachedir)
        
        
        # Record cross validation metrics.
        val_f1.append((grid_search.cv_results_['mean_test_f1'][grid_search.best_index_],
                       grid_search.cv_results_['std_test_f1'][grid_search.best_index_]))

        val_area_under_curve.append((grid_search.cv_results_['mean_test_auc'][grid_search.best_index_],
                                     grid_search.cv_results_['std_test_auc'][grid_search.best_index_]))

        # Record cross validation hyperparameters.
        tfidf_param_text.append(grid_search.best_params_['tfidfvectorizer__max_features'])
        C_param_text.append(grid_search.best_params_['logisticregression__C'])

        # Final model.
        pipeline_final = Pipeline([('tfidfvectorizer',
                                    TfidfVectorizer(ngram_range=(1, ngram),
                                                    tokenizer=tokenize,
                                                    min_df=3,
                                                    max_df=0.9,
                                                    strip_accents='unicode',
                                                    use_idf=1,
                                                    smooth_idf=1,
                                                    sublinear_tf=1,
                                                    max_features=grid_search.best_params_['tfidfvectorizer__max_features'])),
                                   ('randomOversampler',
                                    RandomOverSampler(random_state=random_state)),
                                   ('logisticregression',
                                    LogisticRegression(random_state=random_state,
                                                       C=grid_search.best_params_['logisticregression__C']))])

        final_model = pipeline_final.fit(x_train, y_train)
        preds_train = final_model.predict(x_train)

        # Add predictions in train DF.
        train[str(period)+'_tf_pred'] = preds_train
        train_f1 = f1_score(y_train, preds_train, average='macro')
        f1_train.append((train_f1, 0))  # Record train f1
        train_auc = roc_auc_score(y_train, preds_train)
        area_under_curve_train.append((train_auc, 0))  # Record train auc.
        n.append(len(train))  # Add number of examples in train.
        preds_test = final_model.predict(x_test)

        # Add predictions in test DF.
        test[str(period)+'_tf_pred'] = preds_test
        predictions.append(preds_test)  # Add predictions in list.
        test_f1 = f1_score(y_test, preds_test, average='macro')
        f1.append((test_f1, 0))  # Record test f1.
        test_auc = roc_auc_score(y_test, preds_test)
        area_under_curve.append((test_auc, 0))  # Record test auc.
        n_test.append(len(test))  # Add number of examples in test.

        # Selecting features.
        pip_tfidf_ros = Pipeline([('tfidfvectorizer',
                                   TfidfVectorizer(ngram_range=(1, ngram),
                                                   tokenizer=tokenize,
                                                   min_df=3,
                                                   max_df=0.9,
                                                   strip_accents='unicode',
                                                   use_idf=1,
                                                   smooth_idf=1,
                                                   sublinear_tf=1,
                                                   max_features=grid_search.best_params_['tfidfvectorizer__max_features'])),
                                  ('randomOversampler',
                                   RandomOverSampler(random_state=random_state))])

        X_res, y_res = pip_tfidf_ros.fit_resample(x_train, y_train)
        clf = LogisticRegression(random_state=random_state,
                                 C=grid_search.best_params_['logisticregression__C'])
        sfm = SelectFromModel(clf, threshold=-np.inf,
                              max_features=max_features)
        sfm.fit(X_res, y_res)
        embeded_lr_support = sfm.get_support()
        X_res_pandas = pd.DataFrame(X_res.todense())
        embeded_lr_feature = X_res_pandas.loc[:,
                                              embeded_lr_support].columns.tolist()
        feature_names_list = np.array(pip_tfidf_ros['tfidfvectorizer'].get_feature_names())[
            embeded_lr_feature].tolist()
        feature_names.append(feature_names_list)  # Add importants features.

        # 3. Stage.

        x_train_s = train[['stage_grade']].copy()
        y_train_s = train['label'].values.copy()
        x_test_s = test[['stage_grade']].copy()
        y_test_s = test['label'].values.copy()

        # Create a temporary folder to store the transformers of the pipeline.
        cachedir = mkdtemp()
        memory = Memory(location=cachedir, verbose=10)
        pipeline = Pipeline([('randomOversampler',
                              RandomOverSampler(random_state=random_state)),
                             ('onehotencoder',
                              OneHotEncoder(handle_unknown='ignore')),
                             ('logisticregression',
                              LogisticRegression(random_state=random_state))],
                            memory=memory)

        cross_validation = StratifiedKFold(n_splits=kfold, shuffle=True,
                                           random_state=random_state)
        grid_search = GridSearchCV(pipeline, param_grid=parameter_grid_stage,
                                   scoring=scoring, refit='f1',
                                   cv=cross_validation)


        grid_search.fit(x_train_s, y_train_s)
        
        # Clear the cache directory when you don't need it anymore.
        rmtree(cachedir)
        
        val_f1_s.append((grid_search.cv_results_['mean_test_f1'][grid_search.best_index_],
                         grid_search.cv_results_['std_test_f1'][grid_search.best_index_]))
        val_area_under_curve_s.append((grid_search.cv_results_['mean_test_auc'][grid_search.best_index_],
                                       grid_search.cv_results_['std_test_auc'][grid_search.best_index_]))

        # Final model.
        pipeline_final = Pipeline([('randomOversampler',
                                    RandomOverSampler(random_state=random_state)),
                                   ('onehotencoder',
                                    OneHotEncoder(handle_unknown='ignore')),
                                   ('logisticregression',
                                    LogisticRegression(random_state=random_state,
                                                       C=grid_search.best_params_['logisticregression__C']))])

        C_param_s.append(grid_search.best_params_['logisticregression__C'])
        final_model = pipeline_final.fit(x_train_s, y_train_s)
        preds_train_s = final_model.predict(x_train_s)

        # Fill the output dictionary values
        train[str(period)+'_s_pred'] = preds_train_s
        train_f1_s = f1_score(y_train_s, preds_train_s, average='macro')
        f1_train_s.append(train_f1_s)
        train_auc_s = roc_auc_score(y_train_s, preds_train_s)
        area_under_curve_train_s.append(train_auc_s)
        preds_test_s = final_model.predict(x_test_s)
        test[str(period)+'_s_pred'] = preds_test_s
        predictions_s.append(preds_test_s)
        test_f1_s = f1_score(y_test_s, preds_test_s, average='macro')
        f1_s.append((test_f1_s, 0))
        test_auc_s = roc_auc_score(y_test_s, preds_test_s)
        area_under_curve_s.append((test_auc_s, 0))
        tain_list.append(train)
        test_list.append(test)

    return dict(val_f1=val_f1,
                val_area_under_curve=val_area_under_curve,
                tfidf_param_text=tfidf_param_text,
                C_param_text=C_param_text,
                f1_train=f1_train,
                area_under_curve_train=area_under_curve_train,
                n=n,
                f1=f1,
                area_under_curve=area_under_curve,
                n_test=n_test,
                feature_names=feature_names,
                predictions=predictions,
                val_f1_s=val_f1_s,
                val_area_under_curve_s=val_area_under_curve_s,
                C_param_s=C_param_s,
                f1_train_s=f1_train_s,
                area_under_curve_train_s=area_under_curve_train_s,
                f1_s=f1_s,
                area_under_curve_s=area_under_curve_s,
                predictions_s=predictions_s,
                train=tain_list,
                test=test_list,
                random_state=random_state)
# ---------------------------------------------------------------------------

# ***************************************************************************