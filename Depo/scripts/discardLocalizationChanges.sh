#!/bin/sh

#  discardLocalizationChanges.sh
#  Depo
#
#  Created by Alex on 11/20/19.
#  Copyright © 2019 LifeTech. All rights reserved.

declare -a arr=("./Depo/App/Resources/en.lproj"
    "./Depo/App/Resources/ar.lproj"
    "./Depo/App/Resources/de.lproj"
    "./Depo/App/Resources/es.lproj"
    "./Depo/App/Resources/fr.lproj"
    "./Depo/App/Resources/ro.lproj"
    "./Depo/App/Resources/ru.lproj"
    "./Depo/App/Resources/sq.lproj"
    "./Depo/App/Resources/tr.lproj"
    "./Depo/App/Resources/uk.lproj"
    )

for i in "${arr[@]}"
do
   git checkout HEAD -- "$i"
done
