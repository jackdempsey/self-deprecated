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

  # options
  
  # option to show matches that weren't found, ie. 'clean'
  
  # ability to let user specify a lambda to execute to print out display stuff
  desc 'deprecations', 'Find deprecations in the code'
  def deprecations(dir_to_search='.')
    conversions = {
      'before_filter'   => 'Use before',
      'after_filter'   => 'Use after',
      'render :partial' => 'Use partial',
      'redirect_to' => 'Use redirect',
      'url_for' => 'Use url',
      /redirect.*?return/ => "You want to 'return redirect(...)' not 'redirect and return'"
    }

    results = recursive_search(dir_to_search,conversions.keys)

    conversions.each do |key, warning|
      puts '--> ' + key.to_s.gsub('?-mix:','') # clean up what the regexp.to_s looks like
      unless results[key] =~ /^$/
        puts "  !! " + warning + " !!"
        puts '  ' + '.' * (warning.length + 6)
        puts results[key]
      else
        puts "  Clean! Cheers for you!"
      end
      puts
    end
  end
  
end