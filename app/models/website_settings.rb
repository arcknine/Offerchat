class WebsiteSettings < RailsSettings::SettingObject
  validate do
    puts self.inspect
    case self.var
      # when "style"
      # when "onine"
      # when "pre_chat"
      # when "post_chat"

      when "offline"
        if self.description.blank?
          errors.add("description", " should not be blank")
        elsif self.description.length > 140
          errors.add("description", " should not exceed 140 characters")
        end
    end
  end
end