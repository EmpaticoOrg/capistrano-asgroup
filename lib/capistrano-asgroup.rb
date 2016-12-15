if Gem::Specification.find_by_name('capistrano').version >= Gem::Version.new('3.0.0')
  load File.expand_path('../capistrano/asgroup.rb', __FILE__)
  load File.expand_path('../capistrano/version.rb', __FILE__)
else
  puts "Oops, you may need capistrano 3+"
end
