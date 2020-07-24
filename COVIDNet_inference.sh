#! /bin/bash

##################################################################################################################
### Input parsing
##################################################################################################################

input_path=$1
COVIDNet_model=$2
output_txt=$3


		if [ $# -lt 1 ]; then							# usage dello script							
			    echo $0: "usage: COVIDNet_inference.sh <input_path> [<COVIDNet_model>] [<output_txt>]"			    
			    echo     "COVIDNet_model:   "
			    echo     "                1. COVIDNet-CXR3-A"
			    echo     "                2. COVIDNet-CXR3-B"
			    echo     "                3. COVIDNet-CXR3-C"
			    echo     "                4. COVIDNet-CXR-Large"
			    echo     "                5. COVIDNet-CXR-Small"	
			    exit 1;		    
		fi   

##################################################################################################################
### Functions
##################################################################################################################

str_index() {    
                
                ############# ############# ############# ############# ############# ############# 
                ############        Find the first index of a substring in a string     ########### 
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
                #############      Remove directory and extension from a file name    ############# 
                ############# ############# ############# ############# ############# #############
                  
                echo ` basename $1 | cut -d '.' -f 1 `
		
		};
error() 	{       
	       ############# ############# ############# ############# ############# #############
               #############  	    Print an error message on the screen             ############# 
               ############# ############# ############# ############# ############# ############# 
			
  			echo "$@" 1>&2
  			
			};

fail() 		{

	       ############# ############# ############# ############# ############# ############# #############
               #############  	     Exit the script and print an error message on the screen      ############# 
               ############# ############# ############# ############# ############# ############# #############
                        
  			error "$@"
  			exit 1
		};
##################################################################################################################
### main
##################################################################################################################

SCRIPT=`realpath -s $0`
dir_script=`dirname $SCRIPT`
utilities=${dir_script}"/utilities.sh"

# define default inputs
COVIDNet_DIR=${dir_script} 
COVIDNET_models=${COVIDNet_DIR}"/models/"
[ -z ${COVIDNet_model} ] && { COVIDNet_model="COVIDNet-CXR3-B"; }
weightspath=${COVIDNET_models}"/"${COVIDNet_model}
model_v=( $( ls ${weightspath}"/model-"* )  )
model_str=${model_v[0]}
sind=$( str_index ${model_v[0]} "." )
ckptname=$( basename ${model_str:0:${sind}} )
[ -z ${output_txt} ] && \
	{ output_txt=$( dirname ${input_path} )'/'$( fbasename ${input_path} )"_"${COVIDNet_model}"_inference_output.txt"; }

( [ "${COVIDNet_model}" ==  "COVIDNet-CXR-Large"  ] || \
	[  "${COVIDNet_model}" ==  "COVIDNet-CXR-Small" ] ) &&\
	 { ocommands=" --out_tensor dense_3/Softmax:0 --input_size 224 " ; }


printf "" > ${output_txt}

#if [ -d ${input_path} ]; then
#	time_=$( date +%D_%T )
#	time_=${time_//'/'/'_'}
#	time_=${time_//':'/'_'}
#	temp_txt=${input_path}"/"$( fbasename ${input_path} )"_COVIDNet_inference_"${time_}".txt"
#	temp_err=${input_path}"/"$( fbasename ${input_path} )"_COVIDNet_inference_"${time_}".err"
#	temp_log=${input_path}"/"$( fbasename ${input_path} )"_COVIDNet_inference_"${time_}".log"
#	printf "" >> $temp_err;
#	for i in $( ls ${input_path} ); do  \
#		printf "Image: "${i}" "; 
#		python ${COVIDNet_DIR}"/inference.py"     \
#					--weightspath ${weightspath}     \
#				    	--metaname "model.meta"     \
#					--ckptname $ckptname    \
#					--imagepath ${input_path}"/"${i} ${ocommands} \
#					1>> ${temp_txt} 2>> ${temp_err}  ; \
#					printf "Image: "$( basename ${i} )" ; "  >> ${output_txt}
#					prediction=$( cat ${temp_txt} | grep   "Prediction" ) ; 
#                                       Confidence=$( cat ${temp_txt} | grep   "Normal" ) ;  
#					echo "- "${prediction}" - Confidence: "${Confidence}; 
#					echo ${prediction}" ; Confidence: "${Confidence} >> ${output_txt} ;  
#					cat ${temp_txt} >> ${temp_log};
#					rm ${temp_txt}; 
#	done
#
#else

# check file type
file_mime=$( file --mime-type -b  ${input_path} )
file_type=$( echo $file_mime | rev | cut -d"/" -f1  | rev )

case "${file_type}" in

	"dicom")

		source env/bin/activate
		source ${utilities}
		input_path_jpg=$( dirname ${input_path} )"/"$( fbasename ${input_path} )".jpg"
		imm_dcm2jpg ${input_path} 
		input_path=${input_path_jpg}
		deactivate
	;;

	"jpeg")

		printf ""

	;;

        *)
        # Do whatever you want with extra options
        [ -z $file_type ] || { fail "Unsupported file type '$file_type'";} 
        ;;
    esac

# define text files
time_=$( date +%D_%T )
time_=${time_//'/'/'_'}
time_=${time_//':'/'_'}
temp_txt=$( dirname ${input_path} )"/"$( fbasename ${input_path} )"_"${COVIDNet_model}"_inference_"${time_}".txt"
temp_err=$( dirname ${input_path} )"/"$( fbasename ${input_path} )"_"${COVIDNet_model}"_inference_"${time_}".err"
temp_log=$( dirname ${input_path} )"/"$( fbasename ${input_path} )"_"${COVIDNet_model}"_inference_"${time_}".log"
printf "" >> $temp_err;
printf "Image: "$( basename ${input_path} )" "; 

# perform prediction
python ${COVIDNet_DIR}"/inference.py" \
				--weightspath ${weightspath}     \
				--metaname "model.meta"     \
				--ckptname $ckptname    \
				--imagepath ${input_path} ${ocommands} \
				1>> ${temp_txt}  2>> ${temp_err}   ; \
				printf "Image: "$( basename ${input_path} )" ; "  >> ${output_txt};  \
				prediction=$( cat ${temp_txt} | grep   "Prediction" ) ; \
				Confidence=$( cat ${temp_txt} | grep   "Normal" ) ; \
				echo "- "${prediction}" - Confidence: "${Confidence}; \
				echo ${prediction}" ; Confidence: "${Confidence} >> ${output_txt} ;
				cp ${temp_txt}  ${temp_log}
			        rm ${temp_txt};
				[ -z ${input_path_jpg} ] || { rm ${input_path_jpg} ; }

