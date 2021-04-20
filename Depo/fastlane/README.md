fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

## Choose your installation method:

<table width="100%" >
<tr>
<th width="33%"><a href="http://brew.sh">Homebrew</a></td>
<th width="33%">Installer Script</td>
<th width="33%">Rubygems</td>
</tr>
<tr>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS or Linux with Ruby 2.0.0 or above</td>
</tr>
<tr>
<td width="33%"><code>brew cask install fastlane</code></td>
<td width="33%"><a href="https://download.fastlane.tools">Download the zip file</a>. Then double click on the <code>install</code> script (or run it in a terminal window).</td>
<td width="33%"><code>sudo gem install fastlane -NV</code></td>
</tr>
</table>

# Available Actions
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
### my_gym_lifedrive
```
fastlane my_gym_lifedrive
```

### firebase_lifetech_lifebox
```
fastlane firebase_lifetech_lifebox
```
LifeTech Lifebox build distribution via Firebase
### firebase_lifetech_billo
```
fastlane firebase_lifetech_billo
```
LifeTech Lifedrive build distribution via Firebase
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

### business_poeditor_download
```
fastlane business_poeditor_download
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
