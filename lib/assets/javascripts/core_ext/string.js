String.prototype.underscore_to_camel = function() {
  return this.replace(/_[a-z]/, function(m){ return m.substring(1).toUpperCase(); })
}

String.prototype.capitalize = function() {
  return this.replace(/^[a-z]/, function(m){ return m.toUpperCase(); })
}