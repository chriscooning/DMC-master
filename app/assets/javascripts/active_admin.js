//= require active_admin/base
//= require jquery-ui/core
//= require jquery-ui/widget
//= require libs/jquery.datetimepicker
//= require redactorjs-rails/redactor

$(function(){
  $(".pickdate").datetimepicker();
  $(".redactor").redactor({ minHeight: 350 });



  $('.member_link.delete_link').on('click', function(e){
    var message = $(e.currentTarget).data('delete-prompt');
    result = prompt(message);

    if (result !== 'DELETE'){
      e.preventDefault();
      return false;
    } else {
      return true;
    }
  })
})
