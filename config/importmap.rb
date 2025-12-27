# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "index", to: "index.js"
pin "slim-select", to: "https://unpkg.com/slim-select@2.8.2/dist/slimselect.es.js"
pin "custom/task_form", to: "custom/task_form.js"