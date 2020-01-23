#!/usr/bin/python
# -*- coding: utf-8 -*-

exception_list = [
                  "Please text \"Iptal LIFEBOX %@\" to 2222 to cancel your subscription",
                  
                  "Platinum and lifecell customers can send LIFE CANCEL, other customers can send LIFEBOX CANCEL to 3030 to cancel their memberships",
                  
                  "To deactivate lifebox 50GB please send SMS with the text 50VYKL, for lifebox 500GB please send SMS with the text 500VYKL to the number 8080",
                  
                  "Platinum and lifecell customers can send LIFE, other customers can send LIFEBOX 50GB for lifebox 50GB package, LIFEBOX 500GB for lifebox 500GB package and LIFEBOX 2.5TB for lifebox 2.5TB package to 3030 to start their memberships",
                  
                  "Special prices for lifecell subscribers! To activate lifebox 50GB for 24,99UAH/30 days send SMS with the text 50VKL, for lifebox 500GB for 52,99UAH/30days send SMS with the text 500VKL to the number 8080",
                  
                  "offersCancelLife",
                  "package_slcm_cancel_text",
                  "package_lifecell_cancel_text",
                  "package_kktcell_cancel_text",
                  "package_life_cancel_text",
                  "package_paycell_all_access_cancel_text",
                  "package_paycell_slcm_cancel_text",
                  "package_slcm_paycell_cancel_text",
                  "leave_premium_premium_description",
                  "feature_slcm_cancel_text",
                  "feature_paycell_all_access_cancel_text",
                  "feature_paycell_slcm_cancel_text",
                  "feature_slcm_paycell_cancel_text",
                  "feature_all_access_paycell_cancel_text",
                  "leave_middle_turkcell" ]


path_list = ['./Depo/App/Resources/en.lproj/OurLocalizable.strings',
             './Depo/App/Resources/ar.lproj/OurLocalizable.strings',
             './Depo/App/Resources/de.lproj/OurLocalizable.strings',
             './Depo/App/Resources/es.lproj/OurLocalizable.strings',
             './Depo/App/Resources/fr.lproj/OurLocalizable.strings',
             './Depo/App/Resources/ro.lproj/OurLocalizable.strings',
             './Depo/App/Resources/ru.lproj/OurLocalizable.strings',
             './Depo/App/Resources/sq.lproj/OurLocalizable.strings',
             './Depo/App/Resources/tr.lproj/OurLocalizable.strings',
             './Depo/App/Resources/uk.lproj/OurLocalizable.strings',
             './Depo/App/Resources/en.lproj/InfoPlist.strings',
             './Depo/App/Resources/ar.lproj/InfoPlist.strings',
             './Depo/App/Resources/de.lproj/InfoPlist.strings',
             './Depo/App/Resources/es.lproj/InfoPlist.strings',
             './Depo/App/Resources/fr.lproj/InfoPlist.strings',
             './Depo/App/Resources/ro.lproj/InfoPlist.strings',
             './Depo/App/Resources/ru.lproj/InfoPlist.strings',
             './Depo/App/Resources/sq.lproj/InfoPlist.strings',
             './Depo/App/Resources/tr.lproj/InfoPlist.strings',
             './Depo/App/Resources/uk.lproj/InfoPlist.strings'
             ]


def change_product_name_for_localize_string(path_to_file):

    new_data = []

    with open(path_to_file, 'r') as file:
        filedata = file.readlines()

    for line in filedata:
        
        if '=' in line:
            
            key, value = line.split(' = "')
            
            if key not in exception_list:
                value = value.replace('lifebox', 'billo')
                value = value.replace('Lifebox', 'Billo')
                value = value.replace('LIFEBOX', 'BILLO')
                line = ' = '.join([ key , '"'+value])

        new_data.append(line)

    with open(path_to_file, 'w') as file:
        for item in new_data:
            file.write(item)



for path in path_list:
    change_product_name_for_localize_string(path)







