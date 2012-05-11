package Cisco::UCS::Interconnect;

use warnings;
use strict;

use Cisco::UCS;
use Cisco::UCS::Common::SwitchCard;
use Cisco::UCS::Common::PSU;
use Cisco::UCS::Common::Fan;
use Scalar::Util qw(weaken);
use Carp qw(croak);

our @ISA	= qw(Exporter Cisco::UCS);

our $VERSION	= '0.1';

our @ATTRIBUTES	= qw(dn id model operability serial vendor);

our %ATTRIBUTES = (
			memory		=> 'totalMemory',
			mgmt_ip		=> 'oobIfIp',
			mgmt_gw		=> 'oobIfGw',
			mgmt_net	=> 'oobIfMask',
		);

sub new {
	my ($class, %args) = @_;
	my $self = {};
	bless $self, $class;
	defined $args{dn}	? $self->{dn}	= $args{dn}		: croak 'dn not defined';
	defined $args{ucs} 	? weaken($self->{ucs} = $args{ucs})	: croak 'ucs not defined';
	my %attr = %{$self->{ucs}->resolve_dn(dn => $self->{dn})->{outConfig}->{networkElement}};

	while (my ($k, $v) = each %attr) { $self->{$k} = $v }

        return $self;
}

sub card {
	my ($self, $id) = @_;
	return ( defined $self->{card}->{$id} ? $self->{card}->{$id} : $self->get_card($id) )
}

sub get_card {
	my ($self, $id) = @_;
	return ( $id ? $self->get_cards($id) : undef )
}

sub get_cards {
	my ($self, $id) = @_;
	return $self->{ucs}->_get_child_objects(id => $id, type => 'equipmentSwitchCard', class => 'Cisco::UCS::Common::SwitchCard', attr => 'card', self => $self)
}

sub fan {
        my ($self, $id) = @_; 
        return ( defined $self->{fan}->{$id} ? $self->{fan}->{$id} : $self->get_fan($id) )   
}

sub get_fan {
	print "In get_fan\n";
        my ($self, $id) = @_; 
        return ( $id ? $self->get_fans($id) : undef )
}

sub get_fans {
	print "In get_fans\n";
        my ($self, $id)= @_; 
        return $self->{ucs}->_get_child_objects(id => $id, type => 'equipmentFan', class => 'Cisco::UCS::Common::Fan', attr => 'fan', self => $self)
}

sub psu {
        my ($self, $id) = @_; 
        return ( defined $self->{psu}->{$id} ? $self->{psu}->{$id} : $self->get_psu($id) )   
}

sub get_psu {
        my ($self, $id) = @_; 
        return ( $id ? $self->get_psus($id) : undef )
}

sub get_psus {
        my ($self, $id)= @_; 
        return $self->{ucs}->_get_child_objects(id => $id, type => 'equipmentpsu', class => 'Cisco::UCS::Common::PSU', attr => 'psu', self => $self)
}

{
	no strict 'refs';

	while ( my ($pseudo, $attribute) = each %ATTRIBUTES ) {
		*{ __PACKAGE__ . '::' . $pseudo } = sub {
			my $self = shift;
			return $self->{$attribute}
		}
	}

        foreach my $attribute (@ATTRIBUTES) {
                *{ __PACKAGE__ . '::' . $attribute } = sub {
                        my $self = shift;
                        return $self->{$attribute}
                }
        }
}

=head1 NAME

Cisco::UCS::Interconnect - Class for operations with a Cisco UCS Fabric Interconnect

=head1 SYNOPSIS

	print 'Memory: ' . $ucs->interconnect(A)->serial . " Mb\n";

	print map { 'Interconnect ' . $_->id . ' serial: ' . $_->serial . "\n" } $ucs->get_interconnects;

=head1 DESCRIPTION

Cisco::UCS::Interconnect is a class used to represent an abstracted interface to a Cisco Fabric Interconnect
object in a Cisco::UCS system.  This class provides functionality to retrieve information, statistics and
child objects (like Cisco::UCS::Common::EthernetPorts).

Please note that you should not need to call the constructor directly as Cisco::UCS::Interconnect objects 
are created for you by the methods in the Cisco::UCS package parent class.

Because of the inexorible relationship of a Cisco UCS Fabric Interconnect as a hardware platform and the
concept of a Cisco UCS management entity as a logical instance of the Cisco USCM running on the hardware
platform of a Cisco UCS Interconnect, some boundaries between the two become blurred within this package.

This class can be used for monitoring load and retrieving physical interface and component states and statistics,
however before employing it to do so, consider that SNMP provides similar interface statistic access with less
complexity without requiring session management.

=head2 METHODS

=head2 dn 

Returns the distinguished name of the fabric interconnect in the UCSM management informantion model.

=head2 id

Returns the identifier (either A or B) of the fabric interconnect.

=head2 model

Returns the vendor model code of the fabric interconnect.

=head2 operability

Returns the operability status of the fabric interconnect.

=head2 serial

Returns the serial number of the fabric interconnect.

=head2 vendor

Returns the vendor identification of the fabric interconnect.

=head2 memory

Returns the total installed memory in Mb.

=head2 mgmt_ip

Returns the configured management interface IP address.

=head2 mgmt_gw

Returns the configured management interface gateway IP address.

=head2 mgmt_net

Returns the configured management interface netmask.

=head2 get_fans
                
        my @fans = $ucs->interconnect(A)->get_fans;
        foreach my $fan (@fans) {
                print "Fan " . $fan->id . " thermal : " . $fan->thermal . "\n";
        }
        
Returns an array of Cisco::UCS::Common::Fan objects representing the fans installed in
the fabric interconnect.

=head2 get_fan ( $id )

	print "Fan 1 operability: " . $ucs->interconnect(A)->fan(1)->operability . "\n";       
 
Returns a Cisco::UCS::Common::Fan object corresponding to the fans specified by the numerical
identifier.  Note that this is a non-caching method and when invoked will always query the UCSM.
Consequently this method may be more expensive than the functionally equivalent caching B<fan>
method.

=head2 fan ( $id )
        
Returns a Cisco::UCS::Common::Fan object corresponding to the fans specified by the numerical
identifier.  Note that this is a caching method and when invoked will return an object retrieved
in a previous query if one is available.

=head2 get_psus
                
        my @psus = $ucs->interconnect(A)->get_psus;
        foreach my $psu (@psus) {
                print "PSU " . $psu->id . " thermal : " . $psu->thermal . "\n";
        }
        
Returns an array of Cisco::UCS::Common::PSU objects representing the PSUs installed in
the fabric interconnect.

=head2 get_psu ( $id )

	print "PSU 1 operability: " . $ucs->interconnect(A)->psu(1)->operability . "\n";
 
Returns a Cisco::UCS::Common::PSU object corresponding to the PSUs specified by the numerical
identifier.  Note that this is a non-caching method and when invoked will always query the UCSM.
Consequently this method may be more expensive than the functionally equivalent caching B<psu>
method.

=head2 psu ( $id )
        
Returns a Cisco::UCS::Common::PSU object corresponding to the PSUs specified by the numerical
identifier.  Note that this is a caching method and when invoked will return an object retrieved
in a previous query if one is available.

=head2 get_cards
                
        my @cards = $ucs->interconnect(A)->get_cards;
        foreach my $card (@cards) {
                print "Switchcard " . $card->id . " description : " . $card->description . "\n";
        }
        
Returns an array of Cisco::UCS::Common::SwitchCard objects representing the interface cards 
installed in the fabric interconnect.

=head2 get_card ( $id )

	print "Switchcard 1 operability: " . $ucs->interconnect(A)->card(1)->operability . "\n";
 
Returns a Cisco::UCS::Common::SwitchCard object corresponding to the interface card specified by 
the numerical identifier.  Note that this is a non-caching method and when invoked will always 
query the UCSM. Consequently this method may be more expensive than the functionally equivalent 
caching B<card> method.

=head2 card ( $id )
        
Returns a Cisco::UCS::Common::SwitchCard object corresponding to the interface card specified by the 
numerical identifier.  Note that this is a caching method and when invoked will return an object 
retrieved in a previous query if one is available.

=cut

=head1 AUTHOR

luke Poskitt, C<< <ltp at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-cisco-ucs-interconnect at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Cisco-UCS-Interconnect>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Cisco::UCS::Interconnect


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Cisco-UCS-Interconnect>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Cisco-UCS-Interconnect>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Cisco-UCS-Interconnect>

=item * Search CPAN

L<http://search.cpan.org/dist/Cisco-UCS-Interconnect/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2012 luke Poskitt.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;
