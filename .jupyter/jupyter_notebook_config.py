# Configuration file for jupyter-notebook.

## Whether to allow the user to run the notebook as root.
# c.NotebookApp.allow_root = False

## Whether to open in a browser after starting. The specific browser used is
#  platform dependent and determined by the python standard library `webbrowser`
#  module, unless it is overridden using the --browser (NotebookApp.browser)
#  configuration option.
#  Default: True
c.NotebookApp.open_browser = False

## The port the notebook server will listen on (env: JUPYTER_PORT).
# c.NotebookApp.port = 8888

## Allow access to hidden files
# c.ContentsManager.allow_hidden = False

## Glob patterns to hide in file and directory listings.
# c.ContentsManager.hide_globs = ['__pycache__', '*.pyc', '*.pyo', '.DS_Store', '*.so', '*.dylib', '*~']
# c.FileContentsManager.hide_globs = c.ContentsManager.hide_globs
