// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import { registerFuiControllers } from "ui"
eagerLoadControllersFrom("controllers", application)
registerFuiControllers(application)
