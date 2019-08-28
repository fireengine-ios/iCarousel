fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
### beta_jenkins
```
fastlane beta_jenkins
```

### beta_jenkins_preprod
```
fastlane beta_jenkins_preprod
```

### beta_diawi
```
fastlane beta_diawi
```

### beta_diawi_preprod
```
fastlane beta_diawi_preprod
```

### beta_diawi_prod
```
fastlane beta_diawi_prod
```

### build_prod_and_preprod
```
fastlane build_prod_and_preprod
```

### beta_fabric
```
fastlane beta_fabric
```

### beta_fabric_preprod
```
fastlane beta_fabric_preprod
```

### my_scan
```
fastlane my_scan
```
run tests
### my_gym
```
fastlane my_gym
```
Create ipa
### diawi
```
fastlane diawi
```

### fabric
```
fastlane fabric
```
Distribute build via Fabric
### slack_post
```
fastlane slack_post
```
Post message to the #lifebox-ios-firengine slack channel
### notify_about_completion
```
fastlane notify_about_completion
```

### poeditor_download
```
fastlane poeditor_download
```

### fix_build_number
```
fastlane fix_build_number
```

### switch_to_preprod
```
fastlane switch_to_preprod
```

### switch_to_prod
```
fastlane switch_to_prod
```

### create_new_branch
```
fastlane create_new_branch
```

### increment_version
```
fastlane increment_version
```

### set_build_number
```
fastlane set_build_number
```

### test_get_build_number
```
fastlane test_get_build_number
```
fastlane-plugin-versioning required. also it needs more time that my class
### test_get_build_number_my
```
fastlane test_get_build_number_my
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
