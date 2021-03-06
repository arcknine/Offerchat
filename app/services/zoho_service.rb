class ZohoService
  def initialize(website_id, visitor, task)
    @website = Website.find(website_id)
    data     = @website.settings(:integrations).data

    RubyZoho.configure do |config|
      config.api_key = data["token"]
    end

    @visitor_name = visitor["name"]
    @visitor_email = visitor["email"]
    @visitor_phone = visitor["phone"]

    @task_subject = task["subject"]
    @task_description = task["description"]
    @task_priority = task["priority"]
    @task_status = task["status"]
  end

  def create_task(contact_id)
    t = RubyZoho::Crm::Task.new(
      :contactid    => contact_id,
      :subject      => @task_subject,
      :description  => @task_description,
      :priority     => @task_priority,
      :status       => @task_status
    )
    t.save
  end

  def create_update_contact
    cid = nil

    begin
      result = RubyZoho::Crm::Contact.find_by_last_name(@visitor_name)

      options = {}
      options[:email] = @visitor_email unless @visitor_email.blank?
      options[:phone] = @visitor_phone unless @visitor_phone.blank?

      if result.nil?
        options[:last_name] = @visitor_name
        c = RubyZoho::Crm::Contact.new(options)
        x = c.save
        cid = x.id
      else
        options[:id] = result.first.id
        c = RubyZoho::Crm::Contact.update(options)
        cid = c.id
      end
    rescue
    end

    cid

  end
end