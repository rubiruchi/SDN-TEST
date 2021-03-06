####################################################
#import "base.pp"

include apt

### Export Env: Global %PATH for "Exec"
Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }

### Oracle Java/JDK 7
apt::ppa { "ppa:webupd8team/java": }

exec { "apt-update":
    command => "/usr/bin/apt-get update",
    user    => "root",
    timeout => "0",
    require => Apt::Ppa["ppa:webupd8team/java"],
}

$apt_cache_dir = "/var/cache/oracle-jdk7-installer"
$jdk7_tar = "jdk-7u80-linux-x64.tar.gz"
$jdk7_url = "https://goo.gl/6H8BEW"

file { "mkdir ${apt_cache_dir}":
    path    => "${apt_cache_dir}",
    ensure  => directory,
    owner   => "root",
    group   => "root",
}

exec { "Wget ${jdk7_tar}":
    command  => "wget ${jdk7_url} -O ${jdk7_tar}",
    creates  => "${apt_cache_dir}/${jdk7_tar}",
    cwd      => "${apt_cache_dir}",
    user     => "root",
    timeout  => "0",
    require  => File["mkdir ${apt_cache_dir}"],
}

#file { "Put ${jdk7_tar}":
#    path     => "${apt_cache_dir}/${jdk7_tar}",
#    owner    => "vagrant",
#    group    => "vagrant",
#    mode     => 0755,
#    source   => "/vagrant/resources/puppet/files/${jdk7_tar}",
#    ensure   => directory,
#    replace  => true,
#    recurse  => true,
#    require  => File["mkdir ${apt_cache_dir}"],
#}

package { "oracle-java7-installer":
    ensure  => installed,
    responsefile => "/vagrant/resources/puppet/files/oracle-java7.preseed",
    #require => Apt::Ppa["ppa:webupd8team/java"],
    require => [Exec["apt-update"], Exec["Wget ${jdk7_tar}"]]
}

#exec{ "update-java-alternatives -s java-7-oracle":
#    timeout => "0",
#    require => Package["oracle-java7-installer"],
#}

package { "oracle-java7-set-default":
    ensure  => installed,
    #require => Apt::Ppa["ppa:webupd8team/java"],
    #require => Exec["apt-update"],
    require => Package["oracle-java7-installer"],
}

#$java_home = "/usr/lib/jvm/java-7-oracle"
#file { "/etc/profile.d/java_home.sh":
#    ensure  => present,
#    content => "export JAVA_HOME=\"${java_home}\"",
#    require => Exec["update-java-alternatives -s java-7-oracle"],
#    require => Package["oracle-java7-set-default"],
#}
