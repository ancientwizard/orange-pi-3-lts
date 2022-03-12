import Vue from 'vue'
import VueCompositionAPI, { createApp, h } from '@vue/composition-api'
import { BootstrapVue, IconsPlugin } from 'bootstrap-vue'
import Axios from 'axios'

// Import Bootstrap an BootstrapVue CSS files (order is important)
import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'

// Make BootstrapVue available throughout your project
Vue.use(BootstrapVue)
// Optionally install the BootstrapVue icon components plugin
Vue.use(IconsPlugin)

import App from './App.vue'

Vue.use(VueCompositionAPI)

Vue.prototype.$http	= Axios

const app = createApp({
  render: () => h(App)
})

app.mount('#app')
