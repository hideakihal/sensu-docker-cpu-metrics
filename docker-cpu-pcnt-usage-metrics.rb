#!/usr/bin/env ruby

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/metric/cli'
require 'socket'

class DockerContainerMetrics < Sensu::Plugin::Metric::CLI::Graphite

  option :scheme,
    :description => "Metric naming scheme, text to prepend to metric",
    :short => "-s SCHEME",
    :long => "--scheme SCHEME",
    :default => "#{Socket.gethostname}.docker"

  option :cgroup_path,
    :description => "path to cgroup mountpoint",
    :short => "-c PATH",
    :long => "--cgroup PATH",
    :default => "/sys/fs/cgroup"

  def get_cpuacct_stats 
     cpuacct_stat = []
     info = []
    `docker ps --no-trunc`.each_line do |ps|
      next if ps =~ /^CONTAINER/
      container, image = ps.split /\s+/
      prefix = "#{container}"

      ['cpuacct.stat','cpuacct.usage'].each do |stat|
        f = [config[:cgroup_path], "cpuacct/docker", container, stat].join('/')
        File.open(f, "r").each_line do |l|
          k, v = l.chomp.split /\s+/
          if (v != nil) then
            key = [prefix, stat, k].join('.')
            info.push(v)
          else
            key = [prefix, stat].join('.')
            info.push(k)
          end
          cpuacct_stat.push(key)
        end
      end
    end
    return Hash[cpuacct_stat.zip(info.map(&:to_i))].reject {|key, value| value == nil }
  end

  def run
    cpuacct_stat1 = get_cpuacct_stats
    sleep(5)
    cpuacct_stat2 = get_cpuacct_stats
    cpu_metrics = cpuacct_stat2.keys

    # diff cpu usage in last second
    cpu_sample_diff = Hash[cpuacct_stat2.map { |k, v| [k, v - cpuacct_stat1[k]] }]
      
    cpu_metrics.each do |metric|
      container, cpuacct, stat = metric.split /\./
      if (stat != "usage") then
        key = [container, cpuacct, 'usage'].join('.')
        metric_val = sprintf("%.02f", ((cpu_sample_diff[metric].to_f/100)/(cpu_sample_diff[key].to_f/1000/1000/1000))*100)
        output "#{config[:scheme]}.#{metric}", metric_val 
      end
    end
    ok
  end
end
