


function cars_table_module_js(ns_prefix) {

  $(document).on("click", "#" + ns_prefix + "-car_table .delete_btn", function() {
    Shiny.setInputValue(ns_prefix + "-car_id_to_delete", this.id, { priority: "event"});
    $(this).tooltip('hide');
  });

  $(document).on("click", "#" + ns_prefix + "-car_table .edit_btn", function() {
    Shiny.setInputValue(ns_prefix + "-car_id_to_edit", this.id, { priority: "event"});
    $(this).tooltip('hide');
  });
}

