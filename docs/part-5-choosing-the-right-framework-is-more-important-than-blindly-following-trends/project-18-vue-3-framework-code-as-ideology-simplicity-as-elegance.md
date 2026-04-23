# Project 18 Vue 3 Framework — Code as Ideology, Simplicity as Elegance

## Content Guide
In the photo slideshow project for the WorldSkills Competition website, the combination of the Vue 3 framework and the Bootstrap framework provides an ideal solution for efficiently building responsive and highly interactive slideshows.
Vue 3’s reactive data binding and Composition API make the dynamic management of slideshow data (such as image URL arrays and current indexes) concise and efficient. Developers can easily track state changes using ref or reactive, and dynamically render image lists with the v-for directive. Meanwhile, using Vue 3’s transition system (such as the &lt;transition&gt; component) combined with CSS animations allows for smooth fade-in/fade-out or sliding effects during slide transitions.
The Bootstrap framework, through its powerful responsive grid system and preset styles, ensures perfect adaptation of the slideshow on various devices. Its built-in carousel components or slide display plugins enable quick implementation of interactive features such as automatic playback, navigation buttons, and indicators.
By combining the two, developers can leverage Vue 3’s flexibility to manage complex logic (such as dynamically loading images and responsively adjusting layouts), while using Bootstrap’s ready-made components and styles to rapidly build attractive interfaces. Ultimately, this creates a cross-device compatible, smoothly operating, and visually professional photo slideshow platform for the WorldSkills Competition website.

## Learning Objectives
- ① Understand Vue.js and its core features.
- ② Understand the reasons for using Vue.js.
- ③ Comprehend the MVVM pattern.
- ④ Grasp the reactivity system of Vue.js.

## Task 18.1 Initial Vue 3

### 18.1.1 Overview of Vue 3
With its high performance, flexible architecture and powerful ecosystem, the Vue 3 framework has become a key support in the technology selection for WorldSkills Competition websites. Centered on the design philosophies of simplicity, efficiency and modularity, it restructures code organization through the Composition API, significantly improving logic reuse and code maintainability. Its TypeScript-based type system enhances the development experience, while optimized reactive system mechanisms (such as ref and reactive) boost performance and predictability.
Vue 3’s compilation optimizations (including static node hoisting and block tree analysis) greatly reduce runtime overhead. Combined with the efficient update strategy of the virtual DOM, it maintains smooth performance even in complex applications. In addition, it supports advanced features such as Fragments and custom renderers, and is compatible with Vue 2’s Options API for gradual migration. Paired with ecosystem tools like Vue Router and Pinia, Vue 3 can rapidly build full-stack solutions ranging from simple pages to large-scale single-page applications (SPAs), making it one of the preferred frameworks for modern front-end development.

### 18.1.2 Advantages of Vue 3

#### 1.Lightweight and Efficient
Vue 3 supports on-demand compilation and has a smaller bundle size compared to Vue 2, which helps reduce loading time and improve application performance. It also enables more flexible component logic organization and enhances rendering efficiency.

#### 2.Composition API
The Composition API is one of Vue 3’s core features. It centralizes logic management through functional programming, improving code readability. Vue 3 also offers better TypeScript support, aligning with an important trend in current front-end development.

#### 3.Front-End Routing
Vue Router 4 is the official routing manager for Vue 3, deeply integrated with its reactive system. It supports dynamic routes, nested routes, route lazy loading and other functions.

#### 4.State Management
Pinia is the officially recommended state management library for Vue 3 (replacing Vuex). Designed based on the Composition API, it provides a more concise API and superior TypeScript support.

#### 5.Virtual DOM
Vue 3’s virtual DOM has been reconstructed with more efficient techniques including static hoisting and tree flattening, reducing unnecessary rendering overhead. The compiler precomputes static nodes, skips diffing during updates and reuses them directly.

### 18.1.3 Composition API
<p align="center">
  <img src="../../assets/images/project-18/image-001.png" alt="Image">
</p>

Both the Composition API and the Options API in Vue 3 are programming models of Vue.js used for organizing code and logic. However, there are some differences between them in terms of usage, applicable scenarios, and functionality, as shown in Figure 18-1 below.
<p align="center"><em>Figure 18-1 Composition API</em></p>
Vue 3 supports both the Composition API and the Options API. Developers can flexibly choose and use these two APIs according to actual development requirements and scenarios.
The Composition API is a collection of a series of APIs, and the entry point for using the Composition API is the setup() hook function.

### 18.1.4 Reactive System
In Vue 3, the reactive system dynamically intercepts data operations through Proxy. It automatically collects dependencies (such as component rendering or computed properties) when data is accessed (get), and triggers updates to these dependencies when data changes (set). This enables automatic synchronization from data changes to the view. Its core advantage lies in supporting listening for nested objects and arrays, without requiring manual handling of newly added properties.
The following example helps understand Vue 3's reactive system, with the code as follows:

```vue
<template>
<div>
<!-- Bind reactive data -->
<p>Current count: {{ count }}</p>
<!-- Trigger data modification -->
<button @click="increment">Increment</button>
</div>
</template>
<script setup>
import { ref } from 'vue';
// Define reactive data (use ref for primitive types)
const count = ref(0);
// Method to modify data
function increment() {
  count.value++; // Must modify via .value
}
</script>
```
