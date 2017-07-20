#!/usr/bin/env ruby
require 'io/console'
require 'net/http'
require 'open-uri'
require 'resolv'
require 'socket'
require 'timeout'



def get_pattern(targetURI)
  File.open("common_bucket_prefixes.txt", "r") do |f|
    f.each_line do |line|
      dotted_wordlist = line.chomp+"."
      dashed_wordlist = line.chomp+"-"
      prefix_host = ".s3.amazonaws.com"
      envs = ['dev', 'stage', 's3', 'staging', 'prod']
      $n = 0
      $total = 7
      while $n < $total do
        $n += 1
        case $n
        when 1
            fc_target = targetURI+"#{prefix_host}"
            get_response_code fc_target
        when 2
          envs.each do |env|
            c_wordlist = dashed_wordlist
            fc_target = c_wordlist+targetURI+"-"+"#{env}"+"#{prefix_host}"
            get_response_code fc_target
            c_wordlist = dotted_wordlist
            fc_target = c_wordlist+targetURI+"-"+"#{env}"+"#{prefix_host}"
            get_response_code fc_target
          end
        when 3
          envs.each do |env|
            c_wordlist = dashed_wordlist
            fc_target = c_wordlist+targetURI+"."+"#{env}"+"#{prefix_host}"
            get_response_code fc_target
            c_wordlist = dotted_wordlist
            fc_target = c_wordlist+targetURI+"."+"#{env}"+"#{prefix_host}"
            get_response_code fc_target
          end
        when 4
          envs.each do |env|
            c_wordlist = dashed_wordlist
            fc_target = c_wordlist+targetURI+"#{env}"+"#{prefix_host}"
            get_response_code fc_target
            c_wordlist = dotted_wordlist
            fc_target = c_wordlist+targetURI+"#{env}"+"#{prefix_host}"
            get_response_code fc_target
          end
        when 5
            c_wordlist = dashed_wordlist
            fc_target = c_wordlist+targetURI+"#{prefix_host}"
            get_response_code fc_target
            c_wordlist = dotted_wordlist
            fc_target = c_wordlist+targetURI+"#{prefix_host}"
            get_response_code fc_target
        when 6
          envs.each do |env|
            c_wordlist = dashed_wordlist
            fc_target = targetURI+"-"+c_wordlist+"#{env}"+"#{prefix_host}"
            get_response_code fc_target
            c_wordlist = dotted_wordlist
            fc_target = targetURI+"-"+c_wordlist+"#{env}"+"#{prefix_host}"
            get_response_code fc_target
          end
        else
        end
      end
    end
  end
end

def get_response_code(fc_target)
  begin
    target = "http://"+fc_target
      Timeout::timeout(5) {
        res = Net::HTTP.get_response(URI.parse(target))
        getCode = res.code
        if getCode != "404"
          puts fc_target + " bucket exist".red
        end
      }

    rescue Timeout::Error
    rescue URI::InvalidURIError
    rescue SocketError
    rescue Errno::ECONNREFUSED
    end
end

system "clear"
puts "Enter company name (Example: Yahoo)"
getURI = gets.chomp
get_pattern getURI
