var cell = Jupyter.notebook.get_selected_cell();
cell.config.update({
  CodeCell: {
    cm_config: {
      autoCloseBrackets: false,
    }
  }
});
