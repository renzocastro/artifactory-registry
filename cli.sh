#!/bin/sh

### BEGIN: UTILS

FG_RED_COLOR="\e[0;31m"
FG_GREEN_COLOR="\e[0;32m"
FG_YELLOW_COLOR="\e[0;33m"
FG_CYAN_COLOR="\e[0;34m"
FG_MAGENTA_COLOR="\e[0;35m"
FG_RESET_COLOR="\e[m"

log_info() {
  printf "$FG_CYAN_COLOR%s$FG_RESET_COLOR\n" "$1"
}

log_success() {
  printf "$FG_GREEN_COLOR%s$FG_RESET_COLOR\n" "$1"
}

log_error() {
  printf "$FG_RED_COLOR%s$FG_RESET_COLOR\n" "$1"
}

get_json_value() {
  CONTENT=$1
  KEY=$2
  local VALUE=$(echo "$CONTENT" | grep $KEY | sed -e "s/^\(.*\)\"$KEY\"\(.*\):\(.*\)\"\(.*\)\"\(.*\)/\4/")
  echo "$VALUE"
}

### END: UTILS


echo

JSON_FILE="$PWD/artifactory.json"


# CLI ARGUMENT: init
if [ "$1" == "init" ]; then
  if [[ -f "$JSON_FILE" ]]; then
    log_info "artifactory.json exists."
  else
    T=""
    T="$T{\n"
    T="$T  \"scope\": \"my-scope\",\n"
    T="$T  \"host\": \"http://localhost:8081\",\n"
    T="$T  \"repositoryName\": \"my-project.npm.dev\"\n"
    T="$T}\n"

    echo "$T" > $JSON_FILE

    log_success "artifactory.json was created."
  fi

  exit 0
fi


# exists artifactory.json ?

if [[ ! -f "$JSON_FILE" ]]; then
  log_error "artifactory.json file not found."
  exit 0
fi

JSON_CONTENT=$(cat $JSON_FILE)


NPM_SCOPE=$(get_json_value "$JSON_CONTENT" "scope")
NPM_ARTIFACTORY_REPO=$(get_json_value "$JSON_CONTENT" "repositoryName")
NPM_ARTIFACTORY_URL=$(get_json_value "$JSON_CONTENT" "host")
NPM_ARTIFACTORY_DOMAIN=$(echo $NPM_ARTIFACTORY_URL | sed -e "s/^http[s]*:\\/\\/\(.*\)/\1/")
NPM_ARTIFACTORY_URLBASE="//$NPM_ARTIFACTORY_DOMAIN/artifactory/api/npm/$NPM_ARTIFACTORY_REPO/"
NPM_ARTIFACTORY_URL="$NPM_ARTIFACTORY_URL/artifactory/api/npm/$NPM_ARTIFACTORY_REPO/"
NPM_FILE=~/.npmrc

npm_config_remove() {
  npm config delete "@$NPM_SCOPE:registry"
  sed -i "" "/${NPM_ARTIFACTORY_URLBASE//\//\/}\:/d" $NPM_FILE
}

# CLI ARGUMENT: remove
if [ "$1" == "remove" ]; then
  npm_config_remove
  log_success "JFrog Artifactory NPM configuration was removed."
  exit 0
fi

# CLI ARGUMENT: add
if [ "$1" != "add" ]; then
  log_error "`$1` command not found."
  exit 0
fi


printf "$FG_YELLOW_COLOR%s$FG_RESET_COLOR\n" "JFrog Artifactory authentication"
echo
read -p "» Username: " NPM_USERNAME
read -sp "» Password: " NPM_PASSWORD
echo
echo

CURL_ARGS=(
  --fail
  --silent
  --user "$NPM_USERNAME:$NPM_PASSWORD"
)
CURL_URL="${NPM_ARTIFACTORY_URL}auth/$NPM_SCOPE"
CURL_RESPONSE=$(curl "${CURL_ARGS[@]}" $CURL_URL)

if [[ ! $CURL_RESPONSE ]]; then
  log_error "Authentication failed."
  exit 0
fi

npm_config_remove
echo "$CURL_RESPONSE" >> $NPM_FILE
log_success "JFrog Artifactory NPM configuration was added!"
