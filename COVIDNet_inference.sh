input_path=$1
COVIDNet_model=$2
output_txt=$3


		if [ $# -lt 1 ]; then							# usage dello script							
			    echo $0: "usage: COVIDNet_inference.sh <input_path> [<COVIDNet_model>] [<output_txt>]"
			    exit 1;		    
		fi   

str_index() {    
                
                ############# ############# ############# ############# ############# ############# 
                ############  Trova il primo indice di una sottostringa in una stringa  ########### 
                ############# ############# ############# ############# ############# #############   

		if [ $# -lt 2 ]; then							# usage dello script							
			    echo $0: "usage: str_index <string> <substrin> "
			    return 1;		    
		fi       

                x="${1%%$2*}";   
                [[ $x = $1 ]] && echo -1 || echo ${#x}; 
                };

fbasename () {
                ############# ############# ############# ############# ############# ############# 
                #############   Rimuone directory ed estenzione dal nome di un file   ############# 
                ############# ############# ############# ############# ############# #############
                  
                echo ` basename $1 | cut -d '.' -f 1 `
		
		};

SCRIPT=`realpath -s $0`
dir_script=`dirname $SCRIPT`


COVIDNet_DIR=${dir_script} #"/home/gamorosino/local/COVID-Net"
COVIDNET_models=${COVIDNet_DIR}"/models/"
[ -z ${COVIDNet_model} ] && { COVIDNet_model="COVIDNet-CXR3-B"; }
weightspath=${COVIDNET_models}"/"${COVIDNet_model}
model_v=( $( ls ${weightspath}"/model-"* )  )
model_str=${model_v[0]}
sind=$( str_index ${model_v[0]} "." )
ckptname=$( basename ${model_str:0:${sind}} )
[ -z ${output_txt} ] && { output_txt=$( dirname ${input_path} )'/'$( fbasename ${input_path} )"_"${COVIDNet_model}".txt"; }

( [ "${COVIDNet_model}" ==  "COVIDNet-CXR-Large"  ] || [  "${COVIDNet_model}" ==  "COVIDNet-CXR-Small" ] ) && { ocommands=" --out_tensor dense_3/Softmax:0 --input_size 224 " ; }


printf "" > ${output_txt}

if [ -d ${input_path} ]; then
	temp_txt=${input_path}"/COVIDNet_inference"$( date +%s )".txt"
	for i in $( ls ${input_path} ); do  printf "Image: "${i} ; echo "Image: "${i} >> ${temp_txt} ; python ${COVIDNet_DIR}"/inference.py"     --weightspath ${weightspath}     --metaname "model.meta"     --ckptname $ckptname    --imagepath ${input_path}"/"${i} ${ocommands} 1>> ${temp_txt} 2>> /dev/null  ; cat ${temp_txt} | grep "Image" >> ${output_txt};  cat ${temp_txt} | grep "Normal" >> ${output_txt}; prediction=$( cat ${temp_txt} | grep   "Prediction" ) ; echo ${prediction} >> ${output_txt} ; echo " - "${prediction}  ;rm ${temp_txt}; done

else
	temp_txt=$( dirname ${input_path} )"/COVIDNet_inference"$( date +%s )".txt"
	python ${COVIDNet_DIR}"/inference.py"     --weightspath ${weightspath}     --metaname "model.meta"     --ckptname $ckptname    --imagepath ${input_path} ${ocommands} 1>> ${temp_txt}  2>> /dev/null   ; cat ${temp_txt} | grep "Image" >> ${output_txt};  cat ${temp_txt} | grep "Normal" >> ${output_txt}; prediction=$( cat ${temp_txt} | grep   "Prediction" ) ; echo ${prediction} >> ${output_txt} ; echo " - "${prediction}  ;rm ${temp_txt};

fi
