package DBIx::Password;
use strict;
use DBI();

@DBIx::Password::ISA = qw ( DBI::db );
($DBIx::Password::VERSION) = ' $Revision: 1.8 $ ' =~ /\$Revision:\s+([^\s]+)/;

my $virtual1 = {
              'slash' => {
                           'username' => '',
                           'password' => '',
                           'port' => '',
                           'database' => 'sdf',
                           'attributes' => {},
                           'connect' => 'DBI:mysql:database=sdf;host=asf',
                           'driver' => 'mysql',
                           'host' => 'asf'
                         }
            };


my %driver_cache;

sub connect {
	my ($class, $user, $options) = @_;
	return undef unless $virtual1->{$user};
	my $self;
	my $virtual = $virtual1->{$user};
	return unless $virtual;

	$self = DBI->connect($virtual->{connect}
			, $virtual->{'username'}
			, $virtual->{'password'}
			, $virtual->{'attributes'}
			);
	bless $self, $class;
	$driver_cache{$self} = $user;
	return $self;
}

sub connect_cached {
	my ($class, $user, $options) = @_;
	return undef unless $virtual1->{$user};
	my $self;
	my $virtual = $virtual1->{$user};

	$self = DBI->connect_cached($virtual->{connect}
			, $virtual->{'username'}
			, $virtual->{'password'}
			, $virtual->{'attributes'}
			);
	return unless $self;
	bless $self, $class;
	$driver_cache{$self} = $user;
	return $self;
}

sub getDriver {
	my ($self) = @_;
	unless(ref $self) {
		for my $key (keys %$virtual1) {
			return $virtual1->{$key}->{'driver'} if $self eq $key; 
		}
	} else {
		my $user = $driver_cache{$self};
		return $virtual1->{$user}{'driver'};
	}
}

sub checkVirtualUser {
	my ($user) = @_;
	return 1 
		if $virtual1->{$user};

	return 0;
}

sub DESTROY {
    my ($self) = @_;
    $self->SUPER::DESTROY;
}

1;

=head1 NAME

DBIx::Password - Allows you to create a global password file for DB passwords

=head1 SYNOPSIS

  use DBIx::Password;
  my $dbh = DBIx::Password->connect($user);
  my $dbh = DBIx::Password->connect_cached($user);
  $dbh->getDriver;
  DBIx::Password::getDriver($user);
  DBIx::Password::checkVirtualUser($user);

=head1 DESCRIPTION

Don't you hate keeping track of database passwords and such throughout
your scripts? How about the problem of changing those passwords 
on a mass scale? This module is one possible solution. When you
go to build this module it will ask you to create virtual users.
For each user you need to specify the database module to use,
the database connect string, the username and the password. You
will be prompted to give a name to this virtual user.
You can add as many as you like.

I would recommend that if you are only using this with
web applications that you change the final permissions on this 
package after it is installed in site_perl such that only
the webserver can read it.

A method called getDriver has been added so that you
can determine what driver is being used (handy for
working out database indepence issues).

If you want to find out if the virtual user is valid,
you can call the class method checkVirtualUser().
It returns true (1) if the username is valid, and
zero if not.

Once your are done you can use the connect method (or
the connect_cache method) that comes with DBIx-Password 
and just specify one of the virtual users you defined 
while making the module.

BTW I learned the bless hack that is used from Apache::DBI
so some credit should go to the authors of that module.
This is a rewrite of the module Tangent::DB that I did
for slashcode.

Hope you enjoy it.

=head1 INSTALL

Basically:

perl Makefile.PL

make

make test

make install

Be sure to answer the questions as you make the module

=head1 HOME

To find out more information look at: http://software.tangent.org/projects.pl?view=DBIxPassword

=head1 AUTHOR

Brian Aker, brian@tangent.org

=head1 SEE ALSO

perl(1). DBI(3).

=cut

