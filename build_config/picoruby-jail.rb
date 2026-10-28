MRuby::Build.new('picoruby-jail') do |conf|
  ##
  # Paths
  root  = File.realpath File.join(__dir__, "..")
  pico  = File.realpath File.join(root, "..", "picoruby")
  mruby = File.join(pico, "mrbgems", "picoruby-mruby", "lib", "mruby")

  ##
  # Required for bin/mirb
  conf.picoruby(alloc_estalloc: false)

  conf.toolchain
  conf.cc.defines << "PICORB_PLATFORM_POSIX"
  conf.cc.defines << "MRB_TICK_UNIT=4"
  conf.cc.defines << "MRB_TIMESLICE_TICK_COUNT=3"
  conf.cc.defines << "MRB_INT64"
  conf.cc.defines << "MRB_NO_BOXING"
  conf.cc.defines << "MRB_UTF8_STRING"

  conf.cc.flags << "-pthread"
  conf.linker.flags << "-pthread"
  conf.linker.libraries << 'jail'

  conf.gembox "mruby-posix"
  conf.gembox "minimum"
  conf.gembox "core"
  conf.gembox "stdlib"

  conf.gem core: "picoruby-picotest"
  conf.gem gemdir: File.join(mruby, "mrbgems", "mruby-bin-mirb")
  conf.gem gemdir: root
end
