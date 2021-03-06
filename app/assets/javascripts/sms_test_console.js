// ELMO.SmsTestConsole
//
// Handles sending and displaying test SMS requests.
(function(ns, klass) {

  // constructor
  ns.SmsTestConsole = klass = function() { var self = this;
    self.form = $("form#new_sms_test");

    // attach to the form submit event
    self.form.on("submit", function(){ self.submit(); return false; })
  }
  
  klass.prototype.submit = function() { var self = this;
    $("form#new_sms_test .loading_indicator img").show();
    
    Utils.ajax_with_session_timeout_check({
      type: 'POST',
      url: self.form.attr("action"),
      data: self.form.serialize(),
      success: function(data) {
        $(".sms_test_result").html(data);
      },
      error: function() {
        $(".sms_test_result").html("<em>" + I18n.t("sms_console.submit_error") + "</em>");
      },
      complete: function() {
        // hide the loading indicator
        $("form#new_sms_test .loading_indicator img").hide();
        
        // show the header
        $(".sms_tests_new h2").show();
      }
    })
  }
  
})(ELMO);
