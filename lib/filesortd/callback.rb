require "filesortd/matcher"
require "filesortd/afile"
require "docile"

module Filesortd
  # Folder DSL (add matchers)
  class Callback
    attr_accessor :matchers

    def initialize
      @matchers = {}
    end

    def any(&callback)
      @matchers[AlwaysTrueMatcher.new] = callback
    end

    def match(pattern, &callback)
      @matchers[BasenameMatcher.new(pattern)] = callback
    end

    def kind(pattern, &callback)
      @matchers[SpotlightMatcher.new("kMDItemKind", pattern)] = callback
    end

    def downloaded_from(pattern, &callback)
      pm = Matcher.new(pattern)
      m = XattrMatcher.new("com.apple.metadata:kMDItemWhereFroms") do |elements, path|
        elements.map { |el| pm.match(el) }.count(true) >= 1
      end
      @matchers[m] = callback
    end

    def call(paths)
      paths.each do |path|
        @matchers.each do |matcher, callback|
          Docile.dsl_eval(Afile.new(path), &callback) if matcher.match(path)
        end
      end
    end

  end
end
