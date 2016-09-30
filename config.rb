require 'base64'
require 'pry'
require_relative 'source/extensions/sass_variable'
###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page "/path/to/file.html", layout: :otherlayout

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

# General configuration

###
# Helpers
###

# Methods defined in the helpers block are available in templates
helpers do
  def svg(name)
    root = Middleman::Application.root
    File.read("#{root}/source/images/#{name}.svg")
  end
end

activate :sass_variable

# Build-specific configuration
configure :build do
  activate :relative_assets
  activate :minify_css
  activate :minify_javascript
  activate :minify_html
  activate :gzip

  activate :deploy do |deploy|
    deploy.deploy_method = :git
    # deploy.remote = 'custom-remote' # remote name or git url, default: origin
    # deploy.branch = 'custom-branch' # default: gh-pages
    # deploy.strategy = :force_push # commit strategy: can be :force_push or :submodule, default: :force_push
    deploy.commit_message = 'automated commit by middleman deployment'
  end
end

