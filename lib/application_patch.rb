require 'account_controller'
require 'ftools'

module AttachScreenshotPlugin
  module ApplicationControllerPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :attach_files, :screenshot
        alias_method_chain :find_current_user, :screenshot
      end
    end

  module InstanceMethods
   def find_current_user_with_screenshot
      if params[:controller] == "attach_screenshot" && request.post? && params[:key].present?
        User.find_by_rss_key(params[:key])
      else
        find_current_user_without_screenshot
      end
   end
   def attach_files_with_screenshot(obj, attachments)
      attached = []
      unsaved = []
      screenshots = params[:screenshots]
      if screenshots && screenshots.is_a?(Hash)
        screenshots.each_pair do |key, screenshot|
          key = key.gsub("thumb", "screenshot")
          path = "#{RAILS_ROOT}/tmp/" + key
          file = File.open(path, "rb")

          def file.content_type
            "image/png"
          end
          def file.size
            File.size(path())
          end
          def file.original_filename
            rand(36**8).to_s(36) + "screenshot.png"
          end

          next unless file && file.size > 0
          a = Attachment.create(:container => obj,
                                :file => file,
                                :description => screenshot['description'].to_s.strip,
                                :author => User.current)
          file.close()
          File.delete(path)
          key = key.gsub("screenshot", "thumb")
          path = "#{RAILS_ROOT}/tmp/" + key
          begin
            File.delete(path)
          rescue
          end
          a.new_record? ? (unsaved << a) : (attached << a)
        end
        if unsaved.any?
          flash[:warning] = l(:warning_attachments_not_saved, unsaved.size)
        end
      end
      attached
      attach_files_without_screenshot(obj, attachments)
    end
  end
  end
end
ApplicationController.send(:include, AttachScreenshotPlugin::ApplicationControllerPatch)
