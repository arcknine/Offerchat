
class UrlValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    valid = begin
      URI.parse(value).kind_of?(URI::HTTP)
    rescue URI::InvalidURIError
      false
    end
    if value.to_s.include?("localhost")
      record.errors[attribute] << (options[:message] || "localhost is not allowed")
    end
    unless value.to_s.include?(".") || valid
      record.errors[attribute] << (options[:message] || "is an invalid URL")
    end

  end

end