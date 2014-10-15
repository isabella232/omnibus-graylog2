require 'mixlib/config'
require 'chef/mash'
require 'chef/json_compat'
require 'chef/mixin/deep_merge'
require 'securerandom'
require 'uri'
require 'digest/sha2'

module Graylog2
  extend(Mixlib::Config)

  bootstrap Mash.new
  user Mash.new
  elasticsearch Mash.new
  mongodb Mash.new
  graylog2_server Mash.new
  graylog2_web Mash.new
  node nil

  class << self

    # guards against creating secrets on non-bootstrap node
    def generate_hex(chars)
      SecureRandom.hex(chars)
    end

    def generate_secrets(node_name)
      existing_secrets ||= Hash.new
      if File.exists?("/etc/graylog2/graylog2-secrets.json")
        existing_secrets = Chef::JSONCompat.from_json(File.read("/etc/graylog2/graylog2-secrets.json"))
      end
      existing_secrets.each do |k, v|
        v.each do |pk, p|
          Graylog2[k][pk] = p
        end
      end

      Graylog2['graylog2_web']['secret_token'] ||= generate_hex(64)
      Graylog2['graylog2_server']['secret_token'] ||= generate_hex(64)
      Graylog2['graylog2_server']['admin_password'] ||= Digest::SHA2.new << "admin"

      if File.directory?("/etc/graylog2")
        File.open("/etc/graylog2/graylog2-secrets.json", "w") do |f|
          f.puts(
            Chef::JSONCompat.to_json_pretty({
              'graylog2_server' => {
                'secret_token' => Graylog2['graylog2_server']['secret_token'],
                'admin_password' => Graylog2['graylog2_server']['admin_password'],
              },
              'graylog2_web' => {
                'secret_token' => Graylog2['graylog2_web']['secret_token'],
              }
            })
          )
          system("chmod 0600 /etc/graylog2/graylog2-secrets.json")
        end
      end
    end

    def generate_bootstrap
      if File.exists?("/var/opt/graylog2/bootstrapped")
        Graylog2['bootstrap']['bootstrapped'] = true
      else
        Graylog2['bootstrap']['bootstrapped'] = false
      end
    end

    def generate_services
      existing_services ||= Hash.new
      if File.exists?("/etc/graylog2/graylog2-services.json")
        existing_services = Chef::JSONCompat.from_json(File.read("/etc/graylog2/graylog2-services.json"))
      end
      existing_services.each do |k, v|
        v.each do |pk, p|
          Graylog2[k][pk] = p
        end
      end

      Graylog2['mongodb']['enabled'] = Graylog2[:node]['graylog2']['mongodb']['enable'] if Graylog2['mongodb']['enabled'].nil?
      Graylog2['elasticsearch']['enabled'] = Graylog2[:node]['graylog2']['elasticsearch']['enable'] if Graylog2['elasticsearch']['enabled'].nil?
      Graylog2['graylog2_server']['enabled'] = Graylog2[:node]['graylog2']['graylog2-server']['enable'] if Graylog2['graylog2_server']['enabled'].nil?
      Graylog2['graylog2_web']['enabled'] = Graylog2[:node]['graylog2']['graylog2-web']['enable'] if Graylog2['graylog2_web']['enabled'].nil?

      if File.directory?("/etc/graylog2")
        File.open("/etc/graylog2/graylog2-services.json", "w") do |f|
          f.puts(
            Chef::JSONCompat.to_json_pretty({
              'mongodb' => {
                'enabled' => Graylog2['mongodb']['enabled'],
              },
              'elasticsearch' => {
                'enabled' => Graylog2['elasticsearch']['enabled'],
              },
              'graylog2_server' => {
                'enabled' => Graylog2['graylog2_server']['enabled'],
              },
              'graylog2_web' => {
                'enabled' => Graylog2['graylog2_web']['enabled'],
              },
            })
          )
          system("chmod 0644 /etc/graylog2/graylog2-services.json")
        end
      end
    end

    def enabled?(service)
      Graylog2[service.gsub('-', '_')]['enabled']
    end

    def generate_hash
      results = { "graylog2" => {} }
      [
        "bootstrap",
        "mongodb",
        "elasticsearch",
        "graylog2-server",
        "graylog2-web"
      ].each do |key|
        rkey = key.gsub('_', '-')
        results['graylog2'][rkey] = Graylog2[key]
      end

      results
    end

    def generate_config(node_name)
      generate_secrets(node_name)
      generate_bootstrap
      generate_services
      generate_hash
    end
  end
end
