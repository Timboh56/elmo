// ELMO.Report.EditPane
(function(ns, klass) {
  
  // constructor
  ns.EditPane = klass = function() {
  }
  
  klass.prototype.build = function() {
    // get refs
    this.cont = $("div.report_edit_pane." + this.title.replace(" ", "_").toLowerCase());
    this.error_box = this.cont.find("div.error_box")
  }
  
  klass.prototype.show = function() {
    this.cont.show();
  }

  klass.prototype.hide = function() {
    this.cont.hide();
  }
  
  klass.prototype.show_validation_errors = function() {
    var fields = this.fields_for_validation_errors ? this.fields_for_validation_errors() : [];
    var errors = [];
    for (var i = 0; i < fields.length; i++)
      errors = errors.concat(this.report.errors.get(fields[i]));
    this.has_errors = errors.length > 0;
    this.error_box.html(errors.join("<br/>"));
    this.error_box[this.has_errors ? "show" : "hide"]();
  }

}(ELMO.Report));