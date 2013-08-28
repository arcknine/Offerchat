attributes :id, :api_key, :name, :url, :owner_id, :created_at, :updated_at, :unread

node do |website|
  {
    :settings => {
      :style => {
        :theme    => website.settings(:style).theme,
        :position => website.settings(:style).position,
        :rounded  => website.settings(:style).rounded,
        :gradient => website.settings(:style).gradient
      },
      :online => {
        :header      => website.settings(:online).header,
        :agent_label => website.settings(:online).agent_label,
        :greeting    => website.settings(:online).greeting,
        :placeholder => website.settings(:online).placeholder
      },
      :pre_chat => {
        :enabled          => website.settings(:pre_chat).enabled,
        :message_required => website.settings(:pre_chat).message_required,
        :email_required => website.settings(:pre_chat).email_required,
        :header           => website.settings(:pre_chat).header,
        :description      => website.settings(:pre_chat).description
      },
      :post_chat => {
        :enabled     => website.settings(:post_chat).enabled,
        :header      => website.settings(:post_chat).header,
        :description => website.settings(:post_chat).description,
        :email       => website.settings(:post_chat).email
      },
      :offline => {
        :enabled     => website.settings(:offline).enabled,
        :header      => website.settings(:offline).header,
        :description => website.settings(:offline).description,
        :email       => website.settings(:offline).email
      },
      :footer => {
        :enabled     => website.settings(:footer).enabled
      }
    }
  }
end
