class WebsiteSettings < RailsSettings::SettingObject
  validate do

    if self.var == 'pre_chat' || self.var == 'post_chat' || self.var == 'offline'
      if self.description.blank?
        errors.add(:description, " should not be blank")
      elsif self.description.length > 140
        errors.add(:description, " should not exceed 140 characters")
      end

      if self.var == 'offline' || self.var == 'post_chat'
        if self.email.blank? || self.email.nil?
          errors.add(:email, " should not be blank")
        elsif !valid_email?(self.email)
          errors.add(:email, " is invalid")
        end
      end
    end

    if self.var == "online"
      if self.agent_label.blank?
        errors.add(:widget_label, " should not be blank")
      end
    end

  end

  def valid_email?(email)
    em = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    email =~ em
  end

end
