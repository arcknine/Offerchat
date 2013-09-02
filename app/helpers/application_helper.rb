module ApplicationHelper
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def user_report_js
    js = <<-eos
      <script type="text/javascript">
        var _urq = _urq || [];
        _urq.push(['initSite', '26766dd5-76ba-4120-82a1-42891400b103']);

        (function() {
          var ur = document.createElement('script'); ur.type = 'text/javascript'; ur.async = true;
          ur.src = ('https:' == document.location.protocol ? 'https://d1chfpa9hnx6ug.cloudfront.net/userreport.js' : 'http://sdscdn.userreport.com/userreport.js');
          var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ur, s);
        })();
      </script>
    eos
    js.html_safe
  end

  def ofc_js
    js = <<-eos
      <!--start of Offerchat js code-->
      <script type='text/javascript'>var ofc_key = 'd797224b4535d5943c6b5f83941e7374';
      (function(){  var oc = document.createElement('script'); oc.type = 'text/javascript';
      oc.async = true;  oc.src = ('https:' == document.location.protocol ? 'https://' : 'http://') +
      'd1cpaygqxflr8n.cloudfront.net/p/js/widget.min.js?r=1';
      var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(oc, s);}());
      </script><!--end of Offerchat js code-->
    eos
    js.html_safe
  end
end
