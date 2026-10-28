class Test < Picotest::Test
  ##
  # @api private
  def self.sequence
    @sequence ||= 0
  end

  ##
  # @api private
  def self.sequence=(sequence)
    @sequence = sequence
  end

  ##
  # @return [void]
  def setup
    Dir.mkdir(path) unless Dir.exist?(path)
    remove_jails
  end

  ##
  # @return [void]
  def teardown
    remove_jails
  end

  private

  ##
  # @return [String]
  def name
    self.class.sequence += 1
    "jail#{self.class.sequence}"
  end

  ##
  # @return [String]
  def path
    "/tmp/picoruby-jail-test"
  end

  ##
  # @return [void]
  def remove_jails
    Jail.each do |jail|
      jail.path == path ? jail.remove : nil
    rescue SystemCallError
    end
  end
end

class FlagTest < Test
  def test_create_constant
    assert_equal 0x01, Jail::CREATE
  end

  def test_update_constant
    assert_equal 0x02, Jail::UPDATE
  end

  def test_attach_constant
    assert_equal 0x04, Jail::ATTACH
  end

  def test_dying_constant
    assert_equal 0x08, Jail::DYING
  end

  def test_flags
    assert_equal({create: 0x01, update: 0x02, attach: 0x04, dying: 0x08}, Jail.flags)
  end
end

class ParameterTest < Test
  def test_parameters_returns_an_array
    assert_equal Array, Jail.parameters.class
  end

  def test_parameters_includes_jid
    assert Jail.parameters.include?("jid")
  end

  def test_parameters_includes_name
    assert Jail.parameters.include?("name")
  end

  def test_parameters_includes_path
    assert Jail.parameters.include?("path")
  end

  def test_parameters_of_a_jail
    jail = Jail.create(path:, name:)
    assert_equal path, jail.parameters["path"]
  end
end

class JailSetTest < Test
  def test_set_returns_a_jid
    assert Jail.set({"path" => path, "persist" => 1}, Jail::CREATE) >= 0
  end

  def test_get_returns_a_hash
    jid = Jail.set({"path" => path, "persist" => 1}, Jail::CREATE)
    assert_equal "Hash", Jail.get({"jid" => jid, "path" => nil}, 0).class.to_s
  end

  def test_get_returns_the_path
    jid = Jail.set({"path" => path, "persist" => 1}, Jail::CREATE)
    assert_equal path, Jail.get({"jid" => jid, "path" => nil}, 0)["path"]
  end

  def test_get_returns_persist
    jid = Jail.set({"path" => path, "persist" => 1}, Jail::CREATE)
    assert_equal 1, Jail.get({"jid" => jid, "persist" => nil}, 0)["persist"]
  end
end

class JailCreateTest < Test
  def test_create_returns_a_jail
    assert_equal "Jail", Jail.create(path:, name:).class.to_s
  end

  def test_create_returns_an_integer_jid
    jail = Jail.create(path:, name:)
    assert_equal Integer, jail.id.class
  end

  def test_create_sets_the_name
    jail = Jail.create(path:, name:)
    assert jail.name.start_with?("jail")
  end

  def test_create_sets_the_hostname
    jail = Jail.create(path:, name:, hostname: "test.local")
    assert_equal "test.local", jail.hostname
  end
end

class JailFindByTest < Test
  def test_find_by_jid
    jail = Jail.create(path:, name:)
    assert_equal jail.id, Jail.find_by(jid: jail.id).id
  end

  def test_find_by_name
    jail = Jail.create(path:, name:)
    assert_equal jail.name, Jail.find_by(name: jail.name).name
  end

  def test_find_by_without_a_selector
    assert_raise(ArgumentError) { Jail.find_by }
  end

  def test_find_by_with_both_selectors
    assert_raise(ArgumentError) { Jail.find_by(jid: 1, name: "example") }
  end
end

class JailEachTest < Test
  def test_each_includes_the_jail
    jail = Jail.create(path:, name:)
    assert Jail.map { _1.name }.include?(jail.name)
  end
end

class JailAttachTest < Test
  def test_attach_raises_for_an_unknown_jail
    jid = Jail.set({"path" => path, "persist" => 1}, Jail::CREATE)
    Jail.remove(jid)
    assert_raise(Errno::EINVAL) { Jail.attach(jid) }
  end
end

class JailRemoveTest < Test
  def test_remove
    jid = Jail.set({"path" => path, "persist" => 1}, Jail::CREATE)
    Jail.remove(jid)
    assert_raise(Errno::ENOENT) { Jail.get({"jid" => jid, "name" => nil}, 0) }
  end
end

class JailAccessorTest < Test
  def test_get_a_parameter
    jail = Jail.create(path:, name:, hostname: "read.local")
    assert_equal "read.local", jail["host.hostname"]
  end

  def test_set_a_parameter
    jail = Jail.create(path:, name:)
    jail.hostname = "write.local"
    assert_equal "write.local", jail.hostname
  end
end

class JailInspectTest < Test
  def test_inspect_includes_the_name
    jail = Jail.create(path:, name:)
    assert jail.inspect.include?(jail.name)
  end
end
