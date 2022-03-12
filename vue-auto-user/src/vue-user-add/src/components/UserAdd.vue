// UserAdd.vue

<script>
import LoginCheck  from './UserAddLoginCheck.vue'
import PubkeyCheck from './UserAddPublickeyCheck.vue'

export default {
  components: {
    LoginCheck, PubkeyCheck,
  //DocumentationIcon, ToolingIcon,
  //EcosystemIcon, CommunityIcon, SupportIcon
  },

  data: () => ({
        lognameTxt: '',
         lognameOk: false,
      publickeyTxt: '',
       publickeyOk: false,
        phaseIndex: 0,
          createOk: false,
      createResult: {}
  }),

  methods: {

    doCancel: function () {
      this.lognameTxt   = ''
      this.lognameOk    = false
      this.publickeyTxt = ''
      this.publickeyOk  = false
      this.phaseIndex   = 0
      this.createOk     = false
      this.createResult = {}
    },

    doNext: function (data) {
      console.log(' -> Next', data);
      this.saveState( data )
      this.phaseIndex++
    },

    doPrev: function (data) {
      console.log(' -> Previous', data);
      this.saveState( data )
      this.phaseIndex--
    },

    saveState: function (data) {
      if ( data && 'logname' in data )
      {
        this.lognameTxt = data.logname
        this.lognameOk  = data.ok
      }
      if ( data && 'publickey' in data )
      {
        this.publickeyTxt = data.publickey
        this.publickeyOk  = data.ok
      }
    },

    guessIdentityFileName: function () {
      return this.publickeyTxt.split(' ')[0].split('-')[1]
    },

    doCreate: function () {
      // Assumption we'll only call this with validateed inputs!
      if ( this.lognameOk && this.lognameTxt &&
           this.publickeyOk && this.publickeyTxt )
      {
        let self = this
        let logname   = self.lognameTxt
        let publickey = self.publickeyTxt
        console.log('Submit Account Creation for: ' + logname )
        self.$http
          .get('/api/v1/user/add?username=' + logname + '&public=' + publickey )
          .then( response => {
            self.createResult = response.data
            if ( response.data.code == 200 )
            {
              self.createOk = true
            }
            console.log( response.data )
            self.doNext()
        })

      }
    }
  },

  mounted: async function() {
    console.log('UserAdd->mounted()');
  }
}
</script>

<template>
  <div class="greetings">
    <transition appear name="bounce">
      <div>
        <b-card
          border-variant="light"
          border-width="4"
          header="Orange PI 3 LTS"
          header-class="h3"
          header-bg-variant="success"
          header-text-variant="white"
          body-bg-variant="light"
          x-img-src="/img/orange_pi_logotyp.png"
          x-img-top
          class="mb-4"
        >
          <h3> Account Request Service </h3>

          <!-- Welcome / Introduction -->
          <div v-if="this.phaseIndex == 0">
            <p class="text-dark">
               To login to this server using SSH (Secure Shell) you are required to
               select an account name and provision an SSH public key. The account
               request is completed using these steps.
               <ol class="text-danger">
                 <li>On your PC, server or other conmputer create an SSH public key pair
                     using ssh-keygen OR puttygen.exe OR similar tool.</li>
                 <li>Return to this App and choose a login name.</li>
                 <li>Enter your public key.</li>
                 <li>Submit Account Request.</li>
               </ol>
            </p>

            <b-button variant="success" autofocus v-on:click="doNext">Ready to Continue?</b-button>
          </div>

          <!-- collect logname -->
          <div v-if="this.phaseIndex == 1">
            <login-check v-on:on-prev="doPrev" v-on:on-next="doNext"/>
          </div>

          <!-- collect public key -->
          <div v-if="this.phaseIndex == 2">
            <pubkey-check v-on:on-prev="doPrev" v-on:on-next="doNext"/>
          </div>

          <!-- Submit Create Create  -->
          <div v-if="this.phaseIndex == 3">
            <p class="text-dark">
              The logname and SSH Publick key has passed the sniff test. The account name is
              available, or it was at the time of the check. The SSH Public key has passed
              inspection test.
            </p>

            <ul>
              <li>{{ lognameTxt }}</li>
              <li>{{ publickeyTxt.substr(0,25) }}... --snip--</li>
            </ul>

            <b-button variant="success" v-on:click="doCancel">Cancel</b-button>
            <b-button variant="success" v-on:click="doCreate" class="mr-2" :disabled="! publickeyOk">
              Create Now
            </b-button>

          </div>

          <!-- Submission Ststus  -->
          <div v-if="this.phaseIndex == 4">
            <p v-if="createOk" class="text-dark">
              Congratulations your account has been created. Remember your account does not allow login using a password
              therefore you must authenticate using your SSH key. When using the Open-SSH client the command
              will look like this as a minimum, assuming you used the default file name for the key type provided.
              Of course using Windows and Putty.exe this will be different but similar.
              <br/><code>
                $ ssh -i ~/.ssh/id_{{ guessIdentityFileName() }} {{ lognameTxt }}@ancientwizard.noip.net
              </code>
            </p>

            <div v-else>
              <p class="text-dark">
              We're sorry but your request has failed with an error. Here are a few clues that may help.
              Click "Done" to adjust your inputs and try again.
              </p>
              <ul>
                <li v-if="createResult.code">Result Code: {{ createResult.code }}</li>
                <li v-if="createResult.checkmsg">{{ createResult.checkmsg.split(' ')[1] }}</li>
<!--
                <li v-if="createResult.public">{{ createResult.public }}</li>
 -->
                <li v-if="createResult.message">{{ createResult.message }}</li>
              </ul>
            </div>

            <b-button variant="success" v-on:click="doCancel">Done</b-button>
          </div>

        </b-card>

      </div>
    </transition>

  </div>
</template>

<style scoped>


h3 {
  font-size: 1.2rem;
}

h4 {
  font-size: 1.0rem;
}

.mr-2 {
  margin-left: 0.5em;
}

.greetings h1,
.greetings h3 {
  text-align: center;
}

@media (min-width: 1024px) {
  .greetings h1,
  .greetings h3 {
    text-align: left;
  }
}

.bounce-enter-active {
  animation: bounce-in 1.1s;
}

.bounce-leave-active {
  animation: bounce-in 1.1s reverse;
}

@keyframes bounce-in {
  0% {
    transform: scale(0.35);
  }
  3% {
    transform: scale(0.35);
  }
  100% {
    transform: scale(1);
  }
}

</style>

// END
