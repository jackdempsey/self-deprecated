require 'find'

# Take a directory, and a list of patterns to match, and a list of filenames to avoid
def recursive_search(dir,patterns, excludes=[/\.git/, /\.svn/, /,v$/, /\.cvs$/, /\.tmp$/, /^RCS$/, /^SCCS$/, /~$/])
  results = Hash.new{|h,k| h[k] = ''}

  Find.find(dir) do |path|
    fb =  File.basename(path) 
    next if excludes.any?{|e| fb =~ e}
    if File.directory?(path)
      if fb =~ /\.{1,2}/ 
        Find.prune
      else
        next
      end
    else  # file...
      File.open(path, 'r') do |f|
        ln = 1
        while (line = f.gets)
          patterns.each do |p|
            if !line.scan(p).empty?
              results[p] += "#{path}:#{ln}:#{line}"
            end
          end
          ln += 1
        end
      end
    end
  end
  results
end


class Merb < Thor
  desc 'deprecations [DIRECTORY]', 'Find deprecations in the code'
  method_options :version => :optional
  def deprecations(dir_to_search='.')
    conversions = self.class.messages(options[:version])
    results = recursive_search(File.expand_path(dir_to_search),conversions.keys)

    conversions.each do |key, warning|
      unless results[key].empty?
        puts '--> ' + key.to_s.gsub('?-mix:','') # clean up what the regexp.to_s looks like
        puts "  !! " + warning + " !!"
        puts '  ' + '.' * (warning.length + 6)
        puts results[key]
        puts
      end
    end
  end


  def self.always_messages
    {
      'before_filter'     => 'Use before',
      'after_filter'      => 'Use after',
      'render :partial'   => 'Use partial',
      'redirect_to'       => 'Use redirect',
      'url_for'           => 'Use url',
      /redirect.*?return/ => "You want to 'return redirect(...)' not 'redirect and return'"
    }
  end

  def self.versioned_messages
    {'0.9.5' => {'foo' => 'bar'}}
  end

  def self.messages(version=nil)
    # scan through the VERSIONED hash and select out the tasks that are less than or equal to the passed in version
    if version
      always_messages.merge(versioned_messages.inject({}) do |hash,val|
        (val.first.delete('.').to_i <= version.delete('.').to_i) ? hash.merge(val.last) : hash
      end)
    else
      always_messages.merge(versioned_messages.values.inject {|hash,val| hash.merge(val)})
    end
  end
end