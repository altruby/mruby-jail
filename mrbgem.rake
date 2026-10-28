load File.join(__dir__, "mrblib", "jail", "version.rb")

MRuby::Gem::Specification.new("picoruby-jail") do |spec|
  spec.license = 'MIT'
  spec.author  = 'robert@r.uby.dev'
  spec.summary = 'picoruby + libjail = picoruby-jail'
  spec.version = Jail::VERSION

  if build.picoruby?
    spec.require_name = "jail"
    spec.add_dependency "mruby-errno", 
                        github: "mruby/mruby",
                        branch: "master",
                        path: "mrbgems/mruby-errno"
  end

  spec.cc.flags << '-Wall'
  spec.cc.flags << '-Wpedantic'
  spec.linker.libraries << 'jail'
end
