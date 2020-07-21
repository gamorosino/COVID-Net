gdrive_getID () {
		    	############# ############# ############# ############# ############# ############# #############
		    	############# 	   		Google drive direct download			    ############# 
		    	############# ############# ############# ############# ############# ############# #############

			if [ $# -lt 1 ]; then												
			    echo $0: usage: "gdrive_getID <url>  "
			    return 1;		    
			fi
			local url=$1
			fileid=""
			declare -a patterns=("s/.*\/file\/d\/\(.*\)\/.*/\1/p" "s/.*id\=\(.*\)/\1/p" "s/\(.*\)/\1/p")
			for i in "${patterns[@]}"
			do
   				fileid=$(echo $url | sed -n $i)
   				[ ! -z "$fileid" ] && break
			done

			[ -z "${fileid}" ] && { echo "None" ; }	

			echo "${fileid}"

		}

gdrive_download () {


		    	############# ############# ############# ############# ############# ############# #############
		    	############# 	   		Google drive direct download			    ############# 
		    	############# ############# ############# ############# ############# ############# #############

			if [ $# -lt 2 ]; then							# usage dello script							
			    echo $0: usage: "gdrive_download <url> <filename.ext> "
			    return 1;		    
			fi

			local url=$1
			local filename=$2

			fileid=$( gdrive_getID ${url}  )


			[ "${fileid}" == "None" ] && { echo "Could not find Google ID"; exit 1 ; }	

			echo "File ID: "$fileid 
			
			temp_folder=$( dirname ${filename} )"/gdrive_download_"$( date +%s)"/"
			cookies_txt=${temp_folder}"/cookies.txt"			
			header_txt=${temp_folder}"/header.txt"
			confirm_txt=${temp_folder}"/confirm.txt"

			mkdir -p $temp_folder
			
			wget --save-cookies ${cookies_txt} 'https://docs.google.com/uc?export=download&id='$fileid -O- \
     			| sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p' > ${confirm_txt}

			wget --load-cookies ${cookies_txt} -O $filename \
     			'https://docs.google.com/uc?export=download&id='$fileid'&confirm='$(<${confirm_txt})

			rm -rf ${temp_folder}

			};	
