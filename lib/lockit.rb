require 'fileutils'
module LockIt
  FILENAME='lock.txt'

  module Mixin
    def lock args = {}
      return false if locked?
      write_lock args
      self
    end

    def revise_lock args
      return false unless locked?
      # xxx is it my lock to revise?
      write_lock args
      self
    end

    def try_lock args = {}
      return false if locked?
      lock args
    end

    def locked?
      return true if closest_lock_file
      false
    end

    def unlock
      unlock!
    end

    def unlock!
      FileUtils.rm lock_file
    end

    def lock_info
      f = closest_lock_file
      header, obtained, id, release = open(f).read.split("\n").first.split(" ")
      info = {}
      info[:file] = f
      info[:obtained] = obtained
      info[:id] = id
      info[:release] = release if release

      info
    end

    private
    def closest_lock_file
      d = []
      last = nil
      while pwd = File.expand_path(File.join([self.path, d].flatten)) and pwd != last
        f =  File.join(pwd, LockIt::FILENAME)
	return f if File.exists? f
	d << '..'
        last = pwd
      end
      return false 
    end

    def lock_file
      File.join(self.path, LockIt::FILENAME)
    end
    def write_lock args
      File.open(lock_file, 'w') do |f|
        f.write(lock_content(args))
      end
    end

    def lock_content args
      s = "Lock: #{Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")} #{uniqid}"
      s += " #{args[:release].utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")}" if args[:release] and args[:release].respond_to? :utc
    end

    def uniqid
      Process.pid
    end

  end


  class Dir < ::Dir
    include LockIt::Mixin
  end
end
