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
## iOS
### ios beta_jenkins
```
fastlane ios beta_jenkins
```

### ios beta_jenkins_preprod
```
fastlane ios beta_jenkins_preprod
```

### ios beta_diawi
```
fastlane ios beta_diawi
```

### ios beta_fabric
```
fastlane ios beta_fabric
```

### ios beta_fabric_preprod
```
fastlane ios beta_fabric_preprod
```

### ios my_gym
```
fastlane ios my_gym
```
Create ipa
### ios diawi
```
fastlane ios diawi
```

### ios fabric
```
fastlane ios fabric
```
Distribute build via Fabric
### ios slack_post
```
fastlane ios slack_post
```
Post message to the #lifebox-ios-firengine slack channel
### ios notify_about_completion
```
fastlane ios notify_about_completion
```

### ios poeditor_download
```
fastlane ios poeditor_download
```

### ios switch_to_preprod
```
fastlane ios switch_to_preprod
```

### ios switch_to_prod
```
fastlane ios switch_to_prod
```

### ios test_get_build_number
```
fastlane ios test_get_build_number
```

### ios test_get_build_number_my
```
fastlane ios test_get_build_number_my
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
