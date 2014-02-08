attributes :id, :api_key, :name, :url, :owner_id, :created_at, :updated_at, :unread, :new, :plan, :attention_grabber

node do |website|
  {
    :settings => {
      :style => {
        :theme    => website.settings(:style).theme,
        :position => website.settings(:style).position,
        :rounded  => website.settings(:style).rounded,
        :gradient => website.settings(:style).gradient,
        :language => website.settings(:style).language
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
        :email_required   => website.settings(:pre_chat).email_required,
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
      },
      :grabber => {
        :enabled     => website.settings(:grabber).enabled,
        :uploaded    => website.settings(:grabber).uploaded,
        :name        => website.settings(:grabber).name,
        :src         => website.settings(:grabber).src,
        :height      => website.settings(:grabber).height,
        :width       => website.settings(:grabber).width
      },
      :zendesk => {
        :company     => website.settings(:zendesk).company,
        :username    => website.settings(:zendesk).username,
        :token       => website.settings(:zendesk).token
      }
    }
  }
end
