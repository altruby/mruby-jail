ROOT = File.expand_path("..", __dir__)
PICORUBY_DIR = File.expand_path(ENV["PICORUBY_DIR"] || "../picoruby", ROOT)
TEST_DIR = File.join(ROOT, "test")
PICORUBY = File.join(PICORUBY_DIR, "build", "picoruby-jail", "bin", "picoruby")

require File.join(PICORUBY_DIR, "mrbgems", "picoruby-picotest", "mrblib", "picotest")

unless File.executable?(PICORUBY)
  abort "picoruby-jail: #{PICORUBY} is missing. Run `make build` first."
end

unless Process.uid == 0
  abort "picoruby-jail: the tests create and remove jails, so run them as root."
end

ENV["RUBY"] = PICORUBY

entries = Dir[File.join(TEST_DIR, "*_test.rb")].sort
if entries.empty?
  abort "picoruby-jail: no test files in #{TEST_DIR}"
end

runner = Picotest::Runner.new(
  TEST_DIR,
  require_name: "jail",
  load_path: ROOT,
  entries: entries
)

exit(runner.run == 0 ? 0 : 1)
