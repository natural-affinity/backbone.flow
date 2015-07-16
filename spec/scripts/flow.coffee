describe 'Flow', ->
  ModelType = Backbone.Model.extend({})

  FirstView = Backbone.View.extend
    className: 'one'
    initialize: (options) ->
      @hook = options.hook
      @listenTo(@model, 'model:one', @log)
    log: ->

  SecondView = Backbone.View.extend
    className: 'two'
    initialize: (options) ->
      @hook = options.hook
      @listenTo(@model, 'model:two', @log)
    log: ->

  FlowView = Backbone.Container.Flow.extend
    initialize: (options) ->
      @vent = options.vent
      @views = options.views || @views

      @listenTo(@views[0], 'sample:one', @switchToTwo)
      @listenTo(@views[1], 'sample:two', @switchToOne)

      @next = @views[0]
    switchToTwo: ->
      @next = @views[1]
      @show()
    switchToOne: ->
      @next = @views[0]
      @show()

  describe 'Dependencies', ->
    it 'requires backbone.js', -> expect(Backbone).toBeDefined()

  describe 'Namespaces', ->
    it 'requires Backbone', -> expect(Backbone).toBeDefined()
    it 'requires Backbone.$', -> expect(Backbone.$).toBeDefined()
    it 'requires Backbone.View', -> expect(Backbone.View).toBeDefined()
    it 'requires Backbone.Container', -> expect(Backbone.Container).toBeDefined()

  describe 'Constructor', ->
    flow = null

    beforeEach ->
      flow = new Backbone.Container.Flow()

    it 'extends Backbone.View', -> expect(flow).toEqual(jasmine.any Backbone.View)
    it 'does not set any child views', -> expect(flow.views.length).toBe 0
    it 'does not set the current view', -> expect(flow.current).toBeNull()
    it 'does not set the next view to show', -> expect(flow.next).toBeNull()
    it 'does not listen to any child view events', -> expect(flow._listeningTo).toBeUndefined()
    it 'executes the Backbone.View parent constructor', -> expect(flow.cid).not.toBeNull()

  describe '#show', ->
    [model, one, two, flow] = [null, null, null, null]

    beforeEach ->
      spyOn FirstView.prototype, 'log'
      spyOn SecondView.prototype, 'log'
      spyOn(FirstView.prototype, 'undelegateEvents').and.callThrough()
      spyOn(SecondView.prototype, 'delegateEvents').and.callThrough()
      spyOn(SecondView.prototype, 'render').and.callThrough()

      model = new ModelType()
      one = new FirstView({hook: {}, model: model})
      two = new SecondView({hook: {}, model: model})
      flow = new FlowView({views: [one, two], vent: {}})
      flow.show()
      one.trigger('sample:one')
      model.trigger('model:one')
      model.trigger('model:two')

    it 'sets the current view', -> expect(flow.current).toEqual two
    it 'sets the next view to null', -> expect(flow.next).toBeNull()
    it 'renders the new current view', -> expect(two.render).toHaveBeenCalled()
    it 'unbinds the DOM events of the previous view', -> expect(one.undelegateEvents).toHaveBeenCalled()
    it 'binds the DOM events of the new current view', -> expect(two.delegateEvents).toHaveBeenCalled()
    it 'allows child views to still respond to listenTo events', ->
      expect(one.log).toHaveBeenCalled()
      expect(two.log).toHaveBeenCalled()

  describe '#render', ->
    flow = null

    beforeEach ->
      flow = new Backbone.Container.Flow()
      spyOn flow, 'show'

    it 'is chainable', -> expect(flow.render()).toEqual flow
    it 'executes the show method', -> expect(flow.render().show).toHaveBeenCalled()

  describe '#remove', ->
    [model, one, two, flow] = [null, null, null, null]

    beforeEach ->
      spyOn SecondView.prototype, 'log'
      spyOn FlowView.prototype, 'switchToTwo'

      model = new ModelType()
      one = new FirstView({hook: {}, model: model})
      two = new SecondView({hook: {}, model: model})
      flow = new FlowView({views: [one, two], vent: {}})

      flow.remove()
      model.trigger('model:two')
      one.trigger('sample:one')

    it 'removes the reference to vent', -> expect(flow.vent).toBeNull()
    it 'removes the reference to the next view', -> expect(flow.next).toBeNull()
    it 'removes the reference to the current view', -> expect(flow.current).toBeNull()
    it 'removes the reference to every child view', -> expect(flow.views.length).toBe 0
    it 'removes the reference to the DOM hook for child views', -> expect(one.hook).toBeNull()
    it 'executes the Backbone.View.remove method for child views', -> expect(two.log).not.toHaveBeenCalled()
    it 'executes the Backbone.View.remove method for the container', -> expect(flow.switchToTwo).not.toHaveBeenCalled()
