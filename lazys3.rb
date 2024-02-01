#!/usr/bin/env ruby
require 'net/http'
require 'timeout'

class String
  def red; "\e[31m#{self}\e[0m" end
end

class S3
  attr_reader :bucket, :domain, :code

  def initialize(bucket)
    @bucket = bucket
    @domain = format('http://%s.s3.amazonaws.com', bucket)
  end

  def exists?
    code != 404
  end

  def code
    http && http.code.to_i
  end

  private

  def http
    Timeout::timeout(5) do
      @http ||= Net::HTTP.get_response(URI.parse(@domain))
    end
  rescue
  end
end

class Scanner
  def initialize(list)
    @list = list
  end

  def scan
    @list.each do |word|
      bucket = S3.new word

      if bucket.exists?
        puts "Found bucket: #{bucket.bucket} (#{bucket.code})".red
      end
    end
  end
end

class Wordlist
  ENVIRONMENTS = %w(dev development stage s3 staging prod production test)
  PERMUTATIONS = %i(permutation_raw permutation_envs permutation_host)

  class << self
    def generate(common_prefix, prefix_wordlist)
      [].tap do |list|
        PERMUTATIONS.each do |permutation|
          list << send(permutation, common_prefix, prefix_wordlist)
        end
      end.flatten.uniq
    end

    def from_file(file)
      IO.read(file).split("\n")
    end

    def permutation_raw(common_prefix, _prefix_wordlist)
      common_prefix
    end

    def permutation_envs(common_prefix, prefix_wordlist)
      [].tap do |permutations|
        prefix_wordlist.each do |word|
          ENVIRONMENTS.each do |environment|
            ['%s-%s-%s', '%s-%s.%s', '%s-%s%s', '%s.%s-%s', '%s.%s.%s'].each do |bucket_format|
              permutations << format(bucket_format, common_prefix, word, environment)
            end
          end
        end
      end
    end

    def permutation_host(common_prefix, prefix_wordlist)
      [].tap do |permutations|
        prefix_wordlist.each do |word|
          ['%s.%s', '%s-%s', '%s%s'].each do |bucket_format|
            permutations << format(bucket_format, common_prefix, word)
            permutations << format(bucket_format, word, common_prefix)
          end
        end
      end
    end
  end
end

wordlist_file = ARGV[0]
common_prefix = ARGV[1]

if wordlist_file.nil? || common_prefix.nil?
  puts "Usage: ruby script.rb <wordlist_file> <common_prefix>"
  exit
end

wordlist = Wordlist.generate(common_prefix, Wordlist.from_file(wordlist_file))

puts "Generated wordlist, #{wordlist.length} items..."

Scanner.new(wordlist).scan
