#!/bin/sh

#  discardLocalizationChanges.sh
#  Depo
#
#  Created by Alex on 11/20/19.
#  Copyright © 2019 LifeTech. All rights reserved.

declare -a arr=("$SRCROOT/Depo/App/Resources/en.lproj"
    "$SRCROOT/Depo/App/Resources/ar.lproj"
    "$SRCROOT/Depo/App/Resources/de.lproj"
    "$SRCROOT/Depo/App/Resources/es.lproj"
    "$SRCROOT/Depo/App/Resources/fr.lproj"
    "$SRCROOT/Depo/App/Resources/ro.lproj"
    "$SRCROOT/Depo/App/Resources/ru.lproj"
    "$SRCROOT/Depo/App/Resources/sq.lproj"
    "$SRCROOT/Depo/App/Resources/tr.lproj"
    "$SRCROOT/Depo/App/Resources/uk.lproj"
    )

for i in "${arr[@]}"
do
   git checkout HEAD -- "$i"
done
