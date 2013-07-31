require 'net/http'
class DripWorker
  include Sidekiq::Worker

  def register_to_drip_campaign(email, name)  
    url = URI.parse 'http://drip.offerchat.com/api/actions/create_user'
    req = Net::HTTP::Post.new url.path
    req.basic_auth 'admin','0ff3rch@t'
    req.set_form_data 'email' => email, 'name' => name
    resp = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) } 
  rescue
    false
  end

  def perform(id)
    user = User.find(id)
    self.register_to_drip_campaign user.email, user.name
  end
end
