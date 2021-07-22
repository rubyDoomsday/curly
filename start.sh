CURLY_HOME=$HOME/_my_projects/curly
JSON=$CURLY_HOME/_payload.json # usede for standard json data
DATA=$CURLY_HOME/_payload # used for url-encoded data
HEADERS=$CURLY_HOME/_headers.list
RESPONSE=$CURLY_HOME/_response.json

# ensure environement on source
cd CURLY_HOME
mkdir -p headers history hosts paths payloads responses
touch $HEADERS
touch $JSON
clear
cat .manpage

host_default="http://localhost:3000"
path_default="/"

CURLY_HOST=$host_default
CURLY_PATH=$path_default

setHost() {
  CURLY_HOST=$1
}

setPath() {
  CURLY_PATH=$1
}

alias curlyHelp="cat .manpage"
alias setPayload="vim $JSON"
alias setHeaders="vim $HEADERS"
alias showLast="vim $RESPONSE -c 'vsplit $JSON' -c 'split $HEADERS'"
alias showLastNoPayload="vim -O $HEADERS $RESPONSE"

# inspects current or a saved request
showRequest() {
  if [ -z "$1" ]
  then
    echo "\nHOST: $CURLY_HOST"
    echo "PATH: $CURLY_PATH"
    echo "HEADERS:"
    cat $HEADERS

    if [ -s $JSON ]
    then
      echo "\nPAYLOAD:"
      cat $JSON
    else
      echo ""
    fi
  else
    FILENAME="${1#history/}"
    echo "\nHOST:"
    cat hosts/$FILENAME'.string'
    echo "PATH:"
    cat paths/$FILENAME'.string'

    echo "HEADERS:"
    cat headers/$FILENAME'.list'

    if [ -s payloads/$FILENAME'.json' ]
    then
      echo "\nPAYLOAD:"
      cat payloads/$FILENAME'.json'
    else
      echo ""
    fi
  fi
}

# saves request
saveRequest() {
  today=`date '+%Y-%m-%d'`
  mkdir -p history/$today
  mkdir -p headers/$today
  mkdir -p payloads/$today
  mkdir -p paths/$today
  mkdir -p hosts/$today
  mkdir -p responses/$today

  if [ -z "$1" ]
  then
    host=$(echo $CURLY_HOST | sed -e 's/http[s]*\:\/.*\///g')
    FILENAME="$CURLY_ACTION--$host--${CURLY_PATH//\//.}"
  else
    FILENAME=$1
  fi
  touch history/$today/$FILENAME
  cp $HEADERS headers/$today/$FILENAME'.list'
  cp $JSON payloads/$today/$FILENAME'.json'
  cp $RESPONSE responses/$today/$FILENAME'.json'
  echo $CURLY_HOST > hosts/$today/$FILENAME'.string'
  echo $CURLY_PATH > paths/$today/$FILENAME'.string'
  echo "\nSaved Request: $today/$FILENAME"
}

# load request
loadRequest() {
  FILENAME="${1#history/}"
  cp headers/$FILENAME'.list' $HEADERS
  cp payloads/$FILENAME'.json' $JSON
  cp responses/$FILENAME'.json' $RESPONSE
  CURLY_HOST=$(cat hosts/$FILENAME'.string')
  CURLY_PATH=$(cat paths/$FILENAME'.string')
  echo "\nLOADED: $FILENAME"
  showRequest
}

deleteRequest() {
  FILENAME="${1#history/}"
  rm history/$FILENAME
  rm headers/$FILENAME'.list'
  rm payloads/$FILENAME'.json'
  rm responses/$FILENAME'.json'
  rm paths/$FILENAME'.string'
  rm hosts/$FILENAME'.string'
  echo "\nDeleted Request: $FILENAME"
}

eraseDay() {
  DAY="${1#history/}"
  rm -r -f history/$DAY
  rm -r -f headers/$DAY
  rm -r -f payloads/$DAY
  rm -r -f responses/$DAY
  rm -r -f paths/$DAY
  rm -r -f hosts/$DAY
  echo "\nErased: $DAY"
}

# clears current request
clearRequest() {
  cp .default_headers.list $HEADERS
  rm $JSON && touch $JSON
  rm $RESPONSE && touch $RESPONSE
  CURLY_HOST=$host_default
  CURLY_PATH=$path_default
  echo "\nCleared Request Params"
  showRequest
}

# completely wipes out cache files
curlyReset() {
  echo -n "Are you sure you want to clear all history and settings (y/n)?"
  read answer
  if echo "$answer" | grep -iq "^y"; then
    # clear current containers
    cp .default_headers.list $HEADERS
    rm $JSON && touch $JSON
    rm $RESPONSE && touch $RESPONSE
    # clear history
    /bin/rm -f -R headers/*
    /bin/rm -f -R history/*
    /bin/rm -R hosts/*
    /bin/rm -R paths/*
    /bin/rm -R payloads/*
    /bin/rm -R responses/*
    # reset defaults
    CURLY_HOST=$host_default
    CURLY_PATH=$path_default
    echo "\nReset RubyPost"
    showRequest
  else
    echo "Canceled"
  fi
}

loadHeaders() {
  headers=""
  while read line ; do
    headers=("${headers[@]} -H '$line'")
  done < $HEADERS
  echo $headers
}

loadFormData() {
  data=""
  while read line ; do
    data=("${data[@]} --data-urlencode '$line'")
  done < $DATA
  echo $data
}

# makes a post call with headers and payload to the supplied url
post() {
  CURLY_ACTION="POST"
  headers=`loadHeaders`

  post_path=${1:-$CURLY_PATH}
  CURLY_PATH=$post_path
  POST_URL=$CURLY_HOST$CURLY_PATH

  cmd="curl -d '@$JSON' $headers -X POST '$POST_URL'"

  echo "\n"$cmd"\n"
  eval $cmd | jq . > $RESPONSE && showLast
  saveRequest
}

# makes a get call with headers to the supplied url
get() {
  CURLY_ACTION="GET"
  headers=`loadHeaders`

  get_path=${1:-$CURLY_PATH}
  CURLY_PATH=$get_path
  GET_URL=$CURLY_HOST$CURLY_PATH

  cmd="curl $headers -X GET '$GET_URL'"

  echo "\n"$cmd"\n"
  eval $cmd | jq . > $RESPONSE && showLastNoPayload
  saveRequest
}

# makes a get call with headers to the supplied url
openStream() {
  CURLY_ACTION="STREAM"
  headers=`loadHeaders`

  get_path=${1:-$CURLY_PATH}
  CURLY_PATH=$get_path
  GET_URL=$CURLY_HOST$CURLY_PATH

  cmd="curl $headers -X GET '$GET_URL' --http1.1"

  echo "\n"$cmd"\n"
  eval $cmd

  saveRequest
}

# makes a put call with headers and payload to the supplied url
put() {
  CURLY_ACTION="PUT"
  headers=`loadHeaders`

  put_path=${1:-$CURLY_PATH}
  CURLY_PATH=$put_path
  PUT_URL=$CURLY_HOST$CURLY_PATH

  cmd="curl -d '@$JSON' $headers -X PUT '$PUT_URL'"

  echo "\n"$cmd"\n"
  eval $cmd | jq . > $RESPONSE && showLast
  saveRequest
}

# makes a put call with headers and payload to the supplied url
patch() {
  CURLY_ACTION="PUT"
  headers=`loadHeaders`

  patch_path=${1:-$CURLY_PATH}
  CURLY_PATH=$patch_path
  PATCH_URL=$CURLY_HOST$CURLY_PATH

  cmd="curl -d '@$JSON' $headers -X PATCH '$PATCH_URL'"

  echo "\n"$cmd"\n"
  eval $cmd | jq . > $RESPONSE && showLast
  saveRequest
}

# makes a delete call with headers and payload to the supplied url
delete() {
  CURLY_ACTION="DELETE"
  headers=`loadHeaders`

  delete_path=${1:-$CURLY_PATH}
  CURLY_PATH=$delete_path
  DELETE_URL=$CURLY_HOST$CURLY_PATH

  cmd="curl $headers -X DELETE '$DELETE_URL'"

  echo "\n"$cmd"\n"
  eval $cmd | jq . > $RESPONSE && showLastNoPayload
  saveRequest
}

postForm() {
  CURLY_ACTION="POST"
  headers=`loadHeaders`

  # convert json to url-encoded format
  cat $JSON | sed 's/[{}\" ,]//g;s/\:/=/g;/^[[:space:]]*$/d' > $DATA
  data=`loadFormData`

  post_path=${1:-$CURLY_PATH}
  CURLY_PATH=$post_path
  POST_URL=$CURLY_HOST$CURLY_PATH

  cmd="curl $data $headers -X POST '$POST_URL'"

  echo "\n"$cmd"\n"
  eval $cmd | jq . > $RESPONSE && showLast
  saveRequest

  rm $DATA # remove temp file
}
