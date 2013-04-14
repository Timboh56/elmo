function broadcast_medium_changed() { 
  var select = $('#broadcast_medium')[0];
<<<<<<< HEAD
  var selected = select.options[select.selectedIndex].value
=======
  var selected = select.options[select.selectedIndex].value;
>>>>>>> 91db4a5e0e6c76c8de6e056acea8623922590e05
  var sms_possible = selected != "email_only" && selected != "";

  // hide/show char limit and subject
  if (sms_possible) {
    $('#char_limit').show();
    $('div#which_phone').show();
    broadcast_update_char_limit();
<<<<<<< HEAD
    $('#subject_row').hide();  
    $('#sms_balance').show(); 
=======
    $('div#subject').hide();
    $('.form_field#balance').show();
>>>>>>> 91db4a5e0e6c76c8de6e056acea8623922590e05
  } else {
    $('div#which_phone').hide();
    $('#char_limit').hide();
<<<<<<< HEAD
    $('#sms_balance').hide();
    $('#subject_row').show();
=======
    $('div#subject').show();
    $('.form_field#balance').hide();
>>>>>>> 91db4a5e0e6c76c8de6e056acea8623922590e05
  }
}




function broadcast_update_char_limit() {
  if ($('#char_limit').is(":visible")) {
    var diff = 140 - $('#broadcast_body').val().length;
    $('#char_limit').text(Math.abs(diff) + " characters " + (diff >= 0 ? "remaining" : "too many"));
    $('#char_limit').css("color", diff >= 0 ? "black" : "#d02000");
  }
}

<<<<<<< HEAD

$.ready(broadcast_medium_changed);       

                                                                                 
=======
$(document).ready(function() { $("#broadcast_medium").change(broadcast_medium_changed); $("#broadcast_medium").trigger("change"); })
>>>>>>> 91db4a5e0e6c76c8de6e056acea8623922590e05
