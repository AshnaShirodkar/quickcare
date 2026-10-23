# QuickCare

Static HTML application. One embedded Google Maps browser API key was removed from index.html. No other obvious credentials were found in the supplied HTML; this is not a guarantee against all secret formats.

## Local setup
Copy config.example.js to config.js and set googleMapsApiKey to a restricted Google Maps browser key. Serve this directory with `python3 -m http.server 8000`.

config.js is ignored by Git. Never put the real key in .gitignore itself. The downloadable ZIP deliberately excludes config.js and contains no real key.

## Deployment
Publish index.html and provide config.js in the hosted output. For GitHub Pages, generate config.js during a deployment workflow using a repository secret named GOOGLE_MAPS_API_KEY; never commit the generated file. Maps, address lookup, and facility search require this configuration. A plain checkout deployed without configuration will not support these features.

A browser API key remains visible in deployed JavaScript and network requests, even when sourced from GitHub Secrets. Restrict it to the exact website HTTP referrers and only the required Google Maps APIs in Google Cloud. Rotate the previously embedded key if it was publicly shared or unrestricted. Fully private keys require a backend, which this static application does not include.

## Scope of review
Reviewed the supplied HTML, including inline JavaScript, external URLs, and common credential patterns. No existing Git history or Google Cloud key restrictions were available to inspect. Existing application behavior was preserved; this was not a full functional or clinical-data review.
