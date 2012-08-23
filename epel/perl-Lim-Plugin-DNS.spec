Name:           perl-Lim-Plugin-DNS
Version:        0.10
Release:        1%{?dist}
Summary:        Lim::Plugin::DNS - DNS management plugin for Lim

Group:          Development/Libraries
License:        GPL+ or Artistic
URL:            https://github.com/jelu/lim-plugin-dns/
Source0:        lim-plugin-dns-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildArch:      noarch
BuildRequires:  perl(ExtUtils::MakeMaker)
# Needed for test
BuildRequires:  perl(Test::Simple)

Requires:  perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%description
This plugin manage generic DNS related information like zone files via Lim. It
does not manage DNS software specific information.

%package -n perl-Lim-Plugin-DNS-Common
Summary: Common perl libraries for DNS Lim plugin
Group: Development/Libraries
Version: 0.12
%description -n perl-Lim-Plugin-DNS-Common
Common perl libraries for DNS Lim plugin.

%package -n perl-Lim-Plugin-DNS-Server
Summary: Server perl libraries for DNS Lim plugin
Group: Development/Libraries
Version: 0.12
%description -n perl-Lim-Plugin-DNS-Server
Server perl libraries for DNS Lim plugin.

%package -n perl-Lim-Plugin-DNS-Client
Summary: Client perl libraries for DNS Lim plugin
Group: Development/Libraries
Version: 0.12
%description -n perl-Lim-Plugin-DNS-Client
Client perl libraries for communicating with the DNS Lim plugin.

%package -n perl-Lim-Plugin-DNS-CLI
Summary: CLI perl libraries for DNS Lim plugin
Group: Development/Libraries
Version: 0.12
%description -n perl-Lim-Plugin-DNS-CLI
CLI perl libraries for managing a local or remote DNS installation
via DNS Lim plugin.


%prep
%setup -q -n lim-plugin-dns


%build
%{__perl} Makefile.PL INSTALLDIRS=vendor
make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
make pure_install PERL_INSTALL_ROOT=$RPM_BUILD_ROOT
find $RPM_BUILD_ROOT -type f -name .packlist -exec rm -f {} ';'


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


%changelog
* Sat Aug 11 2012 Jerry Lundström < lundstrom.jerry at gmail.com > - 0.12-1
- Initial package for Fedora

