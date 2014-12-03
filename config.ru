require('./chat-archiver')

run Sinatra::Application
# `run` is a method provided by `rack` to run web applications.
# See:
#  * An example `rack` app without `sinatra`: http://en.wikipedia.org/wiki/Rack_%28web_server_interface%29#Example_application
#  * An in depth, jargon filled overview of `rack`: http://rubylearning.com/blog/a-quick-introduction-to-rack/#C1
