

module Xcodeproj
    class Project
        module Object
            class PBXGroup
                def isPodGroup
                    @isPodGroup
                end
                def setIsPodGroup(isRealPod)         
                    @isPodGroup = isRealPod
                end
            end
        end
    end
end


module Pod
    def self.skipped_top_level_folder_names
        @skipped_top_level_folder_names
    end
    def self.set_skipped_top_level_folder_names(names)         
        @skipped_top_level_folder_names = names
    end
end



require 'pathname'

module Pod
  class Project

    # return the absolute path of podfile
    def pod_file_path
        File.expand_path("../..", path)
    end
    
    def get_parent_development_pod_group(pod_name, path)

        basePath = Pathname.new pod_file_path
        targetPath = Pathname.new path
        relativePath = targetPath.relative_path_from basePath
        parentPath = relativePath.dirname.to_s

        def getGroup(pathArray, rootGroup)
            if pathArray.empty?
                return rootGroup
            end
            headName = pathArray[0]
            g = rootGroup.children.objects.find do |group|
                group.name == headName and !group.isPodGroup
            end
            if g == nil
                g = rootGroup.new_group(headName, nil, :group)
                g.setIsPodGroup false
            end
            return getGroup(pathArray[1..-1], g)
        end
        pathArray = parentPath.split("/").select {|component| component.length > 0}
        if parentPath == "." 
            pathArray = []
        end
        if pathArray.first != nil and Pod.skipped_top_level_folder_names.include? pathArray.first
            pathArray = pathArray.drop(1)
        end
        
        getGroup(pathArray, development_pods)
    end

  end
end
