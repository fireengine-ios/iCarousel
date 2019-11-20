#!/bin/sh

#  discardLocalizationChanges.sh
#  Depo
#
#  Created by Alex on 11/20/19.
#  Copyright © 2019 LifeTech. All rights reserved.

declare -a arr=("$SRCROOT/Depo/App/Resources/en.lproj/OurLocalizable.strings" "$SRCROOT/Depo/App/Resources/ar.lproj/OurLocalizable.strings"
    "$SRCROOT/Depo/App/Resources/de.lproj/OurLocalizable.strings"
    "$SRCROOT/Depo/App/Resources/es.lproj/OurLocalizable.strings"
    "$SRCROOT/Depo/App/Resources/fr.lproj/OurLocalizable.strings"
    "$SRCROOT/Depo/App/Resources/ro.lproj/OurLocalizable.strings"
    "$SRCROOT/Depo/App/Resources/ru.lproj/OurLocalizable.strings"
    "$SRCROOT/Depo/App/Resources/sq.lproj/OurLocalizable.strings"
    "$SRCROOT/Depo/App/Resources/tr.lproj/OurLocalizable.strings"
    "$SRCROOT/Depo/App/Resources/uk.lproj/OurLocalizable.strings"
    )

for i in "${arr[@]}"
do
   git checkout HEAD -- "$i"
done
