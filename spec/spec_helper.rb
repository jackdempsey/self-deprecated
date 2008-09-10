$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'stringio'

Spec::Runner.configure do |config|
  config.mock_with :rr
  
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure 
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end
  
  alias silence capture
end
