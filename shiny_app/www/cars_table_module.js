


function cars_table_module_js(ns) {

  $(document).on("click", "#" + ns + "car_table .delete_btn", function() {
    Shiny.setInputValue(ns + "car_id_to_delete", this.id, { priority: "event"});
    $(this).tooltip('hide');
  });

  debugger;

  $(document).on("click", "#" + ns + "car_table .edit_btn", function() {
    Shiny.setInputValue(ns + "car_id_to_edit", this.id, { priority: "event"});
    $(this).tooltip('hide');
  });
}

