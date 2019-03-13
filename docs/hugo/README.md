## Working with Hugo

You will need Homebrew, a package manager [from brew.sh](https://brew.sh/) - [Windows users see here](https://gohugo.io/getting-started/installing).
```
$ brew install hugo
$ hugo version
$ hugo new site <name of your site>
$ Follow these instruction https://gohugo.io/getting-started/quick-start/#step-3-add-a-theme 🤓
```

The Hugo [documentation](https://gohugo.io/overview/introduction/) gives a much better overview of the project structure than me, so check it out.

* The `/content` directory is where the core website content is stored. Files can be organized in any sort of directory structure and can be written in either markdown or plain html.

* The `+++` stuff at the top of each file is called "Front Matter", and can hold the metadata for each page. This metadata can later be accessed in the layouts to dynamically render content.

* The `/layouts` directory contains the html templates, the structural building blocks for the website.

* The `/layouts/partials` directory contains reusable html components that we can inject into any template. This is useful for headers, footers, navbars, sharing links, and other common components.

* The `/layouts/pages` directory is where we store the templates for rendering the content in the /contentdirectory.

* The `/layouts/shortcodes` directory is where can store shortcodes, or reusable html blocks that we can use in any of the content pages.

* The core difference between partials and shortcodes is that partials are used in layouts(such as a footer), and shortcodes are used in content(such as a right-aligned image).

* The `/archetypes`, `/data`, and `/themes` directories have some cool roles as well, but we don't need to use them in this sample project. Check out the [Hugo documentation](https://gohugo.io/overview/introduction/) for more info.

* The core project configuration is stored within the config.toml file. The data here is accessible from any template in the `/layouts` directory. This is where we store top-level data like the site name and the menu configuration.

* The prebuild resources(SCSS, Javascript ES6) are stored in the `/src` directory.

* The built resources(css, javascript, images) are stored in the `/static` directory.

* The `/public` directory is the final product, with the entire generated website.

## Javascript

### Add javascript to a page

Add a new file in `/src/js/page/` called `{pagetitle}.js` Add the custom javascript here. The the page content file, add `script ="{pagetitle}.js"` to the Front Matter metadata. The script should now download and run whenever the page is visited.

### Add a javascript library

Add the library JS file to `/src/js/vendor`. During a Gulp build process, for example, it will be minified and combined with all other libraries in the directory, and imported before the page-specific scripts on each page.

### Add global javascript
For any javascript that should be run on every page, add it to `/src/js/scripts.js`.
