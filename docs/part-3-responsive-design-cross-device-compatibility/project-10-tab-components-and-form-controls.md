# Project 10 Tab Components and Form Controls

## Content Guide
This project focuses on Bootstrap tab components and form controls. The tab component is a UI component used to create switchable tabs, allowing users to switch between different content sections, each of which can contain distinct content and styles. Meanwhile, Bootstrap provides a comprehensive set of form controls, including &lt;input&gt;, &lt;textarea&gt;, &lt;checkbox&gt;, &lt;radio&gt;, and &lt;select&gt;.

## Learning Objectives
- ① Master form-related components.
- ② Master the interactive design of tab components.
- ③ Be familiar with form validation.
- ④ Master the grid layout of forms and tabs.

## Task 10.1 Information Tabs

### 10.1.1 Task Description
<p align="center">
  <img src="../../assets/images/project-10/image-001.png" alt="Image">
</p>

Through this practical project, implement the production of the information tabs module and the contact form section in the tour guide project. The information tabs module mainly includes custom elements to implement tabs, switch tabs on mouse click, and use aria-selected, aria-hidden, aria-labelledby to display the titles and content of the corresponding tabs. The effect of the example is shown in Figure 10-1.
<p align="center"><em>Figure 10-1 Information Tabs</em></p>

### 10.1.2 Knowledge Preparation
The Bootstrap responsive tab component is a component within the Bootstrap framework used to create switchable tabs with different content. These tabs can automatically adjust their layout based on the device screen size for a better user experience. By using the class names and JavaScript plugins provided by Bootstrap, we can implement interactive functions. Its main features are summarized as follows:

#### 1.Container Layer
Use Bootstrap's container class to achieve responsive layout, with width adapting to screen size. The heading &lt;h2&gt;Other Information&lt;/h2&gt; clearly defines the module theme.

#### 2.Component Layer
Internally, wrap the entire tab component with &lt;div class="tabBox"&gt;, which includes two parts: the navigation tab bar and the content panel.

#### 3.Navigation Tab Bar Attributes

**Table 10-1 Tab Attributes**

| Attribute | Explanation |
| --- | --- |
| role="tablist" | Declares this as a tab group container. |
| data-bs-toggle="tab" | Interactive attribute that switches tabs on click. |
| data-bs-target="#tab1" | Specifies the ID of the content panel to display when clicked. |
| aria-controls="tab1" | Associates the corresponding content panel to improve accessibility. |
| aria-selected="true" | Marks the currently active tab. |

#### 4.Content Panel

**Table 10-2 Tab Panel Attributes**

| Attribute | Explanation |
| --- | --- |
| id="tab1" | Corresponds to data-bs-target of the navigation button to link content. |
| show active | Marks the default displayed content panel. |
| role="tabpanel" | Declares this as a tab content area. |
| aria-labelledby="tab1-tab" | Associates the corresponding navigation tab button ID. |

### 10.1.3 Task Implementation
The information tab bar module is divided into the following five steps:

#### Step 1: Create the directory structure as follows:
module_f: Project Root Directory
├─assets: Directory for images and videos
├─js: Directory for JavaScript files
├─css:Directory for style files
├─bootstrap-5.3.3.min.css
├─main.css
├─images:Directory for image resources
├─video:Directory for video resources
├─index.html:Entry webpage file

#### Step 2: Edit the index.html file and use the &lt;h2&gt; tag as the heading.

```html
<section id="other" class="container">
  <h2>Other Information</h2>
</section>
```

#### Step 3: Edit the index.html file to build the tab navigation bar. Enable tab switching via the data-bs-toggle="tab" attribute, point to the corresponding content area ID with data-bs-target="#tabx", and control the active state with aria-selected="true/false".

```html
<section id="other" class="container">
  <h2>Other Information</h2>
  <div class="tabBox">
    <ul class="nav nav-tabs" role="tablist">
      <li class="nav-item" role="presentation">
        <button class="nav-link active" id="tab1-tab" data-bs-toggle="tab" data-bs-target="#tab1" type="button" role="tab" aria-controls="tab1" aria-selected="true">Tab 1</button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="tab2-tab" data-bs-toggle="tab" data-bs-target="#tab2" type="button"
        role="tab" aria-controls="tab2" aria-selected="false">Tab 2</button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="tab3-tab" data-bs-toggle="tab" data-bs-target="#tab3" type="button"
        role="tab" aria-controls="tab3" aria-selected="false">Tab 3</button>
      </li>
    </ul>
  </div>
</section>
```

#### Step 4: Edit the index.html file to create content panels. Wrap all panels with .tab-content, define panel containers with the .tab-pane class, add fade animations with the .fade class, and set the initial active panel with .show.active.

```html
<section id="other" class="container">
  <h2>Other Information</h2>
  <div class="tabBox">
    <ul class="nav nav-tabs" role="tablist">
      <li class="nav-item" role="presentation">
        <button class="nav-link active" id="tab1-tab" data-bs-toggle="tab" data-bs-target="#tab1" type="button" role="tab" aria-controls="tab1" aria-selected="true">Tab 1</button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="tab2-tab" data-bs-toggle="tab" data-bs-target="#tab2" type="button"
        role="tab" aria-controls="tab2" aria-selected="false">Tab 2</button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="tab3-tab" data-bs-toggle="tab" data-bs-target="#tab3" type="button"
        role="tab" aria-controls="tab3" aria-selected="false">Tab 3</button>
      </li>
    </ul>
    <div class="tabContents">
      <div class="tab-pane fade show active" id="tab1" role="tabpanel" aria-labelledby="tab1-tab">This is the content for Tab 1.
      </div>
      <div class="tab-pane fade" id="tab2" role="tabpanel" aria-labelledby="tab2-tab">This is the content for Tab 2.
      </div>
      <div class="tab-pane fade" id="tab3" role="tabpanel" aria-labelledby="tab3-tab">This is the content for Tab 3.
      </div>
    </div>
  </div>
</section>
<!-- Contact Us -->
```

#### Step 5: Implement the Contact Us styles.

```css
/* Contact Us */
#contact {
  margin-bottom: 50px;
}
#contact .title {
  display: flex;
  justify-content: center;
}
#contact .title h2 {
  padding: 1.5rem 5rem;
  border: 2px solid #cfcfcf;
  background: #fff;
  transform: translateY(50%);
}
#contact form {
  border: 2px solid #cfcfcf;
  padding: 120px 3rem 2rem;
}
```

## Task 10.2 Contact Form

### 10.2.1 Task Description
The contact form module mainly consists of the provided fields: first name, last name, contact email address, and contact phone number, as shown in Figure 6-9.
<p align="center">
  <img src="../../assets/images/project-10/image-002.png" alt="Image">
</p>

<p align="center"><em>Figure 6-9 Contact Form</em></p>

### 10.2.2 Knowledge Preparation
Bootstrap form controls reset form styles through class extensions. Using these classes allows customized display effects for more consistent rendering across browsers and devices. Make sure to use appropriate type attributes on all inputs (e.g., email for email addresses or number for numeric information) to take advantage of newer input controls such as email validation and number selection. Its main features are summarized as follows:

#### 1. Container Layer
Use Bootstrap's container class to implement responsive layout with width adapting to screen size. The heading &lt;h2&gt;Other Information&lt;/h2&gt; clearly defines the module theme.

#### 2. Component Layer
Internally, wrap the entire tab component with &lt;div class="tabBox"&gt;, which includes two parts: the navigation tab bar and the content panel.

#### 3. Form Attributes

**Table 10-3 Form Attributes**

| Class or Attribute Name | Description |
| --- | --- |
| .form-group | Form element group |
| .form-control | Form control |
| .from-control-lg/sm | Control size |
| .form-control-plaintext | Plain text |
| .form-control-range | Range control |
| .form-text | Form text |
| .form-check | Checkbox / radio wrapper |
| .form-check-label | Checkbox / radio label |
| .form-check-input | Checkbox / radio input |
| .form-check-inline | Inline check / radio |
| .form-control-file | File input |

#### 4.Content Panel

**Table 2-9 Button Attributes**

| Attribute | Description |
| --- | --- |
| id="tab1" | Corresponds to the data-bs-target of the navigation button to associate content |
| show active | Marks the default displayed content panel |
| role="tabpanel" | Declares this as a tab content area |
| aria-labelledby="tab1-tab" | Associates the corresponding navigation tab button ID |

### 10.2.3 Task Implementation
The information tab module is divided into the following 3 steps, as detailed below.
module_f: Project Root Directory
├─assets: Directory for images and videos
├─js: Directory for JavaScript files
├─css:Directory for style files
├─bootstrap-5.3.3.min.css
├─main.css
├─images:Directory for image resources
├─video:Directory for video resources
├─index.html:Entry webpage file

#### Step 2: Edit the index.html file, wrap the entire content with a section tag on the outer layer, and set class="container" for responsive layout.

```html
<!-- Contact Us -->
<section id="contact" class="container">
  <div class="title">
    <h2>Contact Us</h2>
  </div>
  <form class="needs-validation" novalidate>
    <div class="row g-3 gy-4">
      <!-- First Name -->
      <div class="col-md-6">
        <div class="form-floating">
          <input type="text" id="contact_first_name" class="form-control" required>
          <label for="contact_first_name" class="form-label">First Name*</label>
          <div class="invalid-feedback">Please enter your name</div>
        </div>
      </div>
      <!-- Last Name -->
      <div class="col-md-6">
        <div class="form-floating">
          <input type="text" id="contact_last_name" class="form-control" required>
          <label for="contact_last_name" class="form-label">Last Name*</label>
          <div class="invalid-feedback">Please enter your last name</div>
        </div>
      </div>
      <!-- Email -->
      <div class="col-md-6">
        <div class="form-floating">
          <input type="email" id="contact_email" class="form-control" required>
          <label for="contact_email" class="form-label">Email*</label>
          <div class="invalid-feedback">Please enter a valid email address</div>
        </div>
      </div>
      <!-- Phone -->
      <div class="col-md-6">
        <div class="form-floating">
          <input type="tel" id="contact_phone" class="form-control"
          pattern="[0-9]{3}-[0-9]{3}-[0-9]{4}">
          <label for="contact_phone" class="form-label">Phone (XXX-XXX-XXXX)</label>
          <div class="invalid-feedback">Please enter a valid phone number format</div>
        </div>
      </div>
    </div>
    <!-- Submit button -->
    <div class="d-grid mt-4">
      <button type="submit" class="btn btn-primary btn-lg">Send Message</button>
    </div>
  </form>
</section>
```

#### Step 3: Implement the Contact Us style.

```css
/* Contact Us */
#contact {
  margin-bottom: 50px;
}
#contact .title {
  display: flex;
  justify-content: center;
}
#contact .title h2 {
  padding: 1.5rem 5rem;
  border: 2px solid #cfcfcf;
  background: #fff;
  transform: translateY(50%);
}
#contact form {
  border: 2px solid #cfcfcf;
  padding: 120px 3rem 2rem;
}
```
