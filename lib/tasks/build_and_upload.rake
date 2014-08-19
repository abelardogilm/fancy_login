desc "Build and upload Gem to GemFury repository"
task :build_and_upload do

  Rake::Task["build"].reenable
  Rake::Task["build"].invoke

  gem = `ls -t pkg/ | head -1`.chomp
  puts "Uploading gem #{gem}..."
  system "curl -F p1=@pkg/#{gem} https://push.fury.io/TeaSaNqqPSXrgpuHptXk/"
end