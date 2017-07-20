name "mongodb"
default_version "3.4.6"
gem_version = "2.4.1"

dependency "runit"
dependency "ruby"
dependency "rubygems"

source url: "https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-#{version}.tgz",
       md5: "a49c20e50ab9d34d4700e1bc31a130b1"

relative_path "mongodb-linux-x86_64-#{version}"

build do
  mkdir "#{install_dir}/mongodb"
  sync  "#{project_dir}/", "#{install_dir}/mongodb"
  delete "#{install_dir}/mongodb/bin/mongoreplay"

  gem "install mongo -n #{install_dir}/embedded/bin --no-rdoc --no-ri -v #{gem_version}"
end
