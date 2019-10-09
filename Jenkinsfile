// Jenkins Template version 1.0

@Library('devops-common') _

/***** PROJECT variables  BEGIN ******/
agentName = 'devops-dss-js-ios-02' // The mac mini assigned to this project

appName = 'lifebox' // this will be the base filename of the app
groupPath = "com/ttech/lifebox/ios" // This will be used on artifactory

// Deploy to ICT Store
ictsContainerId = '743'
ictsDeployers = "EXT02D9926" // To enable, uncomment submitters in approval stage code
testFlightDeployers = "TCUSER" // To enable, uncomment submitters in approval stage code

// Email notification
devTeamEmails = "ozgur.oktay@consultant.turkcell.com.tr;samet.alkan@turkcell.com.tr;can.kucukakdag@turkcell.com.tr"

xcodeParams = [
        xcodeApp: 'Xcode10.1.app',
        target: 'TC_Depo_LifeTech',
        workspaceFile: 'Depo/Depo',
        versionInfoPath: 'Depo/Depo/App/Depo-AppStore-Info.plist',
        schema: 'TC_Depo_LifeTech'
]

def flavors = [
    test: [
        configuration: 'Enterprise',
        developmentTeamID: 'LA4DZFY7SY',
        ipaExportMethod: 'enterprise'
    ],
    prod: [
        configuration: 'AppStore',
        developmentTeamID: '7YZS5NTGYH',
        ipaExportMethod: 'app-store'
    ]
]
/***** PROJECT variables END ******/

artifactory = Artifactory.server 'turkcell-artifactory'
artifactPath = "turkcell-development/${groupPath}/${appName}"

appVersion = '' // short version on apple store. Will be copied from source
version = '' // long version on artifactory. Will contain branch name and build number for uniqueness

branchName = JOB_NAME.replaceAll('[^/]+/','').replaceAll('%2F','/')
isDev = branchName == 'pre_release_v2'
echo "Branch Name: ${branchName}"

def xcodeBuild = { flavorId ->
    def flavor = flavors[flavorId]
    def provisionsDir = "provisioningProfiles/${flavor.configuration}"
    def provisionFiles = findFiles(glob: "${provisionsDir}/*.mobileprovision")
    def provisioningProfiles = provisionFiles.collect { file -> [
        provisioningProfileAppId: file.name.replace('_','.') - '.mobileprovision',
        provisioningProfileUUID: "${provisionsDir}/${file.name}"
        ] }
    echo "Using provisioning profiles: ${provisioningProfiles}"
    step([$class: 'XCodeBuilder', 
      target: xcodeParams.target,
      interpretTargetAsRegEx: false,
      cleanBeforeBuild: true,
      allowFailingBuildResults: false,
      generateArchive: false,
      noConsoleLog: false,
      configuration: flavor.configuration,
      
      // Pack application, build and sign .ipa?
      buildIpa: true,
      ipaExportMethod: flavor.ipaExportMethod,
      ipaName: "${appName}-${BUILD_ID}-${flavorId}",
      ipaOutputDirectory: '',
      ipaManifestPlistUrl: '',
      
      // Manual signing?
      manualSigning: true,
      
      developmentTeamName: 'none (specify one below)',
      developmentTeamID: flavor.developmentTeamID,
      
      // Provisioning Profiles
      provisioningProfiles: provisioningProfiles,
      
      // Change bundle ID?
      changeBundleID: false,
      bundleID: '',
      bundleIDInfoPlistPath: '',
      
      // Keychain
      unlockKeychain: true,
      keychainName: 'none (specify one below)',
      keychainPath: "/Users/jenkinsbuild/Library/Keychains/login.keychain",
      keychainPwd: IOS_PASS,
      
      // Advanced Xcode build options
      cleanTestReports: false,
      xcodeSchema: xcodeParams.schema,
      sdk: '',
      symRoot: '',
      xcodebuildArguments: 'VALID_ARCHS="armv7 armv7s arm64" -allowProvisioningUpdates',
      xcodeWorkspaceFile: xcodeParams.workspaceFile,
      xcodeProjectPath: '',
      xcodeProjectFile: '',
      buildDir: "${WORKSPACE}/build",
      
      // Versioning
      provideApplicationVersion: false,
      cfBundleShortVersionStringValue: '',
      cfBundleVersionValue: ''
      ])
}

def publishToArtifactory = { classifier ->
    STAGE_NAME = 'Build (test): Publish to Artifactory'

    sh "find build -type d -name '*.dSYM' > dsymFiles"
    sh "zip -@ build/dsym.zip < dsymFiles"

    def outputsDir = 'build'
    sh "ls -l ${outputsDir}/*.ipa"
    def uploadSpec = """{
        "files": [
            {
            "pattern": "${outputsDir}/*.ipa",
            "target": "${artifactPath}/${version}/${appName}-${version}-${classifier}.ipa"
            },
            {
            "pattern": "${outputsDir}/dsym.zip",
            "target": "${artifactPath}/${version}/${appName}-${version}-${classifier}-dsym.zip"
            }
        ]}"""
    def buildInfo = artifactory.upload(uploadSpec)
    def ipaUrl = "${artifactory.url}/${artifactPath}/${version}/${appName}-${version}-${classifier}.ipa"
    def dsymUrl = "${artifactory.url}/${artifactPath}/${version}/${appName}-${version}-${classifier}-dsym.zip"
    createSummary icon:'package.png', text:"<a href=\"${ipaUrl}\">${appName}-${version}-${classifier}.ipa</a>"
    createSummary icon:'package.png', text:"<a href=\"${dsymUrl}\">${appName}-${version}-${classifier}-dsym.zip</a>"
}

pipeline {
    agent none
    options {
        timestamps()
        skipDefaultCheckout true
        buildDiscarder(logRotator(numToKeepStr: isDev?'30':'5', daysToKeepStr: isDev?'90':'15'))
    }
    stages {
        stage('Commit Stage') {
            options { timeout(time: 4, unit: 'HOURS') }
            agent { label agentName }
            environment {
                DELIVER_ITMSTRANSPORTER_ADDITIONAL_UPLOAD_PARAMETERS = "-t DAV"
                IOS_PASS = credentials('iosLoginPass')
            }
            steps {
                script {
                    STAGE_NAME = 'Build : Init'
                    //sh "git config --global credential.helper cache"
                    def scmVars = checkout scm
                    def gitUrl = scmVars.GIT_URL.trim()
                    echo "git url: ${gitUrl}"

                    stage('Build for Enterprise') {
                        STAGE_NAME = 'Pre-Build Checks'

 						def infoFile = "${WORKSPACE}/${xcodeParams.versionInfoPath}"
                        def appVersion = sh returnStdout: true, script: "/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' ${infoFile}"
                        //def declaredBuild = sh returnStdout: true, script: "/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' ${infoFile}"
                        //appVersion = "${declaredVersion.trim()}.${declaredBuild.trim()}"
                        version = "${appVersion.trim()}.${branchName.toLowerCase().replace('/','.')}.${env.BUILD_NUMBER}"

                        echo "Building version: ${version}"

                        sh 'Pods/SwiftLint/swiftlint --reporter checkstyle > swiftlint-report.xml || true'
                        checkstyle defaultEncoding: '', healthy: '', pattern: 'swiftlint-report.xml', unHealthy: '',
                            useStableBuildAsReference: true
                        
                        STAGE_NAME = 'Build : Compile'

                        // sh "gem install cocoapods-art --user-install"
                        // sh 'pod repo-art add CocoaPods "https://artifactory.turkcell.com.tr/artifactory/api/pods/CocoaPods"'
                        sh "sudo xcode-select -switch /Applications/${xcodeParams.xcodeApp}/Contents/Developer"
                        sh "cd Depo; pod install --repo-update"
                        xcodeBuild('test')
                        publishToArtifactory('test')
                    }
                }
            }
			post {
				always {
					script {
						email.notifyStage(successRecipientList: devTeamEmails, failureRecipientList: devTeamEmails)
					}
				}
			}
        }
        stage('Approve Deploy to ICT Store') {
            options { timeout(time: 24, unit: 'HOURS') }
            when { expression { ictsContainerId } }
            steps {
                script {
                    try {
                        if (!isDev) {
                            input ok:'Yes', message:'Deploy to ICT Store?' //, submitter: "${ictsDeployers}"
                        }
                        env.DEPLOY_TO = 'ICT Store'
                        echo "Deploy to ICT Store is approved. Starting the deployment..."

                    } catch(err) {
                        echo err.toString()
                    }
                }
            }
        }
        stage('Deploying to ICT Store') {
            when {
                beforeAgent true
                environment name: 'DEPLOY_TO', value: 'ICT Store'
            }
            agent { label 'devops-dss-js-default' }
            options {
                skipDefaultCheckout true
            }
            steps {
                script {
                    def ipaFile = "ictstore.ipa"
                    def manifestFile = "manifest.plist"
                    def ipaUrl = "${artifactory.url}/${artifactPath}/${version}/${appName}-${version}-test.ipa"
                    def ictsBundleIdentifier = flavors['test'].bundleIdentifier
                    sh "curl -v ${ipaUrl} -o ${ipaFile}"

                    writeFile file:manifestFile, text:"""<?xml version="1.0" encoding="UTF-8"?> <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"> <plist version="1.0"> <dict> <key>items</key> <array> <dict> <key>assets</key> <array> <dict> <key>kind</key> <string>software-package</string> <key>url</key> <string>http://ictstore.turkcell.com.tr/repositorystatic/files/1/${ictsContainerId}/content/${ipaFile}</string> </dict> </array> <key>metadata</key> <dict> <key>bundle-identifier</key> <string>${ictsBundleIdentifier}</string> <key>bundle-version</key> <string>${appVersion}</string> <key>kind</key> <string>software</string> <key>subtitle</key> <string>adhoc</string> <key>title</key> <string>${appName}</string> </dict> </dict> </array> </dict> </plist>"""

                    def ictsUpdateUrl = 'http://ictstore.turkcell.com.tr/RepositoryAdmin/rest/containers/updateFile'
                    sh "curl -v -f -i -X POST -F pList=@${manifestFile} -F ipa=@${ipaFile} ${ictsUpdateUrl}?containerId=${ictsContainerId}"
                    sh "echo ${appName}-${version}-test.ipa deployed to ICT Store"
                }
            }
			post {
				always {
					script {
						email.notifyStage(successRecipientList: devTeamEmails, failureRecipientList: devTeamEmails)
					}
				}
			}
        }
        stage('Approve Deploy to Testflight') {
            options { timeout(time: 24, unit: 'HOURS') }
            when { expression { ictsContainerId } }
            steps {
                script {
                    try {
                        if (isDev) {
                            input ok:'Yes', message:'Deploy to Testflight?' //, submitter: "${testFlightDeployers}"
                            env.DEPLOY_TO = 'Testflight'
                        } else {
                            def deployParameter = booleanParam(name: 'Deploy to Testflight', defaultValue: false)
                            def isDeploy = input ok:'Yes', message:'Build for Appstore?', parameters: [ deployParameter ] //, submitter: "${testFlightDeployers}"
                            env.DEPLOY_TO = isDeploy ? 'Testflight': ''
                        }
                        env.BUILD_TARGET = 'Appstore'
                        echo "Deploy to Testflight is approved. Starting the deployment..."

                    } catch(err) {
                        echo err.toString()
                    }
                }
            }
        }
        stage('Build for Appstore') {
            when {
                beforeAgent true
                environment name: 'BUILD_TARGET', value: 'Appstore'
            }
            agent { label agentName }
            options {
                skipDefaultCheckout true
            }
            environment {
                IOS_PASS = credentials('iosLoginPass')
                DELIVER_ITMSTRANSPORTER_ADDITIONAL_UPLOAD_PARAMETERS = "-t DAV"
                TESTFLIGHT_UPLOAD = credentials('testflight')
                FASTLANE_DONT_STORE_PASSWORD = 1
           }
            steps {
                script {
                    xcodeBuild('prod')
                    publishToArtifactory('prod')
                    if (env.DEPLOY_TO == 'Testflight') {
                        stage('Deploying to Testflight') {
                            sh "cp build/${appName}-${BUILD_ID}-prod.ipa ${appName}.ipa"
                            sh returnStdout: true, script: 'rm -f ~/.itmstransporter/UploadTokens/*.token'
                            sh """
                                export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=${TESTFLIGHT_UPLOAD_PSW}
                                ~/.fastlane/bin/fastlane run upload_to_testflight skip_submission:"true" ipa:"${appName}.ipa" apple_id:"${appleId}" username:"${TESTFLIGHT_UPLOAD_USR}"
                            """
                        }
                    }
                }
            }
			post {
				always {
					script {
						email.notifyStage(successRecipientList: devTeamEmails, failureRecipientList: devTeamEmails)
					}
				}
			}
        }
    }
}
