require_relative "../lib/web_server"
require "test/unit"

class WebServerTest < Test::Unit::TestCase
  def setup
    @server = WebServer.new
  end

  def test_episode_178
    url = 'http://rubyrogues.com/178-rr-book-club-refactoring-ruby-with-martin-fowler/'
    episode = @server.send :episode_info, url
    assert_equal episode[:mp3], 'http://traffic.libsyn.com/rubyrogues/RR178RefactoringBook.mp3'
  end

  def test_all_episode
    # episodes = @server.send :all_episode
    # assert_equal episodes.length, 178
  end
end

