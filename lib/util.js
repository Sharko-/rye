Rye.define('util', function (rye) {

    function extend(dest, src) {
        for (var key in src){
            if (Object.prototype.hasOwnProperty.call(parent, key)){
                dest[key] = src[key]
            }
        }
        return dest
    }

    function inherits(child, parent) {
        extend(child, parent)
        function Ctor() {
            this.constructor = child
        }
        Ctor.prototype = parent.prototype
        child.prototype = new Ctor()
        child.__super__ = parent.prototype
        return child
    }

    return {
        extend: extend
      , inherits: inherits
    }

})