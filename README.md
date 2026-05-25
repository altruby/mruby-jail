<p align="center">
  <a href="http://git.home.network/0x1eef/mruby-jail">
    <img src="https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEi39c9ab6rTHulzqrvy45M_omMN8cUyRxfaAph0UhlpubhMxgnJVyOEarYGmHNZgt1uUZmO8cobmrloSiAfxUjgjNOVvRZrF9n9b5tO0S-sG7e9DHfalqyYQZm6aY1jV55IzPbGPA/s1600/freebsd_jail.png" width="200" height="200" border="0" alt="mruby-jail">
  </a>
</p>
<p align="center">
  <a href="http://git.home.network/0x1eef/mruby-jail">
    <img src="https://img.shields.io/badge/FreeBSD-Jails-blue.svg" alt="FreeBSD Jails">
  </a>
  <a href="https://opensource.org/license/0bsd">
    <img src="https://img.shields.io/badge/License-0BSD-orange.svg" alt="License">
  </a>
</p>

## About

mruby-jail provides mruby bindings for
[`libjail`](https://man.freebsd.org/cgi/man.cgi?query=jail&apropos=0&sektion=3).
The library provides an object-oriented interface for creating
and removing jails, reading and writing jail parameters,
enumerating running jails, finding jails by name or JID,
and attaching the current process to a jail. Similar in
approach to FreeBSD's lua bindings for jail management,
but exposed through mruby.

## Quick start

#### Create

Creates a new jail with a name, hostname, and path.
Other parameters can also be provided, and some parameters
have to be provided at creation time (such as `vnet` =>
`"new"`):

```ruby
jail = Jail.create(
  name: "example",
  hostname: "example.local",
  path: "/tmp/jail"
)
```

#### Parameters: all

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
jail = Jail.find_by_id(1)
p jail.parameters # => Hash
```

#### Parameters: get

Read the name, hostname, and path of an existing jail
through generated accessor methods that map to common
jail parameters:

```ruby
jail = Jail.find_by_id(1)
puts jail.name
puts jail.hostname
puts jail.path
```

#### Parameters: set

Update jail parameters through generated setters and a
hash-style interface. The generated setters cover common
properties, while the hash-style interface supports any
parameter exposed by
[`libjail`](https://man.freebsd.org/cgi/man.cgi?query=jail&apropos=0&sektion=3):

```ruby
##
# Preconfigured setters
jail = Jail.find_by_id(1)
jail.hostname = "example.local"

##
# Dynamic jail parameters
jail = Jail.find_by_id(1)
jail["host.hostname"] = "example.local"
```

#### All

Iterate over all running jails with `Jail.all`. Each
element in the collection is a Jail object with its ID
and readable properties:

```ruby
Jail.all.each do |jail|
  puts "JID=#{jail.id} name=#{jail.name}"
end
```

#### Find

Find a jail by ID or by name. Both methods return a Jail
instance that can be used for further operations:

```ruby
by_id = Jail.find_by_id(1)
by_name = Jail.find_by_name("example")
```

#### Attach

Attach the current process to a jail. After attaching,
the process runs within the jail's environment:

```ruby
jail = Jail.find_by_id(1)
jail.attach
```

#### Remove

Remove a jail from the system. This is a destructive
operation that kills all processes in the jail:

```ruby
jail = Jail.find_by_name("example")
jail.remove
```

## Build

```ruby
MRuby::Build.new("app") do |conf|
  conf.toolchain
  conf.gembox "default"
  conf.gem github: "0x1eef/mruby-jail", branch: "main"
end
```

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/)
<br>
See [LICENSE](./LICENSE)
