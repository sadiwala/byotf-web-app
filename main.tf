# Bucket to store website
resource "google_storage_bucket" "website" {
  project       = "google-mpf-982916601176"
  provider = google
  name     = "example-psadiwala-coffee7"
  location = "US"
}

# Make new objects public
resource "google_storage_object_access_control" "public_rule" {
  project       = "google-mpf-982916601176"
  object = google_storage_bucket_object.static_site_src.output_name
  bucket = google_storage_bucket.website.name
  role   = "READER"
  entity = "allUsers"
}
#resource "google_storage_default_object_access_control" "website_read" {
#  bucket = google_storage_bucket.website.name
#  role   = "READER"
#  entity = "allUsers"
#}

# Upload the html file to the bucket
resource "google_storage_bucket_object" "static_site_src" {
  project       = "google-mpf-982916601176"
  name   = "index.html"
  source = "website/index.html"
  bucket = google_storage_bucket.website.name
  
}

# Reserve an external IP
resource "google_compute_global_address" "website" {
  project       = "google-mpf-982916601176"
  provider = google
  name     = "website-lb-ip"
}

# Add the bucket as a CDN backend
resource "google_compute_backend_bucket" "website-backend" {
  project       = "google-mpf-982916601176"
  provider    = google
  name        = "website-backend"
  description = "Contains files needed by the website"
  bucket_name = google_storage_bucket.website.name
  enable_cdn  = true
}


# GCP URL MAP
resource "google_compute_url_map" "website" {
  project       = "google-mpf-982916601176"
  provider        = google
  name            = "website-url-map"
  default_service = google_compute_backend_bucket.website-backend.self_link
    host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_bucket.website-backend.self_link
  }
}
