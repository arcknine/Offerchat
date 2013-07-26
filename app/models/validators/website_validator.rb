class WebsiteValidator < ActiveModel::Validator

  def validate(website)
    if website.settings(:offline).enabled
      if website.settings(:offline).description.blank?
        website.errors[:description] << " is required"
      end
    end
  end

end