Rye.extend(function (global) {

    var selectorRE = /^([.#]?)([\w\-]+)$/
     ,  selectorType = {
            '.': 'getElementsByClassName'
          , '#': 'getElementById'
          , '' : 'getElementsByTagName'
          , '_': 'querySelectorAll'
        }

    function qsa(element, selector) {
        var type

        if (
            !selector.match(selectorRE) 
         || (RegExp.$1 === '#' && element !== document)
        ) {
            type = selectorType._
        } else {
            type = selectorType[RegExp.$1]
            selector = RegExp.$2
        }

        return Rye.slice.call(element[type](selector))
    }

    return {
        qsa: qsa
    }
})