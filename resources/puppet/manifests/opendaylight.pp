####################################################

include apt

#class { "apt":
#  always_apt_update    => true,
#  disable_keys         => undef,
#  proxy_host           => false,
#  proxy_port           => "8080",
#  purge_sources_list   => false,
#  purge_sources_list_d => false,
#  purge_preferences_d  => false,
#  update_timeout       => undef,
#  fancy_progress       => undef
#}

### Install Deps Packages
$deps = [ "build-essential",
          "debhelper",
          "python-software-properties",
          "dkms",
          "fakeroot",
          "graphviz",
          "linux-headers-generic",
          "python-all",
          "python-qt4",
          "python-zopeinterface",
          "python-twisted-conch",
          "python-twisted-web",
          "xauth",
]

### Export Env: Global %PATH for "Exec"
Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }

### Apt Update
#exec { "apt-update":
#    command => "/usr/bin/apt-get update",
#    user    => "root",
#    timeout => "0",
#}

package { $deps:
    ensure   => installed,
}

### Oracle Java/JDK 7
apt::ppa { "ppa:webupd8team/java": }
package { "oracle-java7-installer":
    ensure  => installed,
    responsefile => "/vagrant/resources/puppet/files/oracle-java.preseed",
    require => Apt::Ppa["ppa:webupd8team/java"],
}
exec{ "update-java-alternatives -s java-7-oracle":
    require => Package["oracle-java7-installer"],
    timeout => "0",
}
$java_home = "/usr/lib/jvm/java-7-oracle"
file { "/etc/profile.d/java_home.sh":
    ensure  => present,
    content => "export JAVA_HOME=\"${java_home}\"";
}

$odl_dist_helium_name = "distribution-karaf-0.2.0-Helium"
exec { "Wget ODL-Helium":
    #command  => "wget http://nexus.opendaylight.org/content/groups/public/org/opendaylight/integration/distribution-karaf/0.2.0-Helium/${odl_dist_helium_name}.zip",
    command  => "wget https://plink.ucloud.com/public_link/link/be767e3b82bfdf2d -O ${odl_dist_helium_name}.zip",
    creates  => "/home/vagrant/${odl_dist_helium_name}.zip",
    cwd      => "/home/vagrant",
    user     => "vagrant",
    timeout  => "0",
}

exec { "Extract ODL-Helium (for OpenStack)":
    command => "unzip ${odl_dist_helium_name}.zip && mv ${odl_dist_helium_name} opendaylight-openstack",
    creates => "/home/vagrant/opendaylight-openstack",
    cwd     => "/home/vagrant",
    user    => "vagrant",
    timeout => "0",
    require => Exec["Wget ODL-Helium"],
}

exec { "Extract ODL-Helium (for Mininet)":
    command => "unzip ${odl_dist_helium_name}.zip && mv ${odl_dist_helium_name} opendaylight-mininet",
    creates => "/home/vagrant/opendaylight-mininet",
    cwd     => "/home/vagrant",
    user    => "vagrant",
    timeout => "0",
    require => Exec["Wget ODL-Helium"],
}

file { "Put ODL-Helium-Run-Script (for OpenStack)":
    path     => "/home/vagrant/opendaylight-openstack/run-openstack.sh",
    owner    => "vagrant",
    group    => "vagrant",
    mode     => 0755,
    source   => "/vagrant/resources/puppet/files/run-openstack.sh",
    replace  => true,
    require  => Exec["Extract ODL-Helium (for OpenStack)"],
}

file { "Put ODL-Helium-Run-Script (for Mininet)":
    path     => "/home/vagrant/opendaylight-mininet/run-mininet.sh",
    owner    => "vagrant",
    group    => "vagrant",
    mode     => 0755,
    source   => "/vagrant/resources/puppet/files/run-mininet.sh",
    replace  => true,
    require  => Exec["Extract ODL-Helium (for Mininet)"],
}
