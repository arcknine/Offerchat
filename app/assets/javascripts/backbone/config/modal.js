 var ModalRegion = Backbone.Marionette.Region.extend({
  el: "#modal",

  constructor: function(){
    _.bindAll(this);
    Backbone.Marionette.Region.prototype.constructor.apply(this, arguments);
    this.on("view:show", this.showModal, this);
  },

  getEl: function(selector){
    var $el = $(selector);
    $el.on("hidden", this.close);
    return $el;
  },

  showModal: function(view){
    this.show(view)
    view.on("close", this.hideModal, this);
    // this.$el.modal('show');
    this.$el.removeClass("hide");
    $("#modal-backdrop").removeClass("hide");
  },

  hideModal: function(){
    // this.$el.modal('hide');
    this.$el.addClass("hide");
    $("#modal-backdrop").addClass("hide");
    this.close()
  }
});