#!/bin/sh
sudo chmod -R 777 /var/app/current/vendor/bundle/ruby/*/gems/wkhtmltopdf-binary-*
sudo chmod -R 777 /var/app/staging/vendor/bundle/ruby/*/gems/wkhtmltopdf-binary-* || true
