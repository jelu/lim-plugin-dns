Name:           perl-Lim-Plugin-DNS
Version:        0.11
Release:        1%{?dist}
Summary:        Lim::Plugin::DNS - DNS management plugin for Lim

Group:          Development/Libraries
License:        GPL+ or Artistic
URL:            https://github.com/jelu/lim-plugin-dns/
Source0:        lim-plugin-dns-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildArch:      noarch
BuildRequires:  perl(ExtUtils::MakeMaker)
BuildRequires:  perl(Test::Simple)
BuildRequires:  perl(Lim) >= 0.16

Requires:  perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires:  perl(Lim) >= 0.16

%description
This plugin manage generic DNS related information like zone files via Lim. It
does not manage DNS software specific information.

%package -n perl-Lim-Plugin-DNS-Common
Summary: Common perl libraries for DNS Lim plugin
Group: Development/Libraries
Version: 0.11
%description -n perl-Lim-Plugin-DNS-Common
Common perl libraries for DNS Lim plugin.

%package -n perl-Lim-Plugin-DNS-Server
Summary: Server perl libraries for DNS Lim plugin
Group: Development/Libraries
Version: 0.11
%description -n perl-Lim-Plugin-DNS-Server
Server perl libraries for DNS Lim plugin.

%package -n perl-Lim-Plugin-DNS-Client
Summary: Client perl libraries for DNS Lim plugin
Group: Development/Libraries
Version: 0.11
%description -n perl-Lim-Plugin-DNS-Client
Client perl libraries for communicating with the DNS Lim plugin.

%package -n perl-Lim-Plugin-DNS-CLI
Summary: CLI perl libraries for DNS Lim plugin
Group: Development/Libraries
Version: 0.11
%description -n perl-Lim-Plugin-DNS-CLI
CLI perl libraries for managing a local or remote DNS installation
via DNS Lim plugin.

%package -n lim-management-console-dns
Requires: lim-management-console-common >= 0.16
Summary: DNS Manager Lim plugin Management Console files
Group: Development/Libraries
Version: 0.11
%description -n lim-management-console-dns
DNS Manager Lim plugin Management Console files.


%prep
%setup -q -n lim-plugin-dns


%build
%{__perl} Makefile.PL INSTALLDIRS=vendor
make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
make pure_install PERL_INSTALL_ROOT=$RPM_BUILD_ROOT
find $RPM_BUILD_ROOT -type f -name .packlist -exec rm -f {} ';'
mkdir -p %{buildroot}%{_datadir}/lim/html
mkdir -p %{buildroot}%{_datadir}/lim/html/_dns
mkdir -p %{buildroot}%{_datadir}/lim/html/_dns/js
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/about.html %{buildroot}%{_datadir}/lim/html/_dns/about.html
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/index.html %{buildroot}%{_datadir}/lim/html/_dns/index.html
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/js/application.js %{buildroot}%{_datadir}/lim/html/_dns/js/application.js
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/opt_create.html %{buildroot}%{_datadir}/lim/html/_dns/opt_create.html
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/opt_delete.html %{buildroot}%{_datadir}/lim/html/_dns/opt_delete.html
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/opt_list.html %{buildroot}%{_datadir}/lim/html/_dns/opt_list.html
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/opt_list_table.html %{buildroot}%{_datadir}/lim/html/_dns/opt_list_table.html
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/opt_read.html %{buildroot}%{_datadir}/lim/html/_dns/opt_read.html
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/opt_read_opt.html %{buildroot}%{_datadir}/lim/html/_dns/opt_read_opt.html
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/opt_update.html %{buildroot}%{_datadir}/lim/html/_dns/opt_update.html
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/rr_create.html %{buildroot}%{_datadir}/lim/html/_dns/rr_create.html
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/rr_delete.html %{buildroot}%{_datadir}/lim/html/_dns/rr_delete.html
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/rr_list.html %{buildroot}%{_datadir}/lim/html/_dns/rr_list.html
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/rr_list_table.html %{buildroot}%{_datadir}/lim/html/_dns/rr_list_table.html
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/rr_read.html %{buildroot}%{_datadir}/lim/html/_dns/rr_read.html
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/rr_read_rr.html %{buildroot}%{_datadir}/lim/html/_dns/rr_read_rr.html
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/rr_update.html %{buildroot}%{_datadir}/lim/html/_dns/rr_update.html
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/zone_create.html %{buildroot}%{_datadir}/lim/html/_dns/zone_create.html
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/zone_delete.html %{buildroot}%{_datadir}/lim/html/_dns/zone_delete.html
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/zone_list.html %{buildroot}%{_datadir}/lim/html/_dns/zone_list.html
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/zone_read.html %{buildroot}%{_datadir}/lim/html/_dns/zone_read.html
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/zone_update.html %{buildroot}%{_datadir}/lim/html/_dns/zone_update.html
install -m 644 %{_builddir}/lim-plugin-dns/html/_dns/zone_update_edit.html %{buildroot}%{_datadir}/lim/html/_dns/zone_update_edit.html


%check
make test


%clean
rm -rf $RPM_BUILD_ROOT


%files -n perl-Lim-Plugin-DNS-Common
%defattr(-,root,root,-)
%{_mandir}/man3/Lim::Plugin::DNS.3*
%{perl_vendorlib}/Lim/Plugin/DNS.pm

%files -n perl-Lim-Plugin-DNS-Server
%defattr(-,root,root,-)
%{_mandir}/man3/Lim::Plugin::DNS::Server.3*
%{perl_vendorlib}/Lim/Plugin/DNS/Server.pm

%files -n perl-Lim-Plugin-DNS-Client
%defattr(-,root,root,-)
%{_mandir}/man3/Lim::Plugin::DNS::Client.3*
%{perl_vendorlib}/Lim/Plugin/DNS/Client.pm

%files -n perl-Lim-Plugin-DNS-CLI
%defattr(-,root,root,-)
%{_mandir}/man3/Lim::Plugin::DNS::CLI.3*
%{perl_vendorlib}/Lim/Plugin/DNS/CLI.pm

%files -n lim-management-console-dns
%defattr(-,root,root,-)
%{_datadir}/lim/html/_dns/about.html
%{_datadir}/lim/html/_dns/index.html
%{_datadir}/lim/html/_dns/js/application.js
%{_datadir}/lim/html/_dns/opt_create.html
%{_datadir}/lim/html/_dns/opt_delete.html
%{_datadir}/lim/html/_dns/opt_list.html
%{_datadir}/lim/html/_dns/opt_list_table.html
%{_datadir}/lim/html/_dns/opt_read.html
%{_datadir}/lim/html/_dns/opt_read_opt.html
%{_datadir}/lim/html/_dns/opt_update.html
%{_datadir}/lim/html/_dns/rr_create.html
%{_datadir}/lim/html/_dns/rr_delete.html
%{_datadir}/lim/html/_dns/rr_list.html
%{_datadir}/lim/html/_dns/rr_list_table.html
%{_datadir}/lim/html/_dns/rr_read.html
%{_datadir}/lim/html/_dns/rr_read_rr.html
%{_datadir}/lim/html/_dns/rr_update.html
%{_datadir}/lim/html/_dns/zone_create.html
%{_datadir}/lim/html/_dns/zone_delete.html
%{_datadir}/lim/html/_dns/zone_list.html
%{_datadir}/lim/html/_dns/zone_read.html
%{_datadir}/lim/html/_dns/zone_update.html
%{_datadir}/lim/html/_dns/zone_update_edit.html


%changelog
* Wed Aug 07 2013 Jerry Lundström < lundstrom.jerry at gmail.com > - 0.11-1
- Release 0.11
* Fri Aug 02 2013 Jerry Lundström < lundstrom.jerry at gmail.com > - 0.10-1
- Release 0.10
* Sat Aug 11 2012 Jerry Lundström < lundstrom.jerry at gmail.com > - 0.10-1
- Initial package for Fedora

