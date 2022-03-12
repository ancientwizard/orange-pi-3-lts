<script setup>
import UserAdd    from './components/UserAdd.vue'
</script>

<template>
  <div id="app">
    <header>
<!--  <img alt="Orange PI 3 LTS logo" class="logo" src="/img/orange_pi_logotyp.png" /> -->
    </header>

    <div class="content">
      <UserAdd />
    </div>
  </div>
</template>

<style>
@import './assets/base.css';

#app {
  x-border: 1px solid black;
  max-width: 1280px;
  margin: 0;
  padding: 0;

  font-weight: normal;
}

.content {
  x-border: 1px solid red;
  padding: 1em;
}

header {
  line-height: 1.5;
}

.logo {
  display: block;
  margin: 0 auto 2rem;
}

a,
.green {
  text-decoration: none;
  color: hsla(160, 100%, 37%, 1);
  transition: 0.4s;
}

@media (hover: hover) {
  a:hover {
    background-color: hsla(160, 100%, 37%, 0.2);
  }
}

@media (min-width: 1024px) {
  body {
    display: flex;
    place-items: center;
  }

  #app {
    display: grid;
    grid-template-columns: 1fr 1fr;
    padding: 0 2rem;
  }

  header {
    display: flex;
    place-items: center;
    padding-right: calc(var(--section-gap) / 2);
  }

  header .wrapper {
    border: 1px solid red;
    display: flex;
    place-items: flex-start;
    flex-wrap: wrap;
  }

  .logo {
    margin: 0 2rem 0 0;
  }
}
</style>
