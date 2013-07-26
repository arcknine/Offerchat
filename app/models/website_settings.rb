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
          # website = Website.find(self.target_id)
          # website.errors[:description] << " is required"
        end
    end
  end
end