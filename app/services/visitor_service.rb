class VisitorService
  include Vero::DSL

  def initialize(visitor)
    @visitor = visitor
    @website = @visitor.website
    @owner   = @website.owner
  end

  def generate_token
    begin
      random_token = SecureRandom.urlsafe_base64(nil, false)
    end while Visitor.where(token: random_token).exists?

    random_token
  end

  def generate_name
    'visitor-%06d' % rand(6 ** 6)
  end

  def track
    if @website.visitors.count < 1
      MIXPANEL.track "Install Widget", { :distinct_id => @owner.email }
      vero.events.track!({ :event_name => "Install Widget", :identity => { :email => @owner.email } })
      vero.users.edit_user!({ :email => @owner.email, :changes => { :widget_installed => true } })
      @owner.update_attribute(:widget_installed, true)
    end
  end
end
