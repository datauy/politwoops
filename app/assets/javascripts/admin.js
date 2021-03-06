$(document).ready(function() {

  $('#check_box_is_hit').change(function(e){
    e.preventDefault();
    var form = $('#is_hit_form');
    var form_data = form.serialize();
    var form_url = form.attr('action')

    if ($(this).is(":checked")) {
      form_data = form_data+"&is_hit=true" 
    } else {
      form_data = form_data+"&is_hit=false" 
    }

    $.ajax({
      type:"PUT",
      url: form_url,
      data: form_data,
    })
    .done(function(data) {
      console.log(data);
    })
    .fail(function(jqXHR, textStatus) {
      console.log(textStatus);
    });
  });

  $('.edit-input').on('click', function() {
    var formGroup = $(this).parentsUntil('.form-group').parent();
    var elementValue = ""

    formGroup.find('.input-controls input[type="text"]').each(function(index, element) {
      if (element.value != "" || element.value != null) {
        elementValue += element.value + " "
      }
    });

    if (elementValue != "") {
      formGroup.find('.display-label > span').text(elementValue.trim());
    }
    
    formGroup.find('.display-label').toggle()
    formGroup.find('.input-controls').toggle()
  });
});
