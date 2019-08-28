

Shiny.addCustomMessageHandler(
  "show_toast",
  function(message) {
    toastr[message.type](
      message.title,
      message.message
    )
  }
)

$(document).on("click", "#car_table .delete_btn", function() {
    Shiny.setInputValue("car_row_to_delete", this.id, { priority: "event"});
    $(this).tooltip('hide');
});

$(document).on("click", "#car_table .edit_btn", function() {
    Shiny.setInputValue("car_row_to_edit", this.id, { priority: "event"});
    $(this).tooltip('hide');
});
