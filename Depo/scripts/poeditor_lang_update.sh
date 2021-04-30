#!/bin/bash

POEDITOR_API_TOKEN="b91af56559195b57ea5e1bddb49d3e54"
POEDITOR_PROJECT_ID="397845"

POEDITOR_LANGUAGES_VS_XCODE_FOLDERS=("en" "tr" "uk" "ru" "ro" "es" "de" "ar" "sq" "fr")
ROOT_LOCALIZATION_FOLDER="./Depo/App/Resources/"

function extractUrlFromPOEditorJson {
    temp=`echo $json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w item`
    echo ${temp##*|}
}

function downloadOneLanguage {
    outputfile=$ROOT_LOCALIZATION_FOLDER$currentLangaugeCodeXCode".lproj/OurLocalizable.strings"

    echo "⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️ $currentLanguageCodePOEditor ->  $outputfile ⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️"
    echo Fetching POEditor URL...


    json=`curl -s -# -X POST https://poeditor.com/api/ \
    -d action="export" \
    -d api_token="$POEDITOR_API_TOKEN" \
    -d id="$POEDITOR_PROJECT_ID" \
    -d updating="terms_translations" \
    -d language="$currentLanguageCodePOEditor" \
    -d type="apple_strings"`

    url=`extractUrlFromPOEditorJson`

    echo "⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️"
    echo Downloading translation file...

    curl -# -s -X GET $url -o $outputfile
}

function uploadLanguage {
    uploadFile=$ROOT_LOCALIZATION_FOLDER"en.lproj/OurLocalizable.strings"


    echo "⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️ UPLOADING $uploadFile ⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️"
    echo uploading...

    uploadJson=`curl -X POST https://api.poeditor.com/v2/projects/upload \
     -F api_token="$POEDITOR_API_TOKEN" \
     -F id="$POEDITOR_PROJECT_ID" \
     -F updating="terms_translations" \
     -F file=@"$uploadFile" \
     -F language="en" \
     -F tags={"new":["name-of-tag"}` 

    echo "$uploadJson"
    echo "⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️"

}

echo " ▶️ Begining ▶️ "

uploadLanguage

for value in "${POEDITOR_LANGUAGES_VS_XCODE_FOLDERS[@]}"; do
    currentLanguageCodePOEditor="${value}"
    currentLangaugeCodeXCode="${value}"
    downloadOneLanguage
done