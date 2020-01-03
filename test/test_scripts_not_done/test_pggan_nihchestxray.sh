#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
path_apphub=${DIR}'/../../apphub/'
path_temp=$(dirname $(mktemp -u))'/'

# example specific section
filepath=${path_apphub}'image_generation/pggan_nihchestxray/' 
fname='pggan_nihchestxray_128' 
fname_para=$fname'_param'

path_stderr_dir='stderr/'${fname}'/'
mkdir $path_stderr_dir

#training parameters to test the models
train_info=" "
nb_train_info=" "

# # copy the model file to working directory
# cp "${filepath}/classifier.h5" "${filepath}/feature_extractor.h5" "./"


if ! fastestimator train ${filepath}${fname}'.py' ${train_info} 2>> ${path_stderr_dir}'run_py.txt'; then
    exit 1
fi

#inject a parameter cell
papermill --prepare-only ${filepath}${fname}'.ipynb'  ${path_temp}${fname_para}'.ipynb' ${nb_train_info} 2>> ${path_stderr_dir}'run_papermill.txt'
jupyter nbconvert --to script  ${path_temp}${fname_para}'.ipynb' --output ${fname_para} 2>> ${path_stderr_dir}'run_convert.txt'

if ! ipython  ${path_temp}${fname_para}'.py' 2>> ${path_stderr_dir}'run_ipy.txt'; then
    exit 1
fi

rm -rf ${path_temp}/tmp*
rm  ${path_temp}${fname_para}'.ipynb'
rm  ${path_temp}${fname_para}'.py'

exit 0