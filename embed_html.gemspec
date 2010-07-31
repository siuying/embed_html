# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{embed_html}
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Francis Chong"]
  s.date = %q{2010-07-31}
  s.default_executable = %q{eurl}
  s.description = %q{Download and embed images in html using base64 data encoding}
  s.email = %q{francis@ignition.hk}
  s.executables = ["eurl"]
  s.extra_rdoc_files = ["README.markdown", "bin/eurl", "lib/embed_html.rb", "lib/embed_html/embeder.rb"]
  s.files = ["Manifest", "README.markdown", "Rakefile", "bin/eurl", "lib/embed_html.rb", "lib/embed_html/embeder.rb", "embed_html.gemspec"]
  s.homepage = %q{http://github.com/siuying/embed_html}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Embed_html", "--main", "README.markdown"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{embed_html}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Download or process a HTML page, find images there, download them and embed it into the HTML using Base64 data encoding}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hpricot>, [">= 0"])
      s.add_runtime_dependency(%q<mime-types>, [">= 0"])
    else
      s.add_dependency(%q<hpricot>, [">= 0"])
      s.add_dependency(%q<mime-types>, [">= 0"])
    end
  else
    s.add_dependency(%q<hpricot>, [">= 0"])
    s.add_dependency(%q<mime-types>, [">= 0"])
  end
end
