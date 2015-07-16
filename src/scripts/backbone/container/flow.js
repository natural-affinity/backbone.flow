/* globals */
'use strict';

var Backbone = Backbone || {};
Backbone.Container = Backbone.Container || {};

Backbone.Container.Flow = Backbone.View.extend({
  constructor: function () {
    this.next = null;
    this.current = null;
    this.views = [];

    //super (constructor)
    Backbone.View.apply(this, arguments);
  },
  render: function () {
    this.show();
    return this;
  },
  show: function () {
    if (this.current) {
      this.current.undelegateEvents();
    }

    this.current = this.next;
    this.next = null;
    this.current.delegateEvents().render();
  },
  remove: function () {
    this.next = null;
    this.current = null;

    if (this.vent) {
      this.vent = null;
    }

    while (this.views.length > 0) {
      var view = this.views.pop();
      view.remove();
      view.hook = null;
      view = null;
    }//cleanup (DOM events, listenTo events, references)

    //cleanup container (self)
    Backbone.View.prototype.remove.call(this);
  }
});
