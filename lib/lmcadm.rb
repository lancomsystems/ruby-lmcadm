Dir.glob(File.expand_path("../lmcadm/*.rb", __FILE__)).each do |file|
  require file
end
Dir.glob(File.expand_path("../lmcadm/helpers/*.rb", __FILE__)).each do |file|
  require file
end
module LMCAdm
  # Your code goes here...
end
