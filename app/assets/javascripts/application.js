// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require lib/underscore
//= require lib/backbone
//= require lib/marionette
//= require_tree ./lib
//= require handlebars.runtime
//= require ./strophe/base64
//= require ./strophe/md5
//= require ./strophe/sha1
//= require ./strophe/core
//= require_tree ./strophe
//= require backbone.wreqr
//= require backbone.marionette.handlebars
//= require js-routes
//= require_tree ./vendor
//= require_tree ./backbone/config
//= require backbone/app
//= require_tree ./backbone/controllers
//= require_tree ./backbone/views
//= require_tree ./backbone/entities
//= require_tree ./backbone/components
//= require_tree ./backbone/apps
//= require jquery-fileupload/basic
//= require backbone/init_app

$(document).ready(function(){
  $("#first-time-user").delay(300000).fadeOut();

  $("#first-time-user-close").click(function(e){
    e.preventDefault();
    $("#first-time-user").hide();
  });

  $(".close-trial-end").click(function(e){
    e.preventDefault();
    $(".trial-window").remove();
    $(".modal-backdrop").hide();
    mixpanel.track("Close Trial Over Modal");
  });

  $(".trial-free").click(function(e){
    e.preventDefault();
    $(".trial-window").remove();
    $(".modal-backdrop").hide();
    mixpanel.track("Continue Using Free Version");
  });

  $(".trial-pricing").click(function(e){
    $(".trial-window").remove();
    $(".modal-backdrop").hide();
    mixpanel.track("Click Plans and Pricing From Trial Over Modal");
  });
});
