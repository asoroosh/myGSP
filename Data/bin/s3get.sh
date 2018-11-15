if [ ${#@} == 0 ]; then
    	echo "Usage: $0 s3://Where/From/file.foo Where/To/file.foo"
    	echo " WhereFrom: should be the s3 amazon bucket path to the file"
    	echo " WhereTo: Destination, including the path and the file name."
	exit 1
fi

What2Get=${1}
Where2PuIt=${2}

AWS_ACCESS_KEY=$AWS_ACCESS_KEY_ID
AWS_SECRET_KEY=$AWS_SECRET_ACCESS_KEY

#_________________________________________________________________________________________________
#___________________________________Download form S3 Bucket_______________________________________
#_________________________________________________________________________________________________
function s3get {
        #helper functions_________________________________________________
        function fail { echo "$1" > /dev/stderr; exit 1; }

        #dependency check_________________________________________________
        if ! hash openssl 2>/dev/null; then fail "openssl not installed"; fi
        if ! hash curl 2>/dev/null; then fail "curl not installed"; fi

        #params_________________________________________________
        path="${1}"
        bucket=$(cut -d '/' -f 1 <<< "$path")
        key=$(cut -d '/' -f 2- <<< "$path")
        region="${2:-us-west-1}"

        #echo "Bucket: ${bucket}, Path: ${path}, Key: ${key}"

        #load creds_________________________________________________
        access="$AWS_ACCESS_KEY"
        secret="$AWS_SECRET_KEY"

        #validate_________________________________________________
        if [[ "$bucket" = "" ]]; then fail "missing bucket (arg 1)"; fi;
        if [[ "$key" = ""    ]]; then fail "missing key (arg 1)"; fi;
        if [[ "$region" = "" ]]; then fail "missing region (arg 2)"; fi;
        if [[ "$access" = "" ]]; then fail "missing AWS_ACCESS_KEY (env var)"; fi;
        if [[ "$secret" = "" ]]; then fail "missing AWS_SECRET_KEY (env var)"; fi;

        #compute signature_________________________________________________
        contentType="text/html; charset=UTF-8"
        date="`date -u +'%a, %d %b %Y %H:%M:%S GMT'`"
        resource="/${bucket}/${key}"
        string="GET\n\n${contentType}\n\nx-amz-date:${date}\n${resource}"
        signature=`echo -en $string | openssl sha1 -hmac "${secret}" -binary | base64`

        #get!_________________________________________________
        curl -H "x-amz-date: ${date}" \
                         -H "Content-Type: ${contentType}" \
             -H "Authorization: AWS ${access}:${signature}" \
                            "https://s3.amazonaws.com${resource}" \
                   -o "$2"

        #curl -H "x-amz-date: ${date}" \
        #-H "Content-Type: ${contentType}" \
        #-H "Authorization: AWS ${access}:${signature}" \
        #"https://s3-${region}.amazonaws.com${resource}"
        #-o "$2"
}
#_________________________________________________________________________________________________________________________

s3get $What2Get $Where2PuIt

