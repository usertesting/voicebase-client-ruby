$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'voicebase'

# E.g. "/Users/foo/work/spec"
def spec_root
  File.dirname(__FILE__)
end

def fixtures_root
  "#{spec_root}/fixtures"
end
