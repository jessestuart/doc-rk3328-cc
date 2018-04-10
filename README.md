### ROC-RK3328-CC Manual

This is the manual repo of ROC-RK3328-CC board.

The manual can be built by:

```bash
sudo apt-get install virtualenv
virtualenv --python=python3 sphinx-markdown
source sphinx-markdown/bin/activate
pip install -r requirements.txt
make html
# open _build/html/index.html
```
(Tested in Ubuntu 16.04)

Special thanks to [sphinx-markdown-test](https://github.com/ericholscher/sphinx-markdown-test).
