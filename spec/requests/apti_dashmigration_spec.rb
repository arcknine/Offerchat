require 'spec_helper'

describe Dashmigrate::API do

let(:old_data) do
    '{
        "owner":
        {
          "id":"45", "email":"test@owner62.com", "firstname":"tomas", "lastname":"samot"
        },
        "websites":
        [
          {"name":"adidas.com", "url":"http://www.adidas.com",
            "agents":
            [
              {"firstname":"agent001", "lastname":"agent001", "display_name":"Support", "email":"agent61@test.com", "role":"3"},
              {"firstname":"agent002", "lastname":"agent002", "display_name":"Support", "email":"agent62@test.com", "role":"2"}
            ]
          },
          {"name":"nike", "url":"http://www.nike.com",
            "agents":
            [
              {"firstname":"agent003", "lastname":"agent003", "display_name":"Support", "email":"agent63@test.com" , "role":"3"},
              {"firstname":"agent004", "lastname":"agent004", "display_name":"Support", "email":"agent64@test.com", "role":"2"}
            ]
          }
        ]
        }'
  end


  describe "GET users data" do
    it "returns a json token" do
      get "/api/v1/migration/user"
      response.status.should == 200
    end
  end
end
