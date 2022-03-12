// UserAddPublickeyCheck.vue

<script>
export default {
  data: () => ({
      publickeyTxt: '',
      publickeyOk: false,
      debug: false,
      info: null
  }),

  methods: {

    goBack: function () {
      this.debug && console.log(' -> KeyCheck Back')
      this.publickeyTxt = ''
      this.publickeyOk  = false
      this.$emit('on-prev', { publickey: this.publickeyTxt, ok: this.publickeyOk })
    },


    goNext: function () {
      this.debug && console.log(' -> KeyCheck Continue')
      this.$emit('on-next', { publickey: this.publickeyTxt, ok: this.publickeyOk })
    },

    onPublickeyCheck: function () {
      if ( this.publickeyTxt.length )
      {
        let self = this
        self.publickeyOk = false
        console.log(' Public key (check): ' + self.publickeyTxt );
        self.$http
        .get('/api/v1/user/keycheck?public=' + self.publickeyTxt )
        .then( response => {
            self.info = response.data;
            if ( response.data.code == 200 )
            {
              self.publickeyOk = true
            }
        })
      }
    }
  },

  mounted: async function() {
    console.log('UserAddPublicKeyCheck->mounted()');
  }
}
</script>

<template>
  <div>

    <p>
      An Open-SSH formatted public key contains two pieces separted by a space.
      The first part is entirely based on the type of key, it indicated the type of key.
      The second part is the actual key encoded as BAS64.
      <ul>
       <li>Part 1 example: ssh-ed25519</li>
       <li>Part 2 example: AAAA and a lot more characters.</li>
       <li>Part 3 optional: comments we wont use.</li>
      </ul>
    </p>

    <label for="idpublickey">Enter SSH Public Key:</label>
    <b-form-input id="idpublickey" :state="publickeyOk" type="text" autofocus
      v-on:change="onPublickeyCheck"
      v-on:blur="onPublickeyCheck"
      v-model="publickeyTxt"
      placeholder="Enter a SSH Public key to authenticate your login."
    ></b-form-input>
    <p v-if="publickeyOk" class="text-success">Success, please continue</p>
    <p v-else class="text-danger">A useable public key show Green.</p>

    <b-button variant="success" v-on:click="goBack">Prev</b-button>
    <b-button variant="success" v-on:click="goNext" class="mr-2" :disabled="! publickeyOk">
      Next
    </b-button>

  </div>
</template>

<style scoped>

.mr-2 {
  margin-left: 0.5em;
}

</style>

// END
