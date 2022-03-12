// UserAddLoginCheck.vue

<script>
export default {
  data: () => ({
      lognameTxt: '',
      lognameOk: false,
      debug: false,
      info: null
  }),

  methods: {

    goBack: function () {
      this.debug && console.log(' -> LoginCheck Back')
      this.lognameTxt = ''
      this.lognameOk  = false
      this.$emit('on-prev', { logname: this.lognameTxt, ok: this.lognameOk })
    },

    goNext: function () {
      this.debug && console.log(' -> LoginCheck Continue')
      this.$emit('on-next', { logname: this.lognameTxt.toLowerCase(), ok: this.lognameOk })
    },

    onLognameCheck: function () {
      if ( this.lognameTxt.length )
      {
        let self = this
        self.lognameOk = false
        console.log(' Loginname (check): ' + self.lognameTxt.toLowerCase() );
        self.$http
          .get('/api/v1/user/status?username=' + self.lognameTxt.toLowerCase() )
          .then( response => {
              self.info = response.data;
              if ( response.data.code == 404 )
              {
                self.lognameOk = true
              }
          })
      }
    }
  },

  mounted: async function() {
    console.log('UserAddLoginCheck->mounted()');
  }
}
</script>

<template>
  <div>
    <p>
      Try using a firstnamea or, first initial and last-name. all lowercase, or make
      someting up. It just needs to be unique and not overlap a system account.
      Examples: bob, mike or frank, chicklittle. Have fun!
    </p>

    <label for="idlogname">Desired login name:</label>
    <b-form-input id="idlogname" :state="lognameOk" type="text" autofocus
      v-on:change="onLognameCheck"
      v-on:blur="onLognameCheck"
      v-model="lognameTxt"
      placeholder="Enter a login username"
    ></b-form-input>
    <p v-if="lognameOk" class="text-success">Success, please continue</p>
    <p v-else class="text-danger">An available login username will show Green.</p>

    <b-button variant="success" v-on:click="goBack">Prev</b-button>
    <b-button variant="success" v-on:click="goNext" class="mr-2" :disabled="! lognameOk">
      Next
    </b-button>

    <div v-if="debug">{{ info }}</div>

  </div>
</template>

<style scoped>

.mr-2 {
  margin-left: 0.5em;
}

</style>

// END
