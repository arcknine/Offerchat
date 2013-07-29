class WebsiteSettings < RailsSettings::SettingObject
  validate do
    case self.var
      # when "style"
      # when "onine"
      # when "pre_chat"
      # when "post_chat"

      when "offline"
        if self.description.blank?
          errors.add(:description, " should not be blank")
        elsif self.description.length > 140
          errors.add(:description, " should not exceed 140 characters")
        end

        if self.email.blank?
          errors.add(:email, " should not be blank")
        elsif !valid_email?(self.email)
          errors.add(:email, " is invalid")
        end
    end
  end

  def valid_email?(email)
    em = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    email =~ em
  end

end