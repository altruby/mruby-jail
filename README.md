<p align="center">
  <a href="https://github.com/altruby/picoruby-jail">
    <img src="daemon.png" width="200" height="200" border="0" alt="picoruby-jail">
  </a>
</p>
<p align="center">
  <strong>picoruby-jail</strong>
</p>

## About

[picoruby](https://picoruby.org/) + libjail = picoruby-jail.

This project combines an implementation of ruby that can run 
on a single-chip microcontroller and [libjail](https://man.freebsd.org/libjail)
from the FreeBSD project. Although [picoruby](https://picoruby.org/)
markets itself towards embedded devices it also happens to run
exceptionally well on POSIX systems too. It is more or less 
straight forward to embed picoruby's bytecode into a C program.

## Install

##### make

The next few lines will build your own copy 
of the picoruby executable. The executable
is linked against picoruby-jail and when it
is run it automatically has access to the
picoruby-jail classes, modules and methods. 
This can be surprising compared to mainline
CRuby where there is a single copy of the 
executable that is built once on install: 

    $ git clone --recurse-submodules https://github.com/picoruby/picoruby picoruby
    $ git clone https://github.com/altruby/picoruby-jail
    $ cd picoruby-jail
    $ make build
    $ ../picoruby/build/picoruby-jail/bin/picoruby -e 'p Jail.all'

##### build_config.rb

The steps:

```sh
mkdir myapp
touch build_config.rb
cd ../picoruby
MRUBY_CONFIG=../myapp/build_config.rb rake
```

The configuration (`build_config.rb`):

```ruby
MRuby::Build.new("app") do |conf|
  conf.toolchain
  conf.gembox "default"
  conf.gem github: "altruby/picoruby-jail", branch: "main"
end
```

## Quick start

##### Jail

The Jail singleton class is enumerable. It provides access
to all running jails that are visible to the current process.
We can use the `each` method to iterate over jails, we can
use the `select` method to filter, we can use the `find`
method to find a jail, and we can use the `map` method to
transform:

```ruby
##
# Iterate all
Jail.each do |jail|
  print "jid=#{jail.jid}",
        "name=#{jail.name}",
        "hostname=#{jail.hostname}",
        "\n\n"
end

##
# Select jails by hostname
Jail.select do |jail|
  jail.hostname.to_s.end_with?(".local")
end

##
# Find a jail by name
example = Jail.find do |jail|
  jail.name == "example"
end

##
# Transform jails
jids = Jail.map(&:jid)
```

##### Jail.create

The `Jail.create` method creates a new jail and returns a
`Jail` instance for it. A path is required. A name, hostname,
and other jail parameters can also be provided. Some parameters
have to be provided at creation time, such as `vnet: "new"`:

```ruby
jail = Jail.create(
  path: "/tmp/jail",
  name: "example",
  hostname: "example.local",
  vnet: "new"
)
```

##### Jail.find_by

The `Jail.find_by` method can find a jail by ID or by name,
and returns a `Jail` instance:

```ruby
##
# Find by JID
jail = Jail.find_by(jid: 1)
print "jid " , "\t", jail.jid      , "\n"
print "name ", "\t", jail.name     , "\n"
print "host ", "\t", jail.hostname , "\n"
print "path ", "\t", jail.path     , "\n"

##
# Find by name
jail = Jail.find_by(name: "example")
print "jid " , "\t", jail.jid      , "\n"
print "name ", "\t", jail.name     , "\n"
```

##### Jail.parameters

Discover which jail parameters are supported by the system
and inspect the current values for a specific jail.
`Jail.parameters` returns the parameter names as an
enumerable, and `jail.parameters` returns the values as
a Hash:

```ruby
##
# All known jail parameters, by name
Jail.parameters.each do |parameter|
  puts parameter
end

##
# All known jail parameters, and their values, for a given jail
jail = Jail.find_by(jid: 1)
p jail.parameters # => Hash
```

##### Jail#[]

Read jail parameters with the hash-style interface. There are
also convenience methods for common parameters such as `jid`,
`name`, `hostname`, and `path`:

```ruby
jail = Jail.find_by(jid: 1)
print "jid " , "\t", jail["jid"]           , "\n"
print "name ", "\t", jail["name"]          , "\n"
print "host ", "\t", jail["host.hostname"] , "\n"
print "path ", "\t", jail["path"]          , "\n"

##
# Convenience readers
print "jid " , "\t", jail.jid      , "\n"
print "name ", "\t", jail.name     , "\n"
print "host ", "\t", jail.hostname , "\n"
print "path ", "\t", jail.path     , "\n"
```

##### Jail#[]=

Update jail parameters through the hash-style interface. There
are also convenience setters for common parameters such as
`name`, `hostname`, and `path`:

```ruby
jail = Jail.find_by(jid: 1)
jail["host.hostname"] = "example.local"
puts jail.name
puts jail.hostname
puts jail.path

##
# Convenience writer
jail.hostname = "example.local"
```

##### Jail#attach

Attach the current process to a jail. After attaching,
the process runs within the jail's environment:

```ruby
jail = Jail.find_by(name: "example")
jail.attach
```

##### Jail#remove

Remove a jail from the system. This is a destructive
operation that kills all processes in the jail:

```ruby
jail = Jail.find_by(name: "example")
jail.remove
```

## License

[MIT License](https://choosealicense.com/licenses/mit/)
<br>
See [LICENSE](./LICENSE)
