# Project 9 Bootstrap Cards and Scroll Components---Fixed Width Means Self-Discipline, Fluid Width Means Freedom

## Content Guide
This project focuses on the component system of Bootstrap. Bootstrap cards provide flexible and extensible content containers with a variety of variants and options. Structured layout is achieved using the card component. With predefined containers (.card), content sections (.card-header, .card-body, .card-footer) and multimedia support, you can quickly build modular units with mixed text and images as well as interactive buttons.

## Learning Objectives
- ① Master the card layout component.
- ② Be familiar with media components.
- ③ Master the grid layout structure of Bootstrap.
- ④ Master the scroll component.

## Task 9.1 Basic Information and Latest Events Section

### 9.1.1 Task Description
The basic information and latest events module consists of basic information layout, focus effects, box-shadow effects, zoom effects, offset, blur effects, opacity effects, focus effects and gradient effects, as shown in Figure 9-1.
<p align="center">
  <img src="../../assets/images/project-09/image-001.png" alt="Image">
</p>

<p align="center"><em>Figure 9-1 Service Brief</em></p>

### 9.1.2 Knowledge Preparation
Bootstrap cards provide flexible and extensible content containers with a variety of variants and options. A card is a flexible and extensible content container that includes options for headers and footers, a wide variety of content, contextual background colors, and powerful display options. Its main features are summarized as follows:

#### 1. Card Properties

**Table 9-1 Card Properties**

| Class or Property | Description |
| --- | --- |
| .card | Card |
| .card-img-top | Image at the top |
| .card-img-bottom | Image at the bottom |
| .card-img-overlay | Overlay on top of an image |
| .card-header | Card header |
| .card-header-tabs | Header with tabs |
| .card-header-pills | Header with pills |
| .card-body | Card body |
| .card-title | Card title |
| .card-subtitle | Card subtitle |
| .card-text | Card text |
| .card-link | Card link |
| .card-footer | Card footer |
| .card-group | Card group |
| .card-deck | Card deck |
| .card-columns | Card columns |

2、Bootstrap Colored Cards
Bootstrap provides various classes for card background colors:: .bg-primary,.bg-success,.bg-info, .bg-warning, .bg-danger, .bg-secondary, .bg-dark 和 .bg-light。
3、Titles, Text and Links
Use the .card-title class on heading elements to set the card title.
The .card-text class is used to set the body content of the card.
The .card-link class is used to color links.
4、Image Cards
Add .card-img-top (image above text) or .card-img-bottom to the &lt;img&gt; tag. If you want to set an image as the background, you can use the .card-img-overlay class.
Example:

```html
<div class="container">
  <div class="card" style="width:400px">
    <div class="card-header bg-light">Header</div>
    <div class="card-body">
      <h4 class="card-title">Card Title</h4>
      <p class="card-text">Card Content Information</p>
      <a href="#" class="card-link">Click</a>
    </div>
    <div class="card-footer">Footer</div>
  </div>
</div>
```

### 9.1.3 Task Implementation
The service brief module is divided into the following seven steps, as detailed below.

#### Step 1: Create the directory structure as follows:
module_f :Project root directory
├─assets: Directory for images and videos
├─js: Directory for JavaScript files
├─css:Directory for style files
├─bootstrap-5.3.3.min.css
├─main.css
├─images:Directory for image resources
├─video:Directory for video resources
├─index.html:Entry webpage file

#### Step 2: Edit the index.html file and wrap the outer layer with &lt;div class="container"&gt; to ensure the content is centered and responsive.

```html
<!-- Essential Information | Latest Events -->
<div class="container">
</div>
```

#### Step 3: Edit the index.html file, divide the row structure using .row, and implement a two-column layout (left information column / right events column) internally with .col-6.

```html
<div class="container">
  <div class="row">
    <div class="col-6">
    </div>
    <div class="col-6">
    </div>
  </div>
</div>
```

#### Step 4: Edit the index.html file. Use a &lt;section&gt; tag to wrap the information section (#information) and the event list (#events). Organize the contact information in the list using &lt;ul&gt; and &lt;li&gt; tags, and wrap each event card with an &lt;article&gt; tag.

```html
<div class="container">
  <div class="row">
    <div class="col-6">
      <!-- Essential Information -->
      <section id="information">
        <h2>Essential Information</h2>
        <ul>
          <li>Contact: 04 72 10 30 30</li>
          <li>Address: Mairle de Lyon, 69205 Lyon cedex 01</li>
        </ul>
        <button id="readIt" type="button">Read it Loud</button>
      </section>
    </div>
    <div class="col-6">
    </div>
  </div>
</div>
```

#### Step 5: Edit the index.html file. Use the card component: wrap each event card with .card, use .card-body for the title, and set the image position with .card-img-top.

```html
<div class="container">
  <div class="row">
    <div class="col-6">
      <!-- Essential Information -->
      <section id="information">
        <h2>Essential Information</h2>
        <ul>
          <li>Contact: 04 72 10 30 30</li>
          <li>Address: Mairle de Lyon, 69205 Lyon cedex 01</li>
        </ul>
        <button id="readIt" type="button">Read it Loud</button>
      </section>
    </div>
    <div class="col-6">
      <!-- Latest Events -->
      <section id="events">
        <h2>Latest Events</h2>
        <div class="listContainer" id="eventListBox">
          <div class="listWrapper">
            <article class="photoCard">
              <div class="card photoBox">
                <picture>
                  <source
                  srcset="./assets/images/latest-events-images/worldskills-2024-p.jpg" media="(min-width: 760px)">
                  <source
                  srcset="./assets/images/latest-events-images/worldskills-2024-p-low-res.png" media="(max-width: 760px)">
                  <img src="./assets/images/latest-events-images/worldskills-2024-p.jpg" alt="Event Image">
                </picture>
              </div>
              <div class="card-body">
                <h5 class="card-title">Lyon accueille la finale mondiale des Worldskills 2024
                </h5>
              </div>
            </article>
            <!-- The structure is the same as other cards -->
          </div>
        </div>
      </section>
    </div>
  </div>
</div>
```

#### Step 6: Implement focus effects, box-shadow effects, zoom effects, offset, blur, opacity effects, hover effects, and gradient effects in the main.css style file.

```css
/* Common card design */
/* video */
#video {
  padding-bottom: 0;
}
#video video {
  width: 100%;
}
/* Essential Information */
#information ul {
  list-style: none;
  padding-left: 0;
  margin-top: 2rem;
}
#information ul li {
  margin-bottom: 1rem;
}
#information #readIt {
  background: #023399;
  color: #fff;
  border-radius: .5rem;
  border: none;
  padding: 1rem 1.5rem;
}
/* Events */
#events h2 {
  margin-bottom: 2rem;
}
#events .listWrapper {
  display: flex;
  flex-wrap: nowrap;
  width: min-content;
  padding-bottom: 1rem;
}
#events .listContainer {
  border: 1px solid #aaa;
  border-radius: 5px;
  padding: 1rem;
  overflow-x: scroll;
}
#events .photoCard {
  width: 220px;
}
```
