sensu-docker-cpu-metrics
========================

This Sensu-plugin gather docker containers cpu usage metrics from the host. 

## Usage
 
Add the script on the docker host

```
$ cd /etc/sensu/plugins/system 
$ wget https://github.com/hideakihal/sensu-docker-cpu-metrics/master/docker-cpu-pcnt-usage-metrics.rb
$ chmod 755 docker-cpu-pcnt-usage-metrics.rb
```

Test the script

```
$ sudo watch /opt/sensu/embedded/bin/ruby docker-cpu-pcnt-usage-metrics.rb
```

Add the metric check definition  

```
$ vi /etc/sensu/conf.d/metrics/metric_vmstat.json
```

## References
  * http://qiita.com/marshi@github/items/e8db79c43abf2fca8d72
  * https://access.redhat.com/documentation/ja-JP/Red_Hat_Enterprise_Linux/6/html/Resource_Management_Guide/sec-cpuacct.html
