#!/bin/bash

POEDITOR_API_TOKEN="b91af56559195b57ea5e1bddb49d3e54"
POEDITOR_PROJECT_ID="397845"

POEDITOR_LANGUAGES_VS_XCODE_FOLDERS=("en" "tr")
ROOT_LOCALIZATION_FOLDER="./LifeBox_Business/App/Resources/"

function extractUrlFromPOEditorJson {
    temp=`echo $json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w item`
    echo ${temp##*|}
}

function downloadOneLanguage {
    outputfile=$ROOT_LOCALIZATION_FOLDER$currentLangaugeCodeXCode".lproj/OurLocalizable.strings"

    echo "*************** $currentLanguageCodePOEditor ->  $outputfile ***************"
    echo Fetching POEditor URL...


    json=`curl -s -# -X POST https://poeditor.com/api/ \
    -d api_token="$POEDITOR_API_TOKEN" \
    -d action="export" \
    -d id="$POEDITOR_PROJECT_ID" \
    -d language="$currentLanguageCodePOEditor" \
    -d type="apple_strings"`

    url=`extractUrlFromPOEditorJson`

    echo "***************"
    echo Downloading translation file...

    curl -# -s -X GET $url -o $outputfile
}

for value in "${POEDITOR_LANGUAGES_VS_XCODE_FOLDERS[@]}"; do
    currentLanguageCodePOEditor="${value}"
    currentLangaugeCodeXCode="${value}"
    downloadOneLanguage
done