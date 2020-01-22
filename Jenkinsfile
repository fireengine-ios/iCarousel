// Jenkins Template version 1.1

@Library('devops-common') _

/***** PROJECT variables  BEGIN ******/

agentName = 'devops-dss-js-ios-02' // The mac mini assigned to this project
apps = [ 
[
            name: 'lifebox',// name will be the base filename of the app
            versionInfoPath: 'Depo/Depo/App/Depo-AppStore-Info.plist',
            ictsContainerId: '743', // ICT Store
            appleId: '665036334', // Apple ID property in the App Information section in App Store Connect,
            prodTeamID: '7YZS5NTGYH',
	    xcodeSchema: 'TC_Depo_LifeTech',
            xcodeTarget: 'TC_Depo_LifeTech'
            //xcodeSchema: 'TC_Depo_LifeTech_Bundle',
            //xcodeTarget: 'TC_Depo_LifeTech_Bundle'
        ],
 [
            name: 'lifedrive',// name will be the base filename of the app
            versionInfoPath: 'Depo/Lifedrive/LifeDrive-AppStore-Info.plist',
            ictsContainerId: '966', // ICT Store
            appleId: '1488914348',
            prodTeamID: '729CGH4BJD',
	    //xcodeSchema: // Defaults to app name
            //xcodeTarget: // Defaults to app name
            //xcodeSchema: 'lifedrive_Bundle', 
            //xcodeTarget: 'lifedrive_Bundle'  
        ]
]
derivedDir = 'lifebox'

groupPath = "com/ttech/lifebox/ios" // This will be used on artifactory

// Deploy to ICT Store
ictsDeployers = "EXT02D9926" // To enable, uncomment submitters in approval stage code
testFlightDeployers = "TCUSER" // To enable, uncomment submitters in approval stage code

// Email notification
devTeamEmails = "ozgur.oktay@consultant.turkcell.com.tr;samet.alkan@turkcell.com.tr;can.kucukakdag@turkcell.com.tr"

xcodeParams = [
        xcodeApp: 'Xcode11.app',
        workspaceFile: 'Depo/Depo'
]

def flavors = [
    test: [
        configuration: 'Enterprise',
        developmentTeamID: 'LA4DZFY7SY',
        ipaExportMethod: 'enterprise'
    ],
    prod: [
        configuration: 'AppStore',
        //developmentTeamID: use app.prodTeamID
        ipaExportMethod: 'app-store'
    ]
]

/***** PROJECT variables END ******/

artifactory = Artifactory.server 'turkcell-artifactory'

branchName = JOB_NAME.replaceAll('[^/]+/','').replaceAll('%2F','/')
isDev = branchName == 'special_billo'
echo "Branch Name: ${branchName}"

def readVersion = { app ->
    def infoFile = "${WORKSPACE}/${app.versionInfoPath}"
    // short version on apple store. Will be copied from source
    def appVersion = sh returnStdout: true, script: "/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' ${infoFile}"
    //def declaredBuild = sh returnStdout: true, script: "/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' ${infoFile}"
    //appVersion = "${declaredVersion.trim()}.${declaredBuild.trim()}"
    app.bundleVersion = appVersion.trim()

    // Long version on artifactory. Will contain branch name and build number for uniqueness
    app.version = "${app.bundleVersion}.${branchName.toLowerCase().replace('/','.')}.${env.BUILD_NUMBER}"

    echo "Building app: ${app.name} version: ${app.version}"
}

def runXcode = { app, flavorId ->
    def flavor = flavors[flavorId]

    def provisionsDir = "provisioningProfiles/${flavor.configuration}"
    def provisionFiles = findFiles(glob: "${provisionsDir}/*.mobileprovision")
    def provisioningProfiles = provisionFiles.collect { file -> [
        provisioningProfileAppId: file.name.replace('_','.') - '.mobileprovision',
        provisioningProfileUUID: "${provisionsDir}/${file.name}"
        ] }
    echo "Using provisioning profiles: ${provisioningProfiles}"
    echo "run xcode for app: " + app
    sh "rm -f '${WORKSPACE}/${app.name}-logs/*'"

    xcodeBuild target: app.xcodeTarget ?: app.name,
      interpretTargetAsRegEx: false,
      cleanBeforeBuild: true,
      allowFailingBuildResults: false,
      generateArchive: false,
      noConsoleLog: false,
      //logfileOutputDirectory: "${WORKSPACE}/${app.name}-logs",
      configuration: flavor.configuration,
      
      // Pack application, build and sign .ipa?
      buildIpa: true,
      ipaExportMethod: flavor.ipaExportMethod,
      ipaName: "${app.name}-${BUILD_ID}-${flavorId}",
      ipaOutputDirectory: '',
      ipaManifestPlistUrl: '',
      thinning: '',
      appURL: '',
      displayImageURL: '',
      fullSizeImageURL: '',
      assetPackManifestURL: '',
      
      // Manual signing?
      manualSigning: true,
      
      developmentTeamName: 'none (specify one below)',
      developmentTeamID: flavor.developmentTeamID ?: app.prodTeamID,
      
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
      xcodeSchema: app.xcodeSchema ?: app.name,
      sdk: '',
      symRoot: '',
      xcodebuildArguments: 'VALID_ARCHS="armv7 armv7s arm64" -allowProvisioningUpdates' +
         " -derivedDataPath ~/ciderivedData/${derivedDir}/${branchName}/${flavorId}",
      xcodeWorkspaceFile: xcodeParams.workspaceFile,
      xcodeProjectPath: '',
      xcodeProjectFile: '',
      buildDir: "${WORKSPACE}/build",
      
      // Versioning
      provideApplicationVersion: false,
      cfBundleShortVersionStringValue: '',
      cfBundleVersionValue: ''

    archiveArtifacts allowEmptyArchive: true, artifacts: "${app.name}-logs/*.log"
}

def publishToArtifactory = { app, classifier ->
    STAGE_NAME = 'Build (test): Publish to Artifactory'
    
    sh "find build -type d -name '*.dSYM' > dsymFiles"
    sh "zip -r -@ build/dsym.zip < dsymFiles"

    def artifactPath = "turkcell-development/${groupPath}/${app.name}/${app.version}"
    def artifactName = "${app.name}-${app.version}-${classifier}"

    def outputsDir = 'build'
    sh "ls -l ${outputsDir}/*.ipa"
    def uploadSpec = """{
        "files": [
            {
            "pattern": "${outputsDir}/${app.name}-*.ipa",
            "target": "${artifactPath}/${artifactName}.ipa"
            },
            {
            "pattern": "${outputsDir}/dsym.zip",
            "target": "${artifactPath}/${artifactName}-dsym.zip"
            }
        ]}"""
    def buildInfo = artifactory.upload(uploadSpec)
    def ipaUrl = "${artifactory.url}/${artifactPath}/${artifactName}.ipa"
    def dsymUrl = "${artifactory.url}/${artifactPath}/${artifactName}-dsym.zip"
    createSummary icon:'package.png', text:"<a href=\"${ipaUrl}\">${artifactName}.ipa</a>"
    createSummary icon:'package.png', text:"<a href=\"${dsymUrl}\">${artifactName}-dsym.zip</a>"
}

def deployToIctStore = { app ->
    def artifactPath = "turkcell-development/${groupPath}/${app.name}/${app.version}"
    def ipaFile = "ictstore.ipa"
    def manifestFile = "manifest.plist"
    def ipaUrl = "${artifactory.url}/${artifactPath}/${app.name}-${app.version}-test.ipa"
    def ictsBundleIdentifier = flavors['test'].bundleIdentifier
    sh "curl -v ${ipaUrl} -o ${ipaFile}"

    writeFile file:manifestFile, text:"""<?xml version="1.0" encoding="UTF-8"?> <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"> <plist version="1.0"> <dict> <key>items</key> <array> <dict> <key>assets</key> <array> <dict> <key>kind</key> <string>software-package</string> <key>url</key> <string>http://ictstore.turkcell.com.tr/repositorystatic/files/1/${app.ictsContainerId}/content/${ipaFile}</string> </dict> </array> <key>metadata</key> <dict> <key>bundle-identifier</key> <string>${app.ictsBundleIdentifier}</string> <key>bundle-version</key> <string>${app.version}</string> <key>kind</key> <string>software</string> <key>subtitle</key> <string>adhoc</string> <key>title</key> <string>${app.name}</string> </dict> </dict> </array> </dict> </plist>"""

    def ictsUpdateUrl = 'http://ictstore.turkcell.com.tr/RepositoryAdmin/rest/containers/updateFile'
    sh "curl -v -f -i -X POST -F pList=@${manifestFile} -F ipa=@${ipaFile} ${ictsUpdateUrl}?containerId=${app.ictsContainerId}"
    sh "echo ${app.name}-${app.version}-test.ipa deployed to ICT Store"
}

def deployToTestflight = { app ->
    def uploadCommand = 'run upload_to_testflight skip_submission:true skip_waiting_for_build_processing:true'
    def ipaFile = "build/${app.name}-${BUILD_ID}-prod.ipa"
    
    def artifactPath = "turkcell-development/${groupPath}/${app.name}/${app.version}"
    def ipaUrl = "${artifactory.url}/${artifactPath}/${app.name}-${app.version}-prod.ipa"
    sh "curl -v ${ipaUrl} -o ${ipaFile}"

    sh """
        export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=${TESTFLIGHT_UPLOAD_PSW}
        ~/.fastlane/bin/fastlane ${uploadCommand} ipa:"${ipaFile}" apple_id:"${app.appleId}" username:"${TESTFLIGHT_UPLOAD_USR}"
    """
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
                DELIVER_ITMSTRANSPORTER_ADDITIONAL_UPLOAD_PARAMETERS = "-t HTTP"
                IOS_PASS = credentials('iosLoginPass')
            }
            steps {
                script {
                    STAGE_NAME = 'Build : Init'
                    
                    def scmVars = checkout scm
                    def gitUrl = scmVars.GIT_URL.trim()
                    echo "git url: ${gitUrl}"
                    sh 'rm -rf build'
                    sh " rm -rf ~/ciderivedData/${derivedDir}"

                    stage('Build for Enterprise') {
                        STAGE_NAME = 'Pre-Build Checks'

                        apps.each readVersion

                        sh 'Pods/SwiftLint/swiftlint --reporter checkstyle > swiftlint-report.xml || true'
                        checkstyle defaultEncoding: '', healthy: '', pattern: 'swiftlint-report.xml', unHealthy: '',
                            useStableBuildAsReference: true
                        
                        STAGE_NAME = 'Build : Compile'

                        // sh "gem install cocoapods-art --user-install"
                        // sh 'pod repo-art add CocoaPods "https://artifactory.turkcell.com.tr/artifactory/api/pods/CocoaPods"'
                        sh "sudo xcode-select -switch /Applications/${xcodeParams.xcodeApp}/Contents/Developer"
                        sh "source ~/.bash_profile; cd Depo; pod install" // --repo-update occasionally
                        apps.each { app ->
                            runXcode(app, 'test')
                            publishToArtifactory(app, 'test')
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
        stage('Approve Deploy to ICT Store') {
            options { timeout(time: 24, unit: 'HOURS') }
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
                    apps.each deployToIctStore
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
        stage('Approve Build for Appstore') {
            options { timeout(time: 24, unit: 'HOURS') }
            steps {
                script {
                    try {
                        if (!isDev) {
                            input ok:'Yes', message:'Build for Appstore?' //, submitter: "${ictsDeployers}"
                        }
                        env.BUILD_TARGET = 'Appstore'
                        echo "Build for Appstore is approved. Starting build..."

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
           }
            steps {
                script {
                    apps.each { app ->
                        runXcode(app, 'prod')
                        publishToArtifactory(app, 'prod')
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
        stage('Approve Deploy to Testflight') {
            options { timeout(time: 24, unit: 'HOURS') }
            when {
                beforeAgent true
                environment name: 'BUILD_TARGET', value: 'Appstore'
            }
            steps {
                script {
                    try {
                        def parameters = apps.collect { app -> booleanParam(name: "DEPLOY_${app.name}", defaultValue: true, description: '') }
                        parameters << choice(name: 'DEPLOY_TO', choices: 'Testflight', description: '')
                        def approvals = input ok:'Yes', message:'Deploy?', parameters: parameters //, submitter: "${testFlightDeployers}"
                        approvals.each { key, value -> env.setProperty(key,value) }
                        echo "Approved: ${approvals}. Starting the deployment..."

                    } catch(err) {
                        env.DEPLOY_TO = ''
                        echo err.toString()
                    }
                }
            }
        }
        stage('Deploy to Testflight') {
            when {
                beforeAgent true
                environment name: 'DEPLOY_TO', value: 'Testflight'
            }
            agent { label agentName }
            options {
                skipDefaultCheckout true
            }
            environment {
                IOS_PASS = credentials('iosLoginPass')
                DELIVER_ITMSTRANSPORTER_ADDITIONAL_UPLOAD_PARAMETERS = "-t HTTP"
                TESTFLIGHT_UPLOAD = credentials('testflight')
                FASTLANE_DONT_STORE_PASSWORD = 1
           }
            steps {
                script {
                    sh returnStdout: true, script: 'rm -f ~/.itmstransporter/UploadTokens/*.token'
                    def failReasons = [:]
                    apps.each { app ->
                        try {
                            if (env.getProperty("DEPLOY_${app.name}") == 'true') {
                                deployToTestflight app
                            }

                        } catch (Exception e) {
                            failReasons[app.name] = e.message
                        }
                    }
                    if (failReasons) {
                        error "Fail reasons: ${failReasons}"
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
