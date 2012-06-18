module IsItWorking
  class BundlerCheck
    def initialize(options={})
        end
    
    def call(status)

      gems.each do |gem|
        status.info "#{gem[:name]} (#{gem[:version]}) [#{ gem[:dependencies].map { |x| "#{x[:name]} (#{x[:version]})" }.join(",") }]"
      end
    end
    
    private
    def dependencies
      @dependencies ||= Hash[groups.collect { |group,deps| [group,Hash[deps.collect { |dep| [dep.name,dependency_hash(environment, dep.name)] }]] }]
    end

    def environment
      @environment ||= Bundler.load
    end

    def graph
      @graph ||= Bundler::Graph.new(environment, '/dev/null')
    end

    def groups
      @groups ||= environment.current_dependencies.group_by { |d| d.groups.first.to_s }
    end

    def version key
      dependency_version key
    end

    def gems

      graph.groups.map do |group|
        nodes = graph.relations[group]
        nodes.map { |gem| { :name => gem, :version => dependency_version(gem), :dependencies => graph.relations[gem].map { |d| { :name => d, :version => dependency_version(d) } } } }
      end.flatten
    end

    def dependency_version(key)
      spec = environment.specs.find { |s| s.name == key }
      rev = spec.git_version
      rev.strip! unless rev.nil?
      location = [spec.source.options.values_at('path','uri').compact.first,rev].compact.join('@')
      [spec.version.to_s,location].compact.join(' ').strip
    end
    
  end
end
