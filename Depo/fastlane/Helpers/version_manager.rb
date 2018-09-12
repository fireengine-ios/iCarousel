# version_manager.rb
module Fastlane

  class VersionManager

    def self.get_build_number_my(params)
      folder = params[:xcodeproj] ? File.join(params[:xcodeproj], '..') : '.'
      target_name = params[:target]
      configuration = params[:configuration]

      # Get version_number
      project = get_project!(folder)
      target = get_target!(project, target_name)
      plist_file = get_plist!(folder, target, configuration)
      version_number = get_version_number!(plist_file)

      # Store the number in the shared hash
      Actions.lane_context[Actions::SharedValues::BUILD_NUMBER] = version_number

      # Return the version number because Swift might need this return value
      return version_number
    end

    def self.set_build_number(params)
      folder = params[:xcodeproj] ? File.join(params[:xcodeproj], '..') : '.'
      target_name = params[:target]
      configuration = params[:configuration]
      new_number = params[:new_number]

      # Get version_number
      project = get_project!(folder)
      target = get_target!(project, target_name)
      plist_file = get_plist!(folder, target, configuration)
      save_version_number!(plist_file, new_number)

      # Store the number in the shared hash
      Actions.lane_context[Actions::SharedValues::BUILD_NUMBER] = new_number
    end

    private_class_method def self.get_project!(folder)
      # require 'xcodeproj'
      project_path = Dir.glob("#{folder}/*.xcodeproj").first
      if project_path
        return Xcodeproj::Project.open(project_path)
      else
        UI.user_error!("Unable to find Xcode project in folder: #{folder}")
      end
    end

    private_class_method def self.get_target!(project, target_name)
      targets = project.targets

      # Prompt targets if no name
      unless target_name

        # Gets non-test targets
        non_test_targets = targets.reject do |t|
          # Not all targets respond to `test_target_type?`
          t.respond_to?(:test_target_type?) && t.test_target_type?
        end

        # Returns if only one non-test target
        if non_test_targets.count == 1
          return targets.first
        end

        options = targets.map(&:name)
        target_name = UI.select("What target would you like to use?", options)
      end

      # Find target
      target = targets.find do |t|
        t.name == target_name
      end
      UI.user_error!("Cannot find target named '#{target_name}'") unless target

      target
    end

    private_class_method def self.get_plist!(folder, target, configuration = nil)
      plist_files = target.resolved_build_setting("INFOPLIST_FILE")
      plist_files_count = plist_files.values.compact.uniq.count

      # Get plist file for specified configuration
      # Or: Prompt for configuration if plist has different files in each configurations
      # Else: Get first(only) plist value
      if configuration
        plist_file = plist_files[configuration]
      elsif plist_files_count > 1
        options = plist_files.keys
        selected = UI.select("What build configuration would you like to use?", options)
        plist_file = plist_files[selected]
      else
        plist_file = plist_files.values.first
      end

      # $(SRCROOT) is the path of where the XcodeProject is
      # We can just set this as empty string since we join with `folder` below
      if plist_file.include?("$(SRCROOT)/")
        plist_file.gsub!("$(SRCROOT)/", "")
      end

      plist_file = File.absolute_path(File.join(folder, plist_file))
      UI.user_error!("Cannot find plist file: #{plist_file}") unless File.exist?(plist_file)

      plist_file
    end

    private_class_method def self.get_version_number!(plist_file)
      plist = Xcodeproj::Plist.read_from_path(plist_file)
      UI.user_error!("Unable to read plist: #{plist_file}") unless plist
      return plist["CFBundleVersion"]
    end

    private_class_method def self.save_version_number!(plist_file, new_number)
      plist = Xcodeproj::Plist.read_from_path(plist_file)
      UI.user_error!("Unable to read plist: #{plist_file}") unless plist

      plist["CFBundleVersion"] = new_number
      Xcodeproj::Plist.write_to_path(plist, plist_file)
    end

  end

end