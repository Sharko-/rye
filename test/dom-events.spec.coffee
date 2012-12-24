assert = chai.assert

$ = Rye

DOMEventEmitter = Rye.require('DOMEventEmitter')

makeElement = (tagName, html, attrs) ->
    el = document.createElement(tagName)
    el.innerHTML = html
    el[key] = value for key, value of attrs
    return el

do_not_call = (event) ->
    assert.ok false, "Function shouldn't be called"

class Number.Counter
    constructor: (@index = 0) ->
    valueOf: -> @index
    toString: -> @index.toString()
    step: => ++@index

suite 'DOMEvents', ->

    test 'addListener', (done) ->
        div = makeElement('div')
        fn = (event) ->
            assert.equal event.data, 55
            done()

        DOMEventEmitter.addListener div, 'click', fn
        DOMEventEmitter.trigger div, 'click', 55

    test 'remove listener', (done) ->
        div = makeElement('div')
        counter = new Number.Counter

        DOMEventEmitter.addListener div, 'foo', do_not_call
        DOMEventEmitter.addListener div, 'buz', do_not_call
        DOMEventEmitter.addListener div, 'bar', counter.step
        DOMEventEmitter.removeListener div, 'foo'
        DOMEventEmitter.removeListener div, 'buz*'

        DOMEventEmitter.trigger div, 'bar'
        DOMEventEmitter.trigger div, 'buz'
        DOMEventEmitter.trigger div, 'foo'

        setTimeout ->
            assert.equal counter, 1
            done()
        , 0

    test 'remove listener in element without emitter', ->
        div = makeElement('div')
        DOMEventEmitter.removeListener div, 'foo'
        assert.ok true

    test 'remove listener trought selector', (done) ->
        el = $('#test .content').get(0)
        item = $('.a').get(0)
        counter = new Number.Counter

        DOMEventEmitter.addListener el, 'click li', counter.step
        DOMEventEmitter.addListener el, 'click ul', do_not_call
        DOMEventEmitter.addListener el, 'blur li', do_not_call
        DOMEventEmitter.addListener el, 'focus li', do_not_call
        DOMEventEmitter.removeListener el, 'click ul'
        DOMEventEmitter.removeListener el, 'blur *' 
        DOMEventEmitter.removeListener el, 'focus*' 

        DOMEventEmitter.trigger item, 'click'
        DOMEventEmitter.trigger item, 'blur'
        DOMEventEmitter.trigger item, 'focus'

        setTimeout ->
            assert.equal counter, 1
            done()
        , 0

    test 'remove listener trought handler', (done) ->
        div = makeElement('div')
        counter = new Number.Counter

        DOMEventEmitter.addListener div, 'click', do_not_call
        DOMEventEmitter.addListener div, 'click', counter.step
        DOMEventEmitter.removeListener div, '*', do_not_call

        DOMEventEmitter.trigger div, 'click'

        setTimeout ->
            assert.equal counter, 1
            done()
        , 0

    test 'remove all listeners', (done) ->
        div = makeElement('div')

        DOMEventEmitter.addListener div, 'click', do_not_call
        DOMEventEmitter.addListener div, 'focus', do_not_call
        DOMEventEmitter.addListener div, 'blur', do_not_call
        DOMEventEmitter.removeListener div, '*'

        DOMEventEmitter.trigger div, 'click'
        DOMEventEmitter.trigger div, 'focus'
        DOMEventEmitter.trigger div, 'blur'

        setTimeout (-> done()), 0

    test 'destroy emitter', (done) ->
        div = makeElement('div')
        emitter = new DOMEventEmitter(div)

        emitter.addListener('click', do_not_call)
            .addListener('focus', do_not_call)
            .addListener('blur',  do_not_call)
            .destroy()

        emitter.trigger 'click'
        emitter.trigger 'focus'
        emitter.trigger 'blur'

        setTimeout (-> done()), 0

    test 'accept multiple', (done) ->
        list = $('.list').get(0)
        emitter = new DOMEventEmitter(list)
        item = $('.a').get(0)
        counter = new Number.Counter

        emitter.on
            'click .a': counter.step
            'click': counter.step

        DOMEventEmitter.trigger item, 'click'

        setTimeout ->
            assert.equal counter, 2
            done()
        , 0

    test 'create event', ->
        event = DOMEventEmitter.createEvent type: 'click'
        assert.equal event.type, 'click'

        event = DOMEventEmitter.createEvent 'click', prop: 'value'
        assert.equal event.prop, 'value'

    test 'delegate', (done) ->
        list = $('.list').get(0)
        item = $('.a').get(0)
        counter = new Number.Counter
        fn = (event) ->
            counter.step()
            assert.equal event.currentTarget, document
            assert.equal event.target, item

        DOMEventEmitter.addListener document, 'click .a', fn

        DOMEventEmitter.trigger item, 'click'
        DOMEventEmitter.trigger list, 'click'
        DOMEventEmitter.trigger document, 'click'

        setTimeout ->
            assert.equal counter, 1
            done()
        , 0

    test 'remove delegate', (done) ->
        list = $('.list').get(0)
        item = $('.a').get(0)

        DOMEventEmitter.addListener document, 'click .a', do_not_call

        DOMEventEmitter.removeListener document, 'click .a'
        DOMEventEmitter.trigger item, 'click'

        setTimeout ->
            done()
        , 0

    test 'handler context', (done) ->
        list = $('.list').get(0)
        item = $('.a').get(0)
        counter = new Number.Counter

        DOMEventEmitter.addListener list, 'click .a', ->
            assert.equal @, item
            counter.step()

        DOMEventEmitter.addListener list, 'click', ->
            assert.equal @, list
            counter.step()

        DOMEventEmitter.trigger item, 'click'

        setTimeout ->
            assert.equal counter, 2
            done()
        , 0

    test 'Rye on', (done) ->
        itens = $('.list li')
        fn = (event) ->
            assert event.data is 55, "Argument received"
            done()

        itens.on 'click', fn
        itens.eq(2).trigger 'click', 55

    test 'Rye off', (done) ->
        itens = $('.list li')

        itens.on('blur', do_not_call).off 'blur'
        itens.trigger 'blur'

        setTimeout (-> done()), 0


