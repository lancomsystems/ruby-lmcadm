# Temporary gemfile to be used by OCRA.
GEMFILE = 'ocra_gemfile'

# Add gems from gemspec.
ocra_gemfile = File.new(GEMFILE, 'w')
File.open("lmcadm.gemspec",'r') do |file|
  file.each { |line| ocra_gemfile.write "gem #{$1}\n" if line =~ /spec.add_runtime_dependency (.+)/ }
end
ocra_gemfile.close

# Execute OCRA
#system("ocra --gemfile #{GEMFILE} --console script_name")

# Cleanup
#FileUtils.rm Dir.glob(GEMFILE)
