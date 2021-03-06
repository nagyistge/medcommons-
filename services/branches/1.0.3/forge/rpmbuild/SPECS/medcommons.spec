Name:		medcommons
Version:	0.3.283
Release:	1
Summary:	MedCommons Appliance

Group:		MedCommons
License:	MedCommons License

BuildRoot:	%{_tmppath}/%{name}-%{version}
BuildArch:	noarch

Requires:	medcommons-mc_backups medcommons-config medcommons-console medcommons-DDL medcommons-developers medcommons-gateway medcommons-identity medcommons-orders medcommons-jsvc medcommons-mc_locals medcommons-jai medcommons-php medcommons-schema medcommons-tomcat medcommons-tomcat-native medcommons-tools

%description
The MedCommons appliance.

%install
tar xzf $RPM_SOURCE_DIR/%{name}-%{version}.tar.gz -C %{_tmppath}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/etc/medcommons-release

%changelog
