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
      <script type='text/javascript'>var ofc_key = '87f13f29aad8db0985044b0395964087';
      (function(){  var oc = document.createElement('script'); oc.type = 'text/javascript';
      oc.async = true;  oc.src = ('https:' == document.location.protocol ? 'https://' : 'http://') +
      'd1cpaygqxflr8n.cloudfront.net/p/js/widget.min.js?r=1';
      var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(oc, s);}());
      </script><!--end of Offerchat js code-->
    eos
    js.html_safe
  end

  def mixpanel_js
    js = <<-eos
     <!-- start Mixpanel -->
       <script type="text/javascript">(function(e,b){if(!b.__SV){var a,f,i,g;window.mixpanel=b;a=e.createElement("script");a.type="text/javascript";a.async=!0;a.src=("https:"===e.location.protocol?"https:":"http:")+'//cdn.mxpnl.com/libs/mixpanel-2.2.min.js';f=e.getElementsByTagName("script")[0];f.parentNode.insertBefore(a,f);b._i=[];b.init=function(a,e,d){function f(b,h){var a=h.split(".");2==a.length&&(b=b[a[0]],h=a[1]);b[h]=function(){b.push([h].concat(Array.prototype.slice.call(arguments,0)))}}var c=b;"undefined"!==
typeof d?c=b[d]=[]:d="mixpanel";c.people=c.people||[];c.toString=function(b){var a="mixpanel";"mixpanel"!==d&&(a+="."+d);b||(a+=" (stub)");return a};c.people.toString=function(){return c.toString(1)+".people (stub)"};i="disable track track_pageview track_links track_forms register register_once alias unregister identify name_tag set_config people.set people.set_once people.increment people.append people.track_charge people.clear_charges people.delete_user".split(" ");for(g=0;g<i.length;g++)f(c,i[g]);
b._i.push([a,e,d])};b.__SV=1.2}})(document,window.mixpanel||[]);
mixpanel.init("e4b9256e5d40beb875e772611927adb1");
      </script>
    <!-- end Mixpanel -->
    eos
    js.html_safe
  end

  def mixpanel_dev_js
    js = <<-eos
      <script type="text/javascript">
        function MixPanelMock(){
          this.track = track;
          this.identify = identify;
          this.alias = alias;
          this.people = new Object();
          this.get_distinct_id = get_distinct_id;
          function track(eventString){
            console.log(eventString);
          }
          function identify(params){
            console.log(params);
          }
          function get_distinct_id(){
            console.log("distinct");
          }
          function alias(params){
            console.log(params);
          }
          this.people.set = function(){};
        }
        window.mixpanel = new MixPanelMock();
      </script>
    eos
    js.html_safe
  end
end
