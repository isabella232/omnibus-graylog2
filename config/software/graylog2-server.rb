name "graylog2-server"
default_version project.build_version

dependency "server-jre"
dependency "runit"

source url: "http://packages.graylog2.org/releases/graylog2-server/graylog2-server-#{version}.tgz",
       md5: "b244495ffddacff606a87abbfd166087"

relative_path "graylog2-server-#{version}"

build do
  mkdir "#{install_dir}/server"
  mkdir "#{install_dir}/plugin"
  sync  "#{project_dir}/", "#{install_dir}/server"
end
