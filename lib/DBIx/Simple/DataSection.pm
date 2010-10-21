package DBIx::Simple::DataSection;
use strict;
use warnings;
use base 'DBIx::Simple';
our $VERSION = '0.01';

use Carp;
use Data::Section::Simple;

sub new {
    my $self = shift->SUPER::new(@_);
    $self->_init;
    $self;
}

sub connect {
    my $self = shift->SUPER::connect(@_);
    $self->_init;
    $self;
}

sub _init {
    my $self = shift;
    $self->{package} ||= scalar caller(1);
    $self->{section} = Data::Section::Simple->new( $self->{package} );
    $self->{cache}   = {};
}

# other name?
sub query_by_sql {
    my ( $self, $sql_name, @binds ) = @_;
    my $query = $self->get_sql($sql_name);
    $self->SUPER::query( $query, @binds );
}

sub get_sql {
    my ( $self, $sql_name ) = @_;

    if ( my $sql = $self->{cache}{$sql_name} ) {
        return $sql;
    }
    my $sql = $self->{section}->get_data_section($sql_name);
    if ($sql) {
        $self->{cache}{$sql_name} = $sql if $self->{use_cache};
        return $sql;
    }
    croak "could not find sql: $sql_name in __DATA__ section";
}

1;

__END__

=encoding utf-8

=head1 NAME

DBIx::Simple::DataSection - executes the sql in the __DATA__ section 

=head1 SYNOPSIS

  # Create db instance
  use DBIx::Simple::DataSection; 
  my $dbh = ...
  my $db = DBIx::Simple::DataSection->connect($dbh)

  # Execute the query which is defined in __DATA__ section
  my $foo = ... 
  my $bar = ...
  my $rs = $db->query_by_sql('select.sql', $foo, $bar) 
    or die $db->error;
  
  __DATA__
  @@ select.sql 
  SELECT FROM foo WHERE foo = ? OR bar = ?

=head1 DESCRIPTION

DBIx::Simple::DataSection is a simple DBIx::Simple wrapper module which allows you 
to execute the sql defined in __DATA__ section.

=head1 SOURCE AVAILABILITY

This source is in Github:

  http://github.com/dann/p5-dbix-simple-datasection

=head1 AUTHOR

dann E<lt>techmemo@gmail.comE<gt>

=head1 SEE ALSO

L<DBIx::Simple>, L<Data::Section::Simple>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
